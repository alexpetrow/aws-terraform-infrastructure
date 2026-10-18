# --- Trust GitHub as an identity provider -----------------------------------

resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

# --- Who can assume the plan role --------------------------------------------

data "aws_iam_policy_document" "plan_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Only pull request workflows from this exact repository
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repository}:pull_request"]
    }
  }
}

resource "aws_iam_role" "plan" {
  name                 = "github-actions-terraform-plan"
  description          = "Read-only role for terraform plan in pull requests"
  assume_role_policy   = data.aws_iam_policy_document.plan_trust.json
  max_session_duration = 3600
}

# --- What the plan role can do -----------------------------------------------

resource "aws_iam_role_policy_attachment" "read_only" {
  role       = aws_iam_role.plan.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

data "aws_iam_policy_document" "state_access" {
  statement {
    sid       = "ListStateBucket"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.state_bucket_name}"]
  }

  statement {
    sid       = "ReadState"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.state_bucket_name}/*"]
  }

  statement {
    sid       = "ManageLockFile"
    actions   = ["s3:PutObject", "s3:DeleteObject"]
    resources = ["arn:aws:s3:::${var.state_bucket_name}/*.tflock"]
  }
}

resource "aws_iam_role_policy" "state_access" {
  name   = "terraform-state-access"
  role   = aws_iam_role.plan.id
  policy = data.aws_iam_policy_document.state_access.json
}

output "plan_role_arn" {
  description = "Role ARN for GitHub Actions (store as a repository secret)"
  value       = aws_iam_role.plan.arn
}

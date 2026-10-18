variable "github_owner" {
  description = "GitHub account that owns the repository"
  type        = string
  default     = "alexpetrow"
}

variable "github_owner_id" {
  description = "Immutable numeric ID of the GitHub account"
  type        = string
  default     = "150142473"
}

variable "github_repo" {
  description = "Repository name"
  type        = string
  default     = "aws-terraform-infrastructure"
}

variable "github_repo_id" {
  description = "Immutable numeric ID of the repository"
  type        = string
  default     = "1418569941"
}

variable "state_bucket_name" {
  description = "S3 bucket with Terraform state"
  type        = string
  default     = "alexpetrow-tf-state-euc1"
}

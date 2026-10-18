provider "aws" {
  region = "eu-central-1"

  default_tags {
    tags = {
      Project   = "aws-terraform-infrastructure"
      Component = "ci-access"
      ManagedBy = "terraform"
    }
  }
}

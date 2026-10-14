provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = "aws-terraform-infrastructure"
      Environment = "dev"
      ManagedBy   = "terraform"
    }
  }
}

variable "github_repository" {
  description = "GitHub repository allowed to assume the plan role (owner/name)"
  type        = string
  default     = "alexpetrow/aws-terraform-infrastructure"
}

variable "state_bucket_name" {
  description = "S3 bucket with Terraform state"
  type        = string
  default     = "alexpetrow-tf-state-euc1"
}

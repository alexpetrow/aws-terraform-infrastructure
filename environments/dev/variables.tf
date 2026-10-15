variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "ssh_allowed_cidr" {
  description = "Your public IP in CIDR notation (/32), allowed to use SSH"
  type        = string
}

variable "ssh_public_key" {
  description = "Public SSH key of the control node"
  type        = string
}

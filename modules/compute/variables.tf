variable "name" {
  description = "Name prefix for compute resources"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC for the security group"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet for the instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "root_volume_size" {
  description = "Size of the root volume in GiB"
  type        = number
  default     = 10
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to connect over SSH (e.g. your public IP with /32)"
  type        = string

  validation {
    condition     = can(cidrhost(var.ssh_allowed_cidr, 0)) && var.ssh_allowed_cidr != "0.0.0.0/0"
    error_message = "ssh_allowed_cidr must be a valid CIDR and must not be 0.0.0.0/0."
  }
}

variable "ssh_public_key" {
  description = "Public SSH key content for the instance"
  type        = string
}

variable "role" {
  description = "Role of the instance, used by Ansible dynamic inventory for grouping"
  type        = string
  default     = "web"
}

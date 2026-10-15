output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "Public IPv4 address of the instance"
  value       = aws_instance.this.public_ip
}

output "public_dns" {
  description = "Public DNS name of the instance"
  value       = aws_instance.this.public_dns
}

output "security_group_id" {
  description = "ID of the instance security group"
  value       = aws_security_group.this.id
}

output "ami_id" {
  description = "AMI used for the instance"
  value       = aws_instance.this.ami
}

# Values shown after Terraform apply.
output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Public IP address of the EC2 instance."
  value       = aws_instance.web.public_ip
}

output "security_group_id" {
  description = "ID of the security group."
  value       = aws_security_group.web.id
}

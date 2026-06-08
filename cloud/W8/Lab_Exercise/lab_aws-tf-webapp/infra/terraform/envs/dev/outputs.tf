output "ec2_public_ip" {
  description = "Public IP of the EC2 web server."
  value       = module.ec2.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of the EC2 web server."
  value       = module.ec2.public_dns
}

output "rds_endpoint" {
  description = "RDS MySQL endpoint."
  value       = module.rds.endpoint
}

output "static_bucket_name" {
  description = "S3 bucket for static assets."
  value       = module.s3.bucket_name
}


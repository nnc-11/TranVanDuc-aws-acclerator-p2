output "state_bucket_name" {
  description = "S3 bucket name for Terraform remote state."
  value       = aws_s3_bucket.state.bucket
}

output "lock_table_name" {
  description = "DynamoDB table name for Terraform state locking."
  value       = aws_dynamodb_table.locks.name
}

output "backend_config_hint" {
  description = "Values to copy into envs/dev/backend.tf."
  value = {
    bucket         = aws_s3_bucket.state.bucket
    dynamodb_table = aws_dynamodb_table.locks.name
    region         = var.aws_region
  }
}


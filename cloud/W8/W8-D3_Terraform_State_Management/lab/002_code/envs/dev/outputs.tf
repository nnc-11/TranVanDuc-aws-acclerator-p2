output "app_bucket_name" {
  description = "Name of the private S3 bucket created by the module."
  value       = module.app_bucket.bucket_name
}

output "app_bucket_arn" {
  description = "ARN of the private S3 bucket created by the module."
  value       = module.app_bucket.bucket_arn
}

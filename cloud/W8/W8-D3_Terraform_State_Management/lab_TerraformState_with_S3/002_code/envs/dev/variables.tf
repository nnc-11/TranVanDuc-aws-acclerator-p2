variable "aws_region" {
  description = "AWS region for dev resources."
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Project name used for naming and tags."
  type        = string
  default     = "w8-d3-terraform"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"
}

variable "bucket_name" {
  description = "Globally unique private S3 bucket name for the demo module."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "S3 bucket name must be 3-63 characters and use only lowercase letters, numbers, dots, or hyphens."
  }
}

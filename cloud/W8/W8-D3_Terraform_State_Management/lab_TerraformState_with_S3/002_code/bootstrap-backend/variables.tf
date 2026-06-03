variable "aws_region" {
  description = "AWS region for the Terraform backend resources."
  type        = string
  default     = "ap-southeast-1"
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name for Terraform state."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.state_bucket_name))
    error_message = "S3 bucket name must be 3-63 characters and use only lowercase letters, numbers, dots, or hyphens."
  }
}

variable "lock_table_name" {
  description = "DynamoDB table name used for Terraform state locking."
  type        = string
  default     = "terraform-state-locks-dev"
}

variable "tags" {
  description = "Common tags for backend resources."
  type        = map(string)
  default = {
    Project     = "w8-d3-terraform-state-management"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Purpose     = "terraform-state-backend"
  }
}

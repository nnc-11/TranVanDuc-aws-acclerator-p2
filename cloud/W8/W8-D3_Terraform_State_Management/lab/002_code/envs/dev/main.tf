provider "aws" {
  region = var.aws_region
}

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Lesson      = "W8-D3"
  }
}

module "app_bucket" {
  source = "../../modules/s3_private_bucket"

  bucket_name = var.bucket_name
  tags        = local.common_tags
}

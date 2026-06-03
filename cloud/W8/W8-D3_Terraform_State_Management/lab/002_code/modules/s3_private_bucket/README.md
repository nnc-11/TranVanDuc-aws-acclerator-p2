# Module - S3 Private Bucket

## Purpose

Creates a private S3 bucket with:

* Public access blocked.
* Server-side encryption using AES256.
* Standard tags from the caller.

## Usage

```hcl
module "app_bucket" {
  source = "../../modules/s3_private_bucket"

  bucket_name = "unique-demo-bucket-name"
  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
```

## Inputs

| Name | Description | Type | Required |
| ---- | ----------- | ---- | -------- |
| `bucket_name` | Globally unique S3 bucket name | `string` | yes |
| `tags` | Tags applied to module resources | `map(string)` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| `bucket_name` | S3 bucket name |
| `bucket_arn` | S3 bucket ARN |

# 04 - HCL Syntax

## HCL (HashiCorp Configuration Language)

HCL là ngôn ngữ để viết Terraform.

### Common HCL building blocks:

- Blocks: khối cấu hình hình
- Arguments: thuộc tính bên trong block.
- Expressions
- Strings
- Numbers
- Booleans
- Lists
- Maps
- Variables: biến đầu vào
- Outputs: giá trị xuất ra sau khi apply.

## Blocks and Arguments

A block has a type, labels, and a body.

```hcl
resource "aws_instance" "web" {
  ami           = "ami-xxx"
  instance_type = "t3.micro"
}
```

Block type: `resource`

Labels: `aws_instance`, `web`

Arguments: `ami`, `instance_type`

## Values

```hcl
name        = "demo"
instance_count = 1
enabled     = true
ports       = [22, 80, 443]
tags = {
  Environment = "dev"
  Owner       = "cloud-team"
}
```

## Variables

Variables make code reusable.

```hcl
variable "aws_region" {
  description = "AWS region for the lab"
  type        = string
  default     = "us-east-1"
}
```

Use a variable:

```hcl
provider "aws" {
  region = var.aws_region
}
```

## Outputs

Outputs show useful values after apply.

```hcl
output "instance_id" {
  value = aws_instance.web.id
}
```

## AWS Examples

Security group ingress rule:

```hcl
ingress {
  description = "Allow SSH"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["203.0.113.10/32"]
}
```

Tags:

```hcl
tags = {
  Name        = "terraform-demo"
  Environment = "training"
  ManagedBy   = "terraform"
}
```

## Diagram

```text
HCL file
  |
  +-- terraform block: required versions and providers
  +-- provider block: AWS configuration
  +-- variable blocks: input values
  +-- resource blocks: infrastructure objects
  +-- output blocks: useful result values
```

## Real-World Usage

- `versions.tf` for Terraform and provider versions.
- `providers.tf` for provider configuration.
- `variables.tf` for inputs.
- `main.tf` for resources.
- `outputs.tf` for outputs.

For this beginner lab, everything is kept in `main.tf` so the full flow is easy to read.

## Common Mistakes

- Quên dấu " cho string.
- Hardcode secret trong file .tf.
- Dùng 0.0.0.0/0 cho SSH.
- Dùng sai AMI theo region.

## Summary

```text
Block = khối
Argument = thuộc tính
Variable = input
Output = output
Resource = hạ tầng
# Input variables for reusable lab configuration.
variable "aws_region" {
  description = "AWS region for the lab."
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Name prefix used for lab resources."
  type        = string
  default     = "w8-d1-terraform"
}

variable "instance_type" {
  description = "EC2 instance type for the lab."
  type        = string
  default     = "t3.micro"
}

variable "allowed_ssh_cidr" {
  description = "CIDR range allowed to SSH to the instance. Use your public IP with /32."
  type        = string
  default     = "0.0.0.0/0"
}

variable "project_name" {
  description = "Name prefix for lab resources."
  type        = string
  default     = "k8s-minikube-alb"
}

variable "aws_region" {
  description = "AWS region for this lab."
  type        = string
  default     = "ap-southeast-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the lab VPC."
  type        = string
  default     = "10.40.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the two public subnets."
  type        = list(string)
  default     = ["10.40.1.0/24", "10.40.2.0/24"]

  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "Exactly two public subnet CIDRs are required for the ALB."
  }
}

variable "instance_type" {
  description = "EC2 instance type for the Minikube node."
  type        = string
  default     = "c7i-flex.large"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB."
  type        = number
  default     = 20
}

variable "app_node_port" {
  description = "Fixed Kubernetes NodePort exposed from EC2 to ALB."
  type        = number
  default     = 30080
}

locals {
  common_tags = {
    Project   = var.project_name
    ManagedBy = "terraform"
    Lab       = "k8s-on-aws-terraform-1-click"
  }
}

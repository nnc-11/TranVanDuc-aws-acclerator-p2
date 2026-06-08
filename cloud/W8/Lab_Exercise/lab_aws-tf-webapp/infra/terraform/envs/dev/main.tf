data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs      = slice(data.aws_availability_zones.available.names, 0, 2)
  web_html = file("${path.root}/../../../../app/web/index.html")
}

module "vpc" {
  source = "../../modules/vpc"

  name                 = var.project_name
  vpc_cidr             = var.vpc_cidr
  availability_zones   = local.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "s3" {
  source = "../../modules/s3"

  bucket_name = var.static_bucket_name
}

module "ec2" {
  source = "../../modules/ec2"

  name             = var.project_name
  vpc_id           = module.vpc.vpc_id
  subnet_id        = module.vpc.public_subnet_ids[0]
  key_name         = var.key_name
  instance_type    = var.instance_type
  web_html         = local.web_html
  static_bucket    = module.s3.bucket_name
  allowed_ssh_cidr = var.allowed_ssh_cidr
}

module "rds" {
  source = "../../modules/rds"

  name                 = var.project_name
  vpc_id               = module.vpc.vpc_id
  subnet_ids           = module.vpc.private_subnet_ids
  allowed_sg_id        = module.ec2.security_group_id
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
  db_instance_class    = var.db_instance_class
  allocated_storage_gb = var.db_allocated_storage_gb
  deletion_protection  = var.db_deletion_protection
}

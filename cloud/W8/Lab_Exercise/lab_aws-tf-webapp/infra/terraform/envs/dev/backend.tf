terraform {
  backend "s3" {
    bucket         = "duc-aws-tf-webapp-dev-tfstate"
    key            = "dev/aws-tf-webapp/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "duc-aws-tf-webapp-dev-tflock"
    encrypt        = true
  }
}

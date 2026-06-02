# Answers

## Multiple-Choice Answer Key

1. B - IaC means infrastructure is defined in code files.
2. B - `terraform init` downloads providers and prepares the working directory.
3. B - The provider communicates with AWS APIs.
4. A - State maps Terraform resources to real infrastructure.
5. B - `terraform plan` previews changes.
6. A - `terraform apply` makes the changes.
7. B - Terraform commonly uses `.tf` files.
8. A - `web` is Terraform's local name for that resource.
9. C - `terraform.tfstate` may contain sensitive information and environment details.
10. A - `terraform fmt` formats Terraform files.
11. A - `terraform validate` checks configuration validity.
12. B - The AWS provider block configures region and provider settings.
13. A - A data source queries existing information. ( data source dùng để đọc thông tin đã tồn tại).
14. B - `0.0.0.0/0` allows connection attempts from anywhere.
15. A - Outputs display useful values after apply.
16. A - `terraform destroy` removes managed resources.
17. B - Remote state helps teams coordinate shared infrastructure.
18. A - HCL means HashiCorp Configuration Language.
19. A - Terraform builds a dependency graph.
20. B - Destroy resources and confirm cleanup to avoid unwanted cost.

## Short-Answer Guidance

1. Infrastructure is defined and managed using code instead (thay vì) of manually creating resources in AWS console.

2. 
- `terraform plan` shows what changes Terraform will make.
- `terraform apply` creates, updates, or deletes resources based on the execution plan.

3. Terraform state lưu mapping giữa Terraform configuration và hạ tầng thực tế, bao gồm resource IDs và attributes. Nhờ đó Terraform biết resource nào cần create, update hoặc delete.

4. 
- human error
- khó tracking/review vì không có version control như Git

5. 
- Secrets và state files có thể chứa credentials, resource IDs, IP addresses, sensitive outputs và các thông tin vận hành. 
- **security và compliance risks**

# 01 - Tổng quan Infrastructure as Code

## Infrastructure as Code (IaC) là gì ?

Infrastructure as Code (IaC) = Viết code để quản lý hạ tầng thay vì bấm tay trên Console.

## Why use it?

**Giải quyết vấn đề:**

- Thao tác thủ công dễ sai sót.
- Khó tái tạo môi trường.
- Khó review thay đổi.
- Khó audit lịch sử.
- Dễ xảy ra configuration drift.

**Benefits:**

- Consistency (tính nhất quán)
- Repeatability (khả năng lặp lại)
- Version Control
- Auditability (khả năng kiểm toán)
- Automation

## Đối tượng ?

- DevOps Engineer; Cloud Engineer; Platform Engineer; SRE ;Infrastructure Engineer; ...

## Where is it applied?

|**Các môi trường:**|**Các nền tảng**|
|:------------------|:---------------|
|Development<br>Staging ( kiểm thử cuối, gần giống Production trước khi lên Production)<br> Production | AWS <br> Azure <br> GCP <br> Kubernetes <br> VMware|

## When use it?
- Thực tế: hầu hết mọi môi trường cloud production hiện nay đều dùng IaC.


# How does Terraform work?

Developer -> Git Repository -> Terraform Code -> Terraform plan -> Review -> Terraform apply -> AWS Resource

* **terraform init**: tải provider
* **terraform plan**: xem sắp làm gì
* **terraform apply**: thực thi
* **terraform state**: lưu trạng thái vào `terraform.tfstate` (Terraform cần dựa vào file này để biết cần tạo hay sửa)
* **terraform destroy**: xóa các resource đã được Terraform quản lý

**Mô tả:** Terraform đọc code, so sánh với state hiện tại, tính toán thanh đổi, Goi AWS API để tạo/ sửa/ xóa resouce 


## Những lỗi thường gặp

- sửa console thay vì sửa Code
- quản lý Secrets kém (Secrets không được public.Check kỹ đàng hoàng, không lưu souce code or Git repository): ngon-thơm hí hí
- Apply mà không review

## Vụ xử Secrets
Lab:
- TF_VAR_*
- terraform.tfvars (không commit)
- .gitignore

Production:
- Secret Manager (AWS Secrets Manager, Vault)
- CI/CD Secret Store
- Secret Rotation
- Least Privilege IAM
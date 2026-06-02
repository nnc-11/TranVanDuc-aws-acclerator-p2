# 02 - Terraform Architecture

## Mục đích:

Terraform đọc cấu hình, so sánh với trạng thái hiện tại và thực hiện thay đổi trên hạ tầng thông qua Provider API.

Core components:

- Terraform CLI: Công cụ thực thi (locally or CI/CD).
- Configuration: `.tf` files written in HCL.(khai báo hạ tầng).
- Provider: plugin giúp giao tiếp với AWS/Azure/GCP
- Resource: Đối tượng được quản lý.
- State: lưu trạng thái hạ tầng
- Dependency graph: Terraform's internal map of resource relationships. (xác định thứ tự triển khai).

## Diagram

```text
main.tf
  |
  v
Terraform CLI
  |
  +--> AWS provider plugin
  |        |
  |        v
  |     AWS APIs
  |        |
  |        v
  |     EC2, VPC, SG, IAM
  |
  v
terraform.tfstate
```

Dependency example:

```text
aws_security_group.web
        |
        v
aws_instance.web
```

The EC2 instance depends on the security group because it references the security group ID.

## Real-World Usage

- Small project: lưu state local (`terraform.tfstate`) trên máy cá nhân.
- Team project: lưu state remote (thường trên S3) để mọi người dùng chung một state.
- Dùng DynamoDB để lock state khi chạy `terraform apply`. (kiểu A đang sửa, B phải chờ)
- Locking giúp tránh 2 người sửa hạ tầng cùng lúc làm hỏng hoặc ghi đè state.

Production Terraform usually includes:

- Remote backend for state.
- Separate environments. (tách biệt môi trường)
- Least-privilege AWS IAM roles.
- CI/CD Pipeline
- Policy checks.
- Provider Version Pinning

## Common Mistakes (lỗi thường gặp)

- Deleting or editing `terraform.tfstate` manually.
- không share file state qua chat or email.
- Máy mô không dùng "remote sate" không cho chạy.
- Not pinning provider versions. (cần version nếu thay đổi ngoài ý muốn)
- state có thể chứa thông tin nhảy cảm, cần bảo vệ
- Renaming resources in code khiến cho terraform xóa resource cũ và tạo resource mới.

## Lưu Ý
**Dependency graph**: phụ thuộc quan hệ
- VD1: Xây tường -> lắp cửa => Resource A dùng thông tin của Resource B ⇒ B tạo trước
- VD2: sơn phòng; trồng cây ngoài cổng => Resource A không dùng gì từ Resource B ⇒ Terraform tạo song song.
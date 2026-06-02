# 03 - Terraform Workflow

## Terraform Workflow

1. Viết file `.tf`
2. `terraform init` - tải provider
3. `terraform fmt` - format code
4. `terraform validate` - kiểm tra syntax
5. `terraform plan` - xem Terraform sắp làm gì
6. `terraform apply` - thực thi thay đổi
7. `terraform output` - xem output
8. `terraform destroy` - xóa hạ tầng

9. `terraform state list` - Hiển thị danh sách các resource đang được Terraform quản lý trong state.


## Real-World Usage

In production, `terraform plan` is commonly run in CI for pull requests. Engineers review the planned changes before merge. `terraform apply` may require approval and should run with a controlled IAM role.

## quy tắc

- Luôn đọc `terraform plan` trước khi `apply`.
- `validate` chỉ kiểm tra cấu hình, không kiểm tra quyền AWS.
- Production thường chạy `plan` và `apply` qua CI/CD.
- State nên lưu remote để làm việc nhóm.

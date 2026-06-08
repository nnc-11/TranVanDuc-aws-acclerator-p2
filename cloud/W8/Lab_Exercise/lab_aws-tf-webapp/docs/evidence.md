# Evidence

## 1. Terraform apply

- `terraform output` 
- `terraform state list` 

![Terraform output](picture/terraform_output_redacted.png)

![Terraform state list](picture/terraform_state_list.png)

## 2. Web EC2

- Trình duyệt truy cập được web demo qua EC2 public IP/DNS.

![Web EC2](picture/web-EC2_redacted.png)

## 3. RDS private

- RDS `Publicly accessible = No`.
- Security Group RDS chỉ cho phép port `3306` từ Security Group của EC2.

![RDS private](picture/RDS_private_redacted.png)

## 4. S3 và state backend

- S3 static bucket tồn tại.
- S3 backend có file `dev/aws-tf-webapp/terraform.tfstate`.
- DynamoDB lock table tồn tại.

![S3 and state backend](picture/S3_and_State_backend_redacted.png)

## Destroy lab

- Destroy dev resources.
- Destroy bootstrap resources.

## Security note

- Không commit `terraform.tfvars`, `terraform.tfstate`, `.terraform/`, access key, secret key, DB password.
- Evidence sử dụng ảnh đã redact một phần thông tin định danh để tránh công khai tài nguyên AWS trên GitHub. Nội dung kiểm tra chính vẫn được giữ lại: resource tồn tại, RDS không public, Security Group chỉ mở port cần thiết, và backend state hoạt động.

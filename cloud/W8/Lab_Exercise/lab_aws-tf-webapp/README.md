
# Lab: Terraform AWS Web App Infrastructure

## Đề bài

lab: Deploy a Web App on AWS <br>
Architecture: VPC + public/Private Subnets + EC2 + RDS + S3 <br>
Step 1: Create VPC module with public & private subnets <br>
Step 2: Deploy EC2 instance in public subnet (web server) <br>
Step 3: Deploy RDS MySQL in private subnet<br>
Step 4: Create S3 bucket for static asset<br>
Step 5: Configure security groups to allow only required traffic <br>
* All state stored in S3 backend with DynamoDB locking<br>
Deadline: 23h59 08/06/2026<br>

## Mục tiêu

- Thực hành Terraform để tạo hạ tầng AWS.
- Quản lý Terraform state bằng S3 backend.
- Dùng DynamoDB để tránh nhiều người/process sửa state cùng lúc.
- Kiểm tra các tài nguyên sau khi `apply`.

## Kiến trúc

- User truy cập web qua public IP hoặc DNS của EC2.
- EC2 web server nằm trong public subnet và chạy trang web demo.
- RDS MySQL nằm trong private subnet, không public ra Internet.
- EC2 kết nối tới RDS qua private network trên port 3306.
- Có 2 nhóm S3 trong lab:
  - S3 backend bucket lưu Terraform state, được tạo ở bước `bootstrap`.
  - S3 static asset bucket, được tạo trong môi trường `dev`.
- Security Group chỉ cho phép traffic cần thiết: HTTP public vào EC2, SSH chỉ từ IP cá nhân, MySQL chỉ từ EC2 sang RDS.

## Cấu trúc chính

```text
lab_aws-tf-webapp/
├── README.md
├── docs/evidence.md       # evidence và ghi chú kiểm tra
├── app/web/               # trang web demo chạy trên EC2
├── infra/
│   └── terraform/
│       ├── bootstrap/     # tạo S3 backend và DynamoDB lock
│       ├── envs/dev/      # cấu hình triển khai môi trường dev
│       └── modules/       # module VPC, EC2, RDS, S3
└── .gitignore
```

## Yêu cầu chuẩn bị

- AWS account
- AWS CLI
- Terraform
- EC2 key pair
- Public IP cá nhân
- DB password

## Chạy Terraform

Tạo backend trước bằng Terraform bootstrap:

```bash
cd infra/terraform/bootstrap
terraform init
terraform validate
terraform plan
terraform apply
```

Sau khi bootstrap tạo xong S3 bucket và DynamoDB table.

Chạy Terraform cho môi trường `dev`:

```bash
cd infra/terraform/envs/dev
terraform init
terraform validate
terraform plan
terraform apply
```

## Evidence và kiểm tra sản phẩm

Xem checklist và ảnh bằng chứng tại [docs/evidence.md](docs/evidence.md).

## Flow hoạt động

Flow chính của lab:

1. Chạy `infra/terraform/bootstrap` để tạo S3 backend bucket và DynamoDB lock table.
2. Chạy `infra/terraform/envs/dev` để tạo VPC, EC2, RDS và S3 static bucket.
3. User truy cập web qua EC2 public IP/DNS.
4. EC2 kết nối tới RDS MySQL trong private subnet qua port `3306`.
5. Terraform state của môi trường `dev` được lưu trong S3 backend.

```text
User -> EC2 public web server -> RDS MySQL private
Terraform state -> S3 backend + DynamoDB lock
```

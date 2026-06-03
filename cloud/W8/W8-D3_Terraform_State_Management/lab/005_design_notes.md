# Design Notes

File này ghi chú thiết kế chính của lab Terraform State Management. và là tài liệu bổ sung thông tin cho bài lab.

## 1. Lab Architecture

Lab chạy Terraform từ local machine và deploy resource lên AWS region `ap-southeast-1`.

Luồng chính:

```text
Local machine
      |
      v
bootstrap-backend
      |
      +--> S3 state bucket
      +--> DynamoDB lock table

Local machine
      |
      v
envs/dev
      |
      +--> dùng S3 remote backend
      +--> gọi module s3_private_bucket
      +--> tạo S3 app bucket demo
```

Lab có 2 S3 bucket:

* State bucket: lưu Terraform state remote.
* App bucket: resource demo được Terraform quản lý bằng remote state.

## 2. Code Structure

```text
lab/002_code/
  bootstrap-backend/
    main.tf
    variables.tf
    outputs.tf
    versions.tf
    terraform.tfvars.example
  envs/
    dev/
      backend.tf
      backend.hcl.example
      main.tf
      variables.tf
      outputs.tf
      versions.tf
      terraform.tfvars.example
  modules/
    s3_private_bucket/
      main.tf
      variables.tf
      outputs.tf
      README.md
```

Ý nghĩa:

* `bootstrap-backend`: tạo S3 state bucket và DynamoDB lock table.
* `envs/dev`: root module của môi trường dev, dùng remote backend.
* `modules/s3_private_bucket`: module tạo S3 bucket private.

## 3. Backend Design

`envs/dev/backend.tf` chỉ khai báo backend rỗng:

```hcl
terraform {
  backend "s3" {}
}
```

Giá trị thật nằm trong file local `backend.hcl`:

```hcl
bucket         = "<your-state-bucket-name>"
key            = "w8/d3/dev/terraform.tfstate"
region         = "ap-southeast-1"
dynamodb_table = "terraform-state-locks-dev"
encrypt        = true
```

Lý do dùng file local:

* Không commit tên backend thật vào Git.
* Dễ thay đổi backend theo môi trường.
* Giữ `backend.tf` gọn và tái sử dụng được.

Lưu ý: `dynamodb_table` hiện bị Terraform cảnh báo deprecated, nhưng vẫn giữ trong lab vì yêu cầu bài cần chứng minh DynamoDB lock table có partition key `LockID`.

## 4. Module Design

Module `s3_private_bucket` tạo S3 bucket theo chuẩn tối thiểu:

* Tạo bucket.
* Block public access.
* Bật server-side encryption.
* Nhận tags từ root module.
* Output bucket name và ARN.

Root module `envs/dev` gọi module:

```hcl
module "app_bucket" {
  source = "../../modules/s3_private_bucket"

  bucket_name = var.bucket_name
  tags        = local.common_tags
}
```

Lý do tách module:

* Giảm lặp code.
* Dễ tái sử dụng cho môi trường khác.
* Giữ chuẩn private/encryption thống nhất cho S3 bucket.

## 5. Naming Convention

S3 bucket name phải unique toàn cầu.

Format dùng cho lab:

```text
<username>-<project>-<purpose>-<env>-<region>
```

Ví dụ:

```text
<your-name>-w8-d3-tfstate-dev-ap-southeast-1
<your-name>-w8-d3-app-dev-ap-southeast-1
```

Tên thật nằm trong file local `terraform.tfvars` và `backend.hcl`, không commit lên Git.

## 6. Best Practices

Các điểm chính trong lab:

* Bootstrap backend trước, sau đó mới deploy `envs/dev`.
* State bucket bật versioning, encryption và block public access.
* DynamoDB lock table dùng partition key `LockID`.
* Mỗi environment dùng state key riêng, ví dụ `w8/d3/dev/terraform.tfstate`.
* Không commit `.terraform/`, `terraform.tfstate*`, `terraform.tfvars`, `backend.hcl`.
* Không mở hoặc chụp nội dung file `terraform.tfstate` vì state có thể chứa thông tin nhạy cảm.
* Cleanup theo thứ tự: destroy `envs/dev` trước, backend sau.


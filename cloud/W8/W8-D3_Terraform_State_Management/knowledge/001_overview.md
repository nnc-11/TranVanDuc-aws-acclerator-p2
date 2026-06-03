# 001 - Overview for Terraform State Management Lab

Kiến thức nền tảng trước khi làm lab.

Cũ: S3 lưu state + DynamoDB lock. 
Mới: S3 lưu state + S3 lock file (.tflock). (use_lockfile = true): (hiện chưa đề cập cho phần W8-D3 - đọc thêm)

## 1. Terraform State

Terraform state là dữ liệu Terraform dùng để mapping giữa code `.tf` và hạ tầng thật trên cloud.

State giúp Terraform biết:

* Resource nào đã được tạo.
* Resource ID thật trên AWS là gì.
* Thuộc tính hiện tại của resource.
* Resource nào cần create, update, replace hoặc delete khi chạy `terraform plan`.

Security note: Không nên commit `terraform.tfstate` vào Git vì state có thể chứa thông tin nhạy cảm như resource ID, endpoint, output, metadata hoặc secret.

## 2. Local State vs Remote State

Local state là state nằm trên máy cá nhân, thường là file `terraform.tfstate`. (phục vụ cho làm việc cá nhân).

Remote state là state nằm ở backend dùng chung, ví dụ S3, Terraform Cloud, GCS hoặc Azure Storage.

Khi làm việc nhóm, remote state tốt hơn vì:

* Team và CI/CD dùng chung một nguồn state.
* Giảm rủi ro mất state do máy cá nhân.
* Có thể bật versioning và backup.
* Có thể kết hợp cơ chế lock để tránh chạy đồng thời. 

## 3. S3 Backend

S3 backend là cách lưu Terraform state trên Amazon S3.

Backend S3 thường cần:

* Bucket name unique.
* State key riêng cho từng project/environment.
* Region đúng.
* Encryption enabled.
* Versioning enabled.
* Public access block.
* IAM policy giới hạn quyền truy cập.

Ví dụ:

```hcl
terraform {
  backend "s3" {}
}
```

Giá trị backend thật nên truyền qua file local `backend.hcl` để tránh commit tên bucket thật:

```hcl
bucket         = "replace-with-your-terraform-state-bucket"
key            = "w8/d3/dev/terraform.tfstate"
region         = "ap-southeast-1"
dynamodb_table = "terraform-state-locks-dev"
encrypt        = true
```

Khi init thật:

```bash
terraform init -backend-config=backend.hcl
```

## 4. DynamoDB Lock

DynamoDB lock dùng để tránh nhiều người hoặc nhiều pipeline cùng ghi vào một state tại cùng thời điểm.

Lock table thường có:

* Partition key: `LockID`
* Type: `String`
* Billing mode: `PAY_PER_REQUEST` cho lab/dev

Lưu ý: Terraform S3 backend hiện có native lock file qua `use_lockfile`. `dynamodb_table` là cơ chế legacy/deprecated trong tài liệu mới, nhưng vẫn phổ biến trong nhiều hệ thống đang vận hành.

## 5. Terraform Module

Module là thư mục Terraform đóng gói một nhóm resource để tái sử dụng.

Trong lab này:

* `envs/dev` là root module.
* `modules/s3_private_bucket` là child module.
* Root module gọi child module để tạo S3 bucket private mẫu.

Module tốt nên có:

* Input rõ trong `variables.tf`.
* Output rõ trong `outputs.tf`.
* Default an toàn.
* Không hard-code account, region, secret.
* Không output dữ liệu nhạy cảm.

## 6. Best Practices Cần Nhớ Trong Lab

* Mỗi environment dùng state key riêng.
* Không commit `.terraform/`, `terraform.tfstate*`, credentials hoặc secret.
* Chạy `terraform fmt` trước khi nộp code.
* Chạy `terraform validate` sau khi init.
* Review `terraform plan` trước khi apply.
* Không dùng chung state cho nhiều workload không liên quan.
* Dùng tag chuẩn để trace ownership.
* Dùng IAM least privilege cho backend.

## 7. ADR

* Context : Team cần chia sẻ Terraform state cho môi trường dev.
* Decision: Sử dụng Amazon S3 làm remote backend để lưu Terraform state và DynamoDB để quản lý state locking. tránh ghi đồng thời.
* Rationale:  S3 cung cấp lưu trữ tập trung, bền vững và hỗ trợ versioning. State lock ngăn nhiều tiến trình cùng ghi vào một state tại cùng thời điểm.
* Consequences: Team có state tập trung và dễ khôi phục hơn, nhưng cần bootstrap backend và quản lý IAM cẩn thận. Phát sinh chi phí và yêu cầu quản lý S3/DynamoDB.

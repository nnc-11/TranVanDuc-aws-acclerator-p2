# Apply Runbook

Runbook này hướng dẫn deploy thật lab Terraform State Management trên AWS region `ap-southeast-1`.

## 1. Kiểm Tra Trước Khi Apply

Kiểm tra nhanh:

* AWS credentials đã sẵn sàng.
* Region dùng cho lab là `ap-southeast-1`.
* Bucket name là unique toàn cầu.
* Không commit `terraform.tfvars`, `backend.hcl`, `.terraform/`, hoặc `terraform.tfstate*`.

File local đã dùng cho lab này:

* `lab/002_code/bootstrap-backend/terraform.tfvars`
* `lab/002_code/envs/dev/backend.hcl`
* `lab/002_code/envs/dev/terraform.tfvars`

## 2. Bootstrap Backend

Vào thư mục bootstrap:

```bash
cd lab/002_code/bootstrap-backend
```

Chạy Terraform:

```bash
terraform init
terraform plan
terraform apply
```
Kiểm tra output:

```bash
terraform output
```

Kết quả mong đợi:

```text
state_bucket_name = "noir11-w8-XXXXXXXXXX"
lock_table_name   = "terraform-XXXXXXXXXX"
```

## 3. Deploy Dev Environment

Vào thư mục dev:

```bash
cd ../envs/dev
```

Init bằng remote backend:

```bash
terraform init -backend-config=backend.hcl
```

Deploy app bucket:

```bash
terraform plan
terraform apply
```

```text
phần này chú thích: 001 phần đầu: triển khai cũ và mới.(lab này triển khai theo phương pháp cũ).
│ Warning: Deprecated Parameter
│ 
│ The parameter "dynamodb_table" is deprecated. Use parameter
│ "use_lockfile" instead.
```

Kiểm tra output:

```bash
terraform output
```

Kiểm tra resource đang được quản lý trong state:

```bash
terraform state list
```

Kết quả mong đợi có:

```text
module.app_bucket.aws_s3_bucket.this
module.app_bucket.aws_s3_bucket_public_access_block.this
module.app_bucket.aws_s3_bucket_server_side_encryption_configuration.this
```

## 4. Evidence Cần Chụp

Điền evidence vào `lab/003_evidence.md`.

Evidence chính:

* `terraform state list`.
* AWS Console S3 state bucket có object `w8/d3/dev/terraform.tfstate`.
* AWS Console state bucket bật versioning/encryption/block public access.
* AWS Console DynamoDB table có partition key `LockID`.
* AWS Console app bucket private/block public access.

Lưu ảnh trong:

```text
lab/picture/
```

Tên ảnh theo template:

```text
terraform-state-list.png
s3-state-object.png
s3-state-bucket-settings.png
dynamodb-lock-table.png
s3-app-bucket-private.png
```

## 5. Cleanup

Destroy dev resource trước:

```bash
cd lab/002_code/envs/dev
terraform destroy
```

Sau đó mới cân nhắc destroy backend:

```bash
cd ../../bootstrap-backend
terraform destroy
```

Không destroy backend nếu vẫn cần giữ state trong S3.

## 6. WSL `/mnt/g` Plugin Cache Fix

Nếu Terraform init lỗi provider hoặc chạy chậm trên `/mnt/g`, dùng plugin cache trong `/tmp`:

```bash
mkdir -p /tmp/tf-plugin-cache
TF_PLUGIN_CACHE_DIR=/tmp/tf-plugin-cache terraform init
```

Với thư mục `envs/dev`, thêm backend config:

```bash
TF_PLUGIN_CACHE_DIR=/tmp/tf-plugin-cache terraform init -backend-config=backend.hcl
```

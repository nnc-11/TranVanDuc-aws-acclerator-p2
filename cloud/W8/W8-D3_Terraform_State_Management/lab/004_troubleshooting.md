# Troubleshooting

## 1. Terraform Init Chậm Hoặc Lỗi Provider Trên WSL2 Mount

**Dấu hiệu:**

```text
Failed to load plugin schemas
Failed to read any lines from plugin's stdout
```

Hoặc `terraform init` đứng lâu ở:

```text
Installing hashicorp/aws ...
```

**Nguyên nhân:** Project nằm trên ổ Windows mount qua WSL2, ví dụ `/mnt/g`. Provider cache trong `.terraform` có thể chậm hoặc lỗi.

**Cách fix:**

```bash
mkdir -p /tmp/tf-plugin-cache
TF_PLUGIN_CACHE_DIR=/tmp/tf-plugin-cache terraform init
```

Với thư mục `envs/dev`:

```bash
TF_PLUGIN_CACHE_DIR=/tmp/tf-plugin-cache terraform init -backend-config=backend.hcl
```

Nếu vẫn lỗi:

```bash
rm -rf .terraform
TF_PLUGIN_CACHE_DIR=/tmp/tf-plugin-cache terraform init
```

## 2. Apply Cancelled

**Dấu hiệu:**

```text
Apply cancelled.
```

**Nguyên nhân:** Terraform chỉ chấp nhận đúng chữ `yes` ở prompt xác nhận.

**Cách fix:**

Chạy lại:

```bash
TF_PLUGIN_CACHE_DIR=/tmp/tf-plugin-cache terraform apply
```

Khi thấy:

```text
Enter a value:
```

Nhập đúng:

```text
yes
```

## 3. Warning `dynamodb_table` Deprecated

**Dấu hiệu:**

```text
Warning: Deprecated Parameter
The parameter "dynamodb_table" is deprecated. Use parameter "use_lockfile" instead.
```

**Nguyên nhân:** Terraform S3 backend hiện khuyến nghị dùng native lock file. DynamoDB lock là cơ chế cũ.

**Cách xử lý:** Với lab này giữ nguyên `dynamodb_table`, vì yêu cầu bài lab cần chứng minh DynamoDB lock table có partition key `LockID`.

## 4. Destroy Backend Không Xóa Được State Bucket

**Dấu hiệu:** Destroy backend fail vì S3 state bucket chưa rỗng.

**Nguyên nhân:** State bucket bật versioning, nên object `w8/d3/dev/terraform.tfstate` có thể còn version cũ.

**Cách fix:**

Kiểm tra object versions:

```bash
aws s3api list-object-versions \
  --bucket <your-state-bucket-name> \
  --region ap-southeast-1
```

Xóa các object version còn lại, sau đó destroy backend lại:

```bash
TF_PLUGIN_CACHE_DIR=/tmp/tf-plugin-cache terraform destroy
```

## 5. S3 Bucket Name Bị Trùng

**Dấu hiệu:** Terraform báo bucket already exists hoặc không tạo được S3 bucket.

**Nguyên nhân:** S3 bucket name phải unique toàn cầu.

**Cách fix:** Đổi bucket name theo format:

```text
<username>-<project>-<purpose>-<env>-<region>
```

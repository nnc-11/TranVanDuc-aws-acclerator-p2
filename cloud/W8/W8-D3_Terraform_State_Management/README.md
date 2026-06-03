# Terraform Part 2 - State Management, Modules, Best Practices, ADR

> Self-study Terraform - Day 03  
> Focus: remote state with S3, state locking with DynamoDB, reusable modules, and cleanup after apply.

## Mục Tiêu

Lab này dùng Terraform chạy từ local machine để deploy resource thật lên AWS region `ap-southeast-1`.

Sau khi hoàn thành, cần hiểu được:

* Vì sao cần Terraform remote state.
* Cách tạo S3 bucket để lưu state.
* Cách dùng DynamoDB để lock state.
* Cách deploy môi trường `dev` bằng remote backend.
* Cách dùng module local để tạo S3 bucket private.
* Cách chụp evidence và cleanup resource sau lab.

## Thứ Tự Làm Lab

Đọc và làm theo thứ tự:

1. kiến thức chính: `knowledge/001_overview.md`
2. yêu cầu bài lab: `lab/001_requirements.md`
3. thiết kế: `lab/005_design_notes.md`
4. code Terraform: `lab/002_code/`
5. Apply theo runbook: `lab/006_apply_runbook.md`
6. evidence: `lab/003_evidence.md`
7. Nếu gặp lỗi, xem: `lab/004_troubleshooting.md`

## Luồng Deploy

Apply theo đúng thứ tự:

```text
bootstrap-backend -> envs/dev
```

Ý nghĩa:

* `bootstrap-backend`: tạo S3 state bucket và DynamoDB lock table.
* `envs/dev`: dùng backend đã tạo để deploy S3 app bucket demo.

Không chạy `envs/dev` trước khi bootstrap backend xong.

## Cleanup

Cleanup theo đúng thứ tự:

```text
envs/dev -> bootstrap-backend
```

Không destroy backend trước khi destroy `envs/dev`.

Lưu ý: state bucket có versioning, nên có thể còn object versions của `terraform.tfstate`. Nếu bucket chưa xóa được, xem hướng dẫn trong `lab/004_troubleshooting.md`.

## security note

Không commit các file local hoặc state:

* `.terraform/`
* `.terraform.lock.hcl`
* `terraform.tfstate`
* `terraform.tfstate.*`
* `terraform.tfvars`
* `backend.hcl`

Không mở hoặc chụp nội dung file `terraform.tfstate` vì state có thể chứa thông tin nhạy cảm.

Terraform S3 backend hiện cảnh báo `dynamodb_table` deprecated. Lab này vẫn giữ DynamoDB locking vì yêu cầu cần chứng minh lock table có partition key `LockID`.

## References

* Terraform S3 backend: https://developer.hashicorp.com/terraform/language/backend/s3
* Terraform modules: https://developer.hashicorp.com/terraform/language/modules
* Terraform style guide: https://developer.hashicorp.com/terraform/language/style

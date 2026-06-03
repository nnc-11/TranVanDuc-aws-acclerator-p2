# Assessment Answer Key

## Multiple Choice

1. B - State mapping Terraform configuration với hạ tầng thật.
2. B - State có thể chứa dữ liệu nhạy cảm và thông tin hạ tầng.
3. A - Remote backend phù hợp cho team và CI/CD.
4. B - S3 backend lưu Terraform state trên S3.
5. A - Lock tránh nhiều tiến trình ghi cùng state cùng lúc.
6. B - DynamoDB lock table dùng partition key `LockID`.
7. B - Versioning giúp khôi phục state version cũ khi cần.
8. B - Root module là thư mục Terraform nơi chạy lệnh Terraform.
9. A - Child module là module được gọi bởi module khác.
10. A - Module phù hợp khi cần tái sử dụng hoặc chuẩn hóa pattern.
11. A - `variables.tf` thường khai báo input.
12. C - Secret phải được quản lý bằng cơ chế phù hợp và không commit giá trị thật.
13. A - `terraform fmt` định dạng code.
14. A - ADR ghi lại quyết định kiến trúc và lý do.
15. A - ADR thường có Status, Context, Decision, Consequences.

## Short Answer Guidance

1. Local state không phù hợp khi làm việc nhóm vì state nằm trên máy cá nhân, dễ mất, khó chia sẻ, không có lock và có thể gây xung đột nếu nhiều người cùng thay đổi infrastructure.

2. S3 bucket lưu file `terraform.tfstate` tập trung, có thể bật versioning và encryption. DynamoDB table giữ lock record để tránh nhiều tiến trình Terraform cùng ghi vào một state.

3. Nguyên tắc bảo mật: không commit state, bật encryption cho S3 bucket, bật public access block, giới hạn IAM least privilege, tách state theo environment, không output secret, audit truy cập backend.

4. Module nên có input/output rõ ràng, type và validation hợp lý, default an toàn, không hard-code account/region, có tagging chuẩn, không output secret, chỉ gom các resource cùng một mục đích.

5. Ví dụ ADR:

- Môi trường dev được nhiều người thao tác và cần state chung để tránh lệch hạ tầng.
- Dùng S3 bucket để lưu Terraform state, bật encryption/versioning, và dùng locking theo tiêu chuẩn team.
- Team có state tập trung và dễ khôi phục hơn, nhưng cần bootstrap backend và quản lý IAM cho bucket state.


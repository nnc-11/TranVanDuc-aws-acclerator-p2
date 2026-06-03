# Assessment Questions

## Multiple Choice

1. Terraform state dùng để làm gì?
   A. Lưu source code Terraform  
   B. Mapping giữa Terraform configuration và hạ tầng thật  
   C. Thay thế AWS IAM  
   D. Tự động giảm chi phí AWS

2. Vì sao không nên commit `terraform.tfstate` vào Git?
   A. Vì Git không hỗ trợ file JSON  
   B. Vì state có thể chứa dữ liệu nhạy cảm và thông tin hạ tầng  
   C. Vì Terraform không đọc được state trong Git  
   D. Vì state chỉ dùng cho Kubernetes

3. Remote backend giúp ích nhất trong tình huống nào?
   A. Làm việc nhóm hoặc chạy Terraform qua CI/CD  
   B. Viết file Markdown  
   C. Cài AWS CLI  
   D. Tạo SSH key

4. S3 backend dùng để làm gì?
   A. Lưu Terraform provider binary  
   B. Lưu Terraform state trên S3  
   C. Build Docker image  
   D. Tạo VPC mặc định

5. DynamoDB lock giúp tránh vấn đề gì?
   A. Nhiều tiến trình Terraform ghi cùng một state cùng lúc  
   B. User quên chạy `terraform fmt`  
   C. AWS hết quota EC2  
   D. S3 bucket bị đặt sai tag

6. DynamoDB lock table cho Terraform S3 backend thường cần partition key nào?
   A. `StateID`  
   B. `LockID`  
   C. `TerraformKey`  
   D. `BackendID`

7. Tại sao nên bật versioning cho S3 state bucket?
   A. Để tăng tốc `terraform fmt`  
   B. Để có khả năng khôi phục state version cũ khi cần  
   C. Để tự động tạo module  
   D. Để tắt encryption

8. Root module là gì?
   A. Module được gọi từ registry  
   B. Thư mục Terraform nơi đang chạy lệnh Terraform  
   C. File `outputs.tf`  
   D. S3 bucket lưu state

9. Child module là gì?
   A. Module được gọi bởi một module khác  
   B. Một loại provider  
   C. File state backup  
   D. Lệnh thay thế `terraform init`

10. Khi nào nên tạo Terraform module?
    A. Khi có pattern hạ tầng cần tái sử dụng hoặc chuẩn hóa  
    B. Khi chỉ sửa một typo  
    C. Khi muốn bỏ qua state  
    D. Khi không dùng provider

11. File nào thường dùng để khai báo input của module?
    A. `variables.tf`  
    B. `state.tf`  
    C. `quiz.md`  
    D. `backend.lock`

12. Best practice nào đúng với Terraform variable nhạy cảm?
    A. Hard-code trực tiếp trong `main.tf`  
    B. Commit vào public repo để dễ chia sẻ  
    C. Dùng cơ chế secret phù hợp và tránh commit giá trị thật  
    D. Đặt trong output không sensitive

13. Lệnh nào dùng để định dạng code Terraform?
    A. `terraform fmt`  
    B. `terraform style`  
    C. `terraform clean`  
    D. `terraform backend`

14. ADR dùng để làm gì?
    A. Ghi lại quyết định kiến trúc và lý do của quyết định đó  
    B. Thay thế Terraform state  
    C. Tự động tạo AWS account  
    D. Xóa resource khi hết giờ lab

15. Một ADR tốt nên có phần nào?
    A. Status, Context, Decision, Consequences  
    B. Password, Access Key, Secret Token  
    C. Screenshot, AMI ID, Public IP  
    D. Only command history

## Short Answer

1. Giải thích vì sao local state không phù hợp khi nhiều người cùng làm Terraform.
2. Mô tả vai trò của S3 bucket và DynamoDB table trong remote state pattern.
3. Nêu ít nhất 3 nguyên tắc bảo mật khi quản lý Terraform state.
4. Khi thiết kế module Terraform, bạn sẽ cân nhắc những điểm nào để module dễ tái sử dụng?
5. Viết một ADR ngắn cho quyết định: "Dùng S3 backend để lưu Terraform state cho môi trường dev".

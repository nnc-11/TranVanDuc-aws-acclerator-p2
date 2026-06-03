# Lab 01 - Terraform Remote State, Locking, and Modules

## Requirements

Một team DevOps cần chuẩn hóa cách quản lý Terraform state cho môi trường `dev`. Team muốn state được lưu tập trung trên AWS S3, có cơ chế lock để tránh chạy đồng thời, và code hạ tầng được đóng gói bằng module để tái sử dụng.


Yêu cầu:

* Triển khai Terraform remote state trên AWS S3.
* Cấu hình state locking bằng DynamoDB.
* Tổ chức mã nguồn Terraform theo mô hình module tái sử dụng.
* Quản lý môi trường dev bằng Terraform remote backend.
* Kiểm chứng cơ chế lưu trữ và khóa state.

## Prerequisites Lab

Chuẩn bị trước:

* Terraform CLI 
* AWS CLI 
* AWS credentials 
* region AWS dùng cho lab, `ap-southeast-1`.
* Biết naming convention để đặt bucket name unique toàn cầu.  <username>-<project>-<purpose>-<env>-<region>
* Đã đọc phần kiến thức trong `knowledge/`.

## Cost Warning

Resource phát sinh chi phí:

  - S3 state bucket: storage, request, versioning.
  - DynamoDB lock table: read/write request.
  - S3 app bucket: storage, request.

Ước tính chi phí: rất thấp, thường dưới $1 nếu chỉ dùng lab ngắn hạn và cleanup sau khi làm xong.

## Success Criteria

Lab hoàn thành và đáp ứng các yêu cầu của mục: Requirements

## Evidence requirements.

* terraform state list
* AWS Console S3 state bucket có object w8/d3/dev/terraform.tfstate
* AWS Console state bucket bật versioning/encryption/block public access
* AWS Console DynamoDB table có partition key LockID
* AWS Console app bucket private/block public access

xem file kết quả evident: 003_evidence.md


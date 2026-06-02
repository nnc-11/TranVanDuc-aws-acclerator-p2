# Lab 01 - Deploy EC2 bằng Terraform

## Requirements

Một nhóm vận hành cần triển khai nhanh một EC2 instance trên AWS để phục vụ kiểm thử. Thay vì thao tác trực tiếp trên AWS Console, nhóm quyết định sử dụng Terraform để quản lý hạ tầng dưới dạng code.

Yêu cầu:

* Tạo EC2 instance bằng Terraform.
* Tạo Security Group cho phép SSH.
* Sử dụng Variables và Outputs.
* Hiểu cách Terraform quản lý State.
* Xóa toàn bộ tài nguyên sau khi hoàn thành.

---

## Objectives

Sau khi hoàn thành lab, bạn có thể:

* Cấu hình Terraform kết nối AWS.
* Triển khai EC2 instance.
* Tạo Security Group.
* Sử dụng Variables và Outputs.
* Kiểm tra Terraform State.
* Dọn dẹp tài nguyên bằng Terraform.

---

## Prerequisites

Căì đặt:

* Terraform 
* AWS CLI v2
* Git
* AWS Account
* AWS Credentials đã cấu hình trên máy local
* Một AWS Region (ví dụ: `ap-southeast-1`)

Kiến thức cơ bản:

* Terminal (Linux/macOS/WSL/PowerShell)
* Git cơ bản (clone, add, commit, push)
* Hiểu khái niệm cơ bản về AWS EC2 (Instance, Security Group)
* Terraform (Provider, Resource, Variable, Output, State, Terraform Workflow)

---
## Cost Warning

Lab sẽ tạo EC2 instance trên AWS.

Khuyến nghị:

* Sử dụng `t3.micro` (cost thấp, nằm trong free tier account)
* Luôn chạy `terraform destroy` sau khi hoàn thành

---

## Success Criteria

Lab hoàn thành khi:

- EC2 và Security Group được tạo bằng Terraform.
- Variables và Outputs được sử dụng.
- Terraform State được kiểm tra.
- Toàn bộ tài nguyên được xóa sau khi hoàn thành lab.

---
## Evidence

Lưu evidence đủ để chứng minh lab đã hoàn thành:

* Terraform apply thành công và có outputs.
* EC2 instance và Security Group được tạo trên AWS.
* Terraform State có quản lý các resource của lab.
* Terraform destroy thành công sau khi hoàn thành.

Không lưu AWS credentials, secret keys, Terraform state files, account ID, ARN, public IP hoặc thông tin cá nhân trong evidence.

**Note:**
- Variables là các giá trị đầu vào giúp cấu hình Terraform linh hoạt và tái sử dụng được.
- Outputs là các giá trị đầu ra được Terraform hiển thị sau khi tạo hoặc cập nhật resource.

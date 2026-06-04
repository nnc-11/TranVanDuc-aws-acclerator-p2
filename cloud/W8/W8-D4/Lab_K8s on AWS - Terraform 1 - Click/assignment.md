# K8s on AWS — Terraform 1-Click

## Đề bài

### Yêu cầu

Dựng 1 con EC2, bật Minikube hoặc Kind trong đó, deploy một app đơn giản, nhỏ nhẹ, expose ra ALB.

Toàn bộ phải là **1-click automation từ Terraform**: bắt nó tự dựng hạ tầng, và biết wire một provider khác vào.

> Lưu ý:
>
> Đây chỉ là đề bài.
>
> Cách giải — kiến trúc, công cụ, cách wire provider, cách nối Kubernetes với ALB — là phần các bạn tự nghiên cứu và đề xuất.
>
> Kỹ năng Minikube/Kind vừa thực hành ở Lab là điểm khởi đầu của bạn.
>
> Không có lời giải mẫu.

---

## Phạm vi & Ràng buộc

### Bắt buộc

- Hạ tầng (EC2 + các thành phần cần thiết) phải được dựng bằng Terraform.
- Cụm Kubernetes chạy bằng Minikube hoặc Kind trên EC2.
- Application phải chạy bên trong Kubernetes (không cài trực tiếp trên EC2).
- Application phải truy cập được từ Internet thông qua ALB.
- Chỉ cần một lệnh để dựng toàn bộ hệ thống (1-click deployment).
- Phải sử dụng tối thiểu 2 Terraform Providers và có cơ chế wire provider.

### Tự do quyết định

- Loại application (miễn nhẹ, đơn giản).
- Ngôn ngữ lập trình.
- Sử dụng Minikube hay Kind.
- Driver của Minikube/Kind.
- Terraform provider thứ hai là gì.
- Cách triển khai application vào cluster.
- Thiết kế Network/VPC.
- Cấu trúc thư mục.
- Terraform modules.
- Variables.

---

## Cần tự nghiên cứu

- Chạy Kubernetes trên một EC2 như thế nào để network được expose ra host.
- ALB kết nối tới application đang chạy trong cluster bằng cách nào.
- Terraform điều phối nhiều providers trong một lần apply ra sao.
- Cách quản lý dependency giữa Infrastructure, Kubernetes cluster và Application deployment.
- Thứ tự provisioning phù hợp để đảm bảo hệ thống hoạt động hoàn chỉnh sau một lần apply.

---

## Deliverables

### 1. Terraform Repository

Bao gồm toàn bộ source code cần thiết để dựng hệ thống.

### 2. README.md

README cần có:

- Kiến trúc tổng thể.
- Sơ đồ hệ thống.
- Hướng dẫn chạy.
- Giải thích cách wire providers.
- Giải thích các quyết định thiết kế chính.

### 3. Bằng chứng hoạt động

- URL của ALB.
- Ảnh chụp màn hình hoặc video cho thấy application truy cập được từ browser.

### 4. Cleanup

Phải destroy được toàn bộ tài nguyên sau khi hoàn thành.

---

## Acceptance Criteria

### 1. One-Click Deployment

Từ repository sạch:

```bash
terraform apply
```

Sau khi hoàn thành:

- Application chạy thành công.
- URL ALB truy cập được từ Internet.

### 2. Application chạy trong Kubernetes

Application phải chạy trong Minikube hoặc Kind.
Không được chạy trực tiếp trên EC2.

### 3. Multi-Provider

Có tối thiểu 2 Terraform Providers được sử dụng và wire trong cùng cấu hình.

### 4. Design Justification

Người thực hiện giải thích được:

- Tại sao chọn kiến trúc đó.
- Tại sao chọn provider đó.
- Cách hoạt động của luồng kết nối.

### 5. Reproducibility

Hệ thống có thể:

- Destroy hoàn toàn.
- Dựng lại từ đầu.
- Cho kết quả giống nhau.

---

## Cách chấm

Trainer sẽ:

1. Clone repository.
2. Thực hiện đúng các bước trong README.
3. Chạy lệnh triển khai.
4. Kiểm tra:
   - ALB hoạt động.
   - Application truy cập được.
   - Application thực sự chạy trong Kubernetes.
   - Có sử dụng nhiều Terraform Providers.
5. Hỏi giải thích về kiến trúc và các quyết định thiết kế.

> Lưu ý: Sau khi hoàn thành cần destroy toàn bộ hạ tầng để tránh phát sinh chi phí AWS không cần thiết.

---

# Giờ là lúc tự tay làm

Bạn vừa tự deploy, expose, scale, rollout và debug một application trên một cụm Kubernetes thực tế.

Phần còn lại là thử thách của bạn:

- Đưa Kubernetes lên AWS.
- Tự động hóa toàn bộ bằng Terraform.
- Thiết kế kiến trúc phù hợp.
- Wire nhiều Terraform Providers trong cùng một workflow.
- Đảm bảo chỉ cần 1-click deployment để dựng toàn bộ hệ thống.

Không có lời giải mẫu.

Mục tiêu không phải là làm giống một đáp án có sẵn, mà là chứng minh bạn hiểu:

- Kubernetes hoạt động như thế nào.
- Terraform điều phối hạ tầng ra sao.
- Cách kết nối Infrastructure và Application Deployment.
- Cách xây dựng một hệ thống có thể tái tạo (reproducible) và tự động hóa hoàn toàn.

Hãy chủ động nghiên cứu, thử nghiệm, thất bại, sửa lỗi và bảo vệ các quyết định thiết kế của mình.

Đó chính là phần quan trọng nhất của bài tập này.

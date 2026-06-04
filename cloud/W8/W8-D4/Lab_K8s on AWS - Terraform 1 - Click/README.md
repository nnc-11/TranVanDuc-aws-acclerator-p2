# K8s on AWS - Terraform 1-Click

Lab này dùng Terraform để tạo hạ tầng AWS, cài Minikube trên EC2, deploy app HTTP base vào Kubernetes và expose app ra Internet thông qua AWS ALB.

## Kiến trúc tổng thể

```text
User Browser
  -> Internet
  -> Public ALB :80
  -> Target Group instance port 30080
  -> EC2 private IP :30080
  -> Kubernetes Service NodePort
  -> Pod hashicorp/http-echo
```

Thành phần chính:

- AWS VPC riêng cho lab.
- 2 public subnets trên 2 Availability Zones.
- EC2 Amazon Linux 2023 `c7i-flex.large` chạy Minikube.
- Minikube driver `none`, container runtime `containerd`.
- Public Application Load Balancer.
- Target Group target type `instance`, port `30080`.
- Kubernetes Deployment `hello-app` với 2 replicas.
- Kubernetes Service `NodePort` port `30080`.

## Lựa chọn thiết kế

- Chọn Minikube vì phù hợp yêu cầu lab và để vận hành single-node Kubernetes trên EC2.
- Chọn driver `none` để NodePort bind trực tiếp lên network của EC2, giúp ALB forward vào EC2 qua port `30080`.
- Chọn container runtime `containerd` vì Kubernetes v1.24+ không dùng Docker CRI trực tiếp nếu không cài thêm `cri-dockerd`.
- Cài thêm `crictl` và CNI plugins vì Minikube driver `none` với Kubernetes mới cần các dependency này trên host.
- Chọn `hashicorp/http-echo` vì image nhỏ, không cần build, phù hợp mục đích chứng minh request đã đi vào Kubernetes.
- Chọn ALB target type `instance` để ALB forward trực tiếp tới EC2 NodePort, không cần AWS Load Balancer Controller.

## Terraform providers

Repo sử dụng các providers:

- `hashicorp/aws`: tạo VPC, subnet, EC2, Security Group, ALB, Target Group, Listener.
- `hashicorp/cloudinit`: render cloud-init user data để bootstrap Minikube và deploy app.

Wire dependency:

- `cloudinit_config` đóng gói bootstrap script và Kubernetes manifests.
- `aws_instance.user_data_base64` nhận output từ `cloudinit_config`.
- EC2 tự cài Minikube và apply manifests khi khởi động, không cần Terraform SSH vào instance.
- `aws_lb_target_group_attachment` attach EC2 vào Target Group port `30080`.

## Cấu trúc thư mục

```text
.
├── .gitignore
├── assignment.md
├── solution.md
├── evidence.md
├── README.md
└── terraform/
    ├── .terraform.lock.hcl
    ├── versions.tf
    ├── providers.tf
    ├── variables.tf
    ├── terraform.tfvars.example
    ├── locals.tf
    ├── network.tf
    ├── security.tf
    ├── compute.tf
    ├── alb.tf
    ├── bootstrap.tf
    ├── outputs.tf
    ├── scripts/
    │   └── bootstrap-minikube.sh
    └── k8s/
        ├── namespace.yaml
        ├── deployment.yaml
        └── service.yaml
```

## Cách chạy

Điều kiện trước khi chạy:

- Đã cấu hình AWS credentials.
- AWS region: `ap-southeast-1`.
- AWS account có quyền tạo VPC, EC2, Security Group, ALB.
- Terraform CLI đã cài trên máy local.

Chạy deployment:

```bash
cd terraform
terraform init
terraform apply
```

Sau khi apply thành công, lấy output:

```bash
terraform output
```

Kiểm tra app:

```bash
curl "$(terraform output -raw application_url)"
```

Kết quả mong đợi:

```text
Hello from Kubernetes
```

## Cleanup

Destroy toàn bộ tài nguyên:

```bash
cd terraform
terraform destroy
```

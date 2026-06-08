# Giải pháp lab: K8s on AWS - Terraform 1-Click

## 1. Tóm tắt yêu cầu

Dùng Terraform để tạo 1 EC2 trên AWS, cài Minikube trên EC2, deploy một web app nhỏ vào Kubernetes và expose app ra Internet thông qua AWS Application Load Balancer.

Ràng buộc bắt buộc:

- Hạ tầng AWS được tạo bằng Terraform.
- Kubernetes chạy bằng Minikube trên EC2.
- Application chạy trong Kubernetes, không chạy trực tiếp trên EC2.
- Internet traffic đi qua ALB.
- Một workflow Terraform dùng được toàn bộ hệ thống.
- Sử dụng nhiều Terraform providers và có dependency wire rõ ràng.

## 2. Phương án chọn

### Kubernetes runtime

Chọn **Minikube trên EC2**.

### EC2

Chọn **Amazon Linux 2023, instance type `c7i-flex.large`, EBS 20GB**.

Lý do:

- Đủ CPU/RAM cho Minikube single-node và app demo.
- AMI phổ biến, để cài Docker package, containerd, kubectl và Minikube bằng script.
- Chi phí phù hợp cho lab ngắn hạn.

### Minikube driver

Chọn **Minikube driver `none`**.

Lý do:

- Minikube chạy trực tiếp trên host EC2.
- Kubernetes NodePort bind trực tiếp lên network của EC2.
- ALB forward được request tới EC2 qua port NodePort `30080`.
- Kiến trúc gọn, dễ debug và dễ giải thích.

### Application image

Chọn **`hashicorp/http-echo`**.

Lý do:

- Image nhỏ, đúng mục đích test HTTP rất rõ ràng.
- Không cần build image riêng, giảm lỗi ngoài phạm vi lab.
- Trả về response tĩnh `Hello from Kubernetes`, phù hợp để chứng minh app đang chạy sau ALB.

Kubernetes resources:

- `Namespace`: `lab`
- `Deployment`: 2 replicas
- `Service`: `NodePort`, service port `80`, container port `5678`, nodePort `30080`

## 3. Kiến trúc hệ thống

```text
User Browser
  -> Internet
  -> Public ALB :80
  -> Target Group instance port 30080
  -> EC2 private IP :30080
  -> Kubernetes Service NodePort
  -> Pod hashicorp/http-echo
```

Thành phần AWS:

- 1 VPC riêng cho lab.
- 2 public subnets trên 2 Availability Zones.
- 1 Internet Gateway.
- 1 public route table.
- 1 EC2 instance chạy Minikube.
- 1 ALB public.
- 1 Target Group target type `instance`, protocol HTTP, port `30080`.
- 1 Listener HTTP port `80`.
- Security Group ALB: allow inbound TCP 80 từ Internet.
- Security Group EC2: allow inbound TCP 30080 từ ALB Security Group.

Thành phần Kubernetes:

- Minikube single-node cluster.
- Namespace `lab`.
- Deployment `hello-app`.
- Service `hello-app` type `NodePort`.

## 4. Terraform providers và wire dependency

Chọn 2 providers:

1. `hashicorp/aws`: tạo VPC, subnet, EC2, Security Group, ALB, Target Group, Listener.
2. `hashicorp/cloudinit`: render cloud-init user data để cài Minikube và deploy app.

Wire dependency:

- `cloudinit_config.minikube` đóng gói bootstrap script và Kubernetes manifests.
- `aws_instance.minikube.user_data` nhận output từ `cloudinit_config.minikube`.
- EC2 tự cài Minikube và deploy manifests khi khởi động.
- `aws_lb_target_group_attachment` gắn EC2 vào Target Group port `30080`.
- ALB Listener forward request vào Target Group.

## 5. Phương án thực hiện

1. Tạo network AWS: VPC, subnets, route table, Internet Gateway.
2. Tạo Security Groups cho ALB và EC2.
3. Render cloud-init user data bằng cloudinit provider.
4. Tạo EC2 Amazon Linux 2023 với user data đã render.
5. EC2 tự chạy `scripts/bootstrap-minikube.sh` khi khởi động.
6. Script trên EC2 cài Docker package, containerd, kubectl, minikube, crictl, CNI plugins và conntrack.
7. Start Minikube với driver `none` và container runtime `containerd`.
8. Apply manifests trong `k8s/`.
9. Tạo ALB, Target Group, Listener và attach EC2 vào Target Group.
10. Output ALB DNS name.

Lệnh chạy:

```bash
cd terraform
terraform init
terraform apply
```

## 6. Thành phần cần chuẩn bị

Local:

- Terraform CLI.
- AWS CLI.
- AWS credentials có quyền tạo VPC, EC2, Security Group, ALB.
- Git.

AWS:

- Region: `ap-southeast-1`.
- Quota cho 1 EC2 `c7i-flex.large`.
- Quota cho 1 ALB.
- Quyền tạo VPC, subnet, route table, Security Group, EC2, ALB, Target Group, Listener.

EC2 sẽ được bootstrap tự động:

- Docker package và containerd.
- conntrack.
- crictl.
- CNI plugins.
- kubectl.
- minikube.
- Kubernetes manifests của app.

## 7. Kiến trúc thư mục để xuất

Code Terraform, script và Kubernetes manifests đặt chung trong thư mục `terraform/`.

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

Vai tro chính:

- `terraform/*.tf`: toàn bộ hạ tầng AWS và provision Minikube.
- `terraform/.terraform.lock.hcl`: khóa provider versions sau khi `terraform init`.
- `terraform/scripts/`: script cài Minikube và deploy app trên EC2.
- `terraform/k8s/`: Kubernetes manifests cho app.
- `README.md`: hướng dẫn chạy, kiến trúc, cleanup.
- `evidence.md`: ghi ALB URL và bằng chứng sau khi apply thành công.
- `.gitignore`: bỏ qua state, key, cache và file tạm.

## 9. Dự đoán rủi ro kỹ thuật và cách fix ngắn gọn

- Minikube start chậm: thêm wait/retry đến khi `kubectl get nodes` thành công; driver `none` cần `crictl`, CNI plugins và kubeconfig path đúng.
- ALB health check fail: cố định Service `nodePort: 30080`, health check path `/`.
- EC2 bị chặn traffic: EC2 SG chỉ allow TCP 30080 từ ALB SG.
- Cloud-init chạy lỗi: xem log `/var/log/cloud-init-output.log` và `/var/log/minikube-bootstrap.log`.
- Pod chưa ready: script wait `kubectl rollout status deployment/hello-app -n lab`.
- Destroy sót tài nguyên: tất cả AWS resources phải nằm trong Terraform state.

## 10. Kết quả mong đợi

Sau khi chạy:

```bash
cd terraform
terraform init
terraform apply
```

Terraform output:

```text
alb_dns_name = "<ten-alb>.ap-southeast-1.elb.amazonaws.com"
```

Kiểm tra:

```bash
curl http://<alb_dns_name>
```

Kết quả:

```text
Hello from Kubernetes
```

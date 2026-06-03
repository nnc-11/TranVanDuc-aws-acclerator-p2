# 003 - Install kubectl

## Mục tiêu

Cài kubectl để thao tác với Kubernetes API server. Trong lab này, kubectl dùng để kiểm tra node, namespace, Pod, Deployment, Service và các resource khác trong minikube.

## Điều kiện trước khi cài

* Đã hoàn thành `001_docker_desktop.md`.
* Nên hoàn thành `002_minikube.md` trước khi kiểm tra cluster.
* Có thể chạy lệnh trong Ubuntu/WSL.

## Step-by-step

### Step 1 - Cài kubectl trên Windows bằng winget

Mở PowerShell hoặc Windows Terminal trên Windows, chạy:

```powershell
winget install --id Kubernetes.kubectl -e --accept-source-agreements --accept-package-agreements
```

Sau khi cài xong, mở terminal mới nếu PATH chưa nhận `kubectl`.

### Step 2 - Cài kubectl binary cho Ubuntu/WSL

Trong Ubuntu/WSL, đứng tại folder `install_tools`, chạy:

```bash
mkdir -p bin
curl -LO "https://dl.k8s.io/release/stable.txt"
curl -LO "https://dl.k8s.io/release/$(cat stable.txt)/bin/linux/amd64/kubectl"
install kubectl bin/kubectl
rm stable.txt kubectl
```

Nếu không có quyền dùng `install`, có thể dùng:

```bash
mkdir -p bin
curl -LO "https://dl.k8s.io/release/stable.txt"
curl -LO "https://dl.k8s.io/release/$(cat stable.txt)/bin/linux/amd64/kubectl"
mv kubectl bin/kubectl
chmod +x bin/kubectl
rm stable.txt
```

### Step 3 - Kiểm tra kubectl client

Trong Ubuntu/WSL, chạy:

```bash
./bin/kubectl version --client
```

Kết quả mong đợi:

```text
Client Version: v...
Kustomize Version: v...
```

### Step 4 - Start minikube trước khi kiểm tra cluster

Nếu cluster chưa chạy, start minikube:

```bash
./bin/minikube start --driver=docker
```

Kiểm tra minikube:

```bash
./bin/minikube status
```

### Step 5 - Kiểm tra context Kubernetes

Sau khi minikube start thành công, chạy:

```bash
./bin/kubectl config current-context
```

Kết quả mong đợi:

```text
minikube
```

Nếu chưa đúng context, chuyển sang context minikube:

```bash
./bin/kubectl config use-context minikube
```

### Step 6 - Kiểm tra node

Chạy:

```bash
./bin/kubectl get nodes
```

Kết quả mong đợi:

```text
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   ...   v...
```

### Step 7 - Kiểm tra namespace mặc định

Chạy:

```bash
./bin/kubectl get namespaces
```

Kết quả mong đợi có các namespace cơ bản:

```text
default
kube-node-lease
kube-public
kube-system
```

## Lệnh kubectl thường dùng trong lab

Xem Pod:

```bash
./bin/kubectl get pods -A
```

Xem Service:

```bash
./bin/kubectl get svc -A
```

Xem Deployment:

```bash
./bin/kubectl get deploy -A
```

Mô tả Pod:

```bash
./bin/kubectl describe pod <pod-name> -n <namespace>
```

Xem logs:

```bash
./bin/kubectl logs <pod-name> -n <namespace>
```

Port-forward Service:

```bash
./bin/kubectl port-forward svc/<service-name> 8080:80 -n <namespace>
```

Apply manifest:

```bash
./bin/kubectl apply -f <file-or-folder>
```

Xóa manifest:

```bash
./bin/kubectl delete -f <file-or-folder>
```

## Lỗi thường gặp

### Lỗi: The connection to the server localhost:8080 was refused

Nguyên nhân thường là chưa có kubeconfig hoặc minikube chưa start.

Cách xử lý:

```bash
./bin/minikube start --driver=docker
./bin/kubectl config current-context
./bin/kubectl get nodes
```

### Lỗi: kubectl command not found

Nếu dùng binary trong repo, gọi đúng path:

```bash
./bin/kubectl version --client
```

Hoặc thêm `install_tools/bin` vào `PATH`.

### Lỗi: context không phải minikube

Chuyển context:

```bash
./bin/kubectl config use-context minikube
```

## Success Criteria

Hoàn thành file này khi các lệnh sau chạy thành công:

```bash
./bin/kubectl version --client
./bin/kubectl config current-context
./bin/kubectl get nodes
./bin/kubectl get namespaces
```

## Trạng thái máy hiện tại

Kiểm tra ngày `2026-06-03 23:27:56 +07`:

* Windows package `Kubernetes.kubectl` đã được cài.
* Binary Linux đã có tại `install_tools/bin/kubectl`.
* `./bin/kubectl version --client` đã verify thành công.
* Context hiện tại là `minikube`.
* `./bin/kubectl get nodes` đã đọc được node `minikube` ở trạng thái `Ready`.
* `./bin/kubectl get namespaces` đã đọc được namespace mặc định của cluster.

Verify kubectl client:

```text
Client Version: v1.33.0
Kustomize Version: v5.6.0
```

Verify context:

```text
minikube
```

Verify node:

```text
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   38s   v1.35.1
```

Verify namespaces:

```text
NAME              STATUS   AGE
default           Active   38s
kube-node-lease   Active   38s
kube-public       Active   38s
kube-system       Active   38s
```

Kết luận: kubectl đã sẵn sàng để thao tác với cluster minikube.

## References

* kubectl install documentation: <https://kubernetes.io/docs/tasks/tools/>
* kubectl cheat sheet: <https://kubernetes.io/docs/reference/kubectl/quick-reference/>

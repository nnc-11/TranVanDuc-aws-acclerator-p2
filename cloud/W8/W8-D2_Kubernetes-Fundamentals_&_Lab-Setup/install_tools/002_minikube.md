# 002 - Install minikube

## Mục tiêu

Cài minikube để tạo Kubernetes cluster local trên máy cá nhân. Trong lab này, minikube dùng Docker làm driver.

## Điều kiện trước khi cài

* Đã hoàn thành `001_docker_desktop.md`.
* `docker run --rm hello-world` chạy thành công trong Ubuntu/WSL.
* Có quyền tải/cài binary trên máy.

## Step-by-step

### Step 1 - Kiểm tra Docker trước khi cài minikube

Trong Ubuntu/WSL, chạy:

```bash
docker version
docker run --rm hello-world
```

Chỉ tiếp tục khi Docker chạy thành công.

### Step 2 - Cài minikube trên Windows bằng winget

Mở PowerShell hoặc Windows Terminal trên Windows, chạy:

```powershell
winget install --id Kubernetes.minikube -e --accept-source-agreements --accept-package-agreements
```

Sau khi cài xong, mở terminal mới nếu PATH chưa nhận `minikube`.

### Step 3 - Cài minikube binary cho Ubuntu/WSL

Trong Ubuntu/WSL, đứng tại folder `install_tools`, chạy:

```bash
mkdir -p bin
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
install minikube-linux-amd64 bin/minikube
rm minikube-linux-amd64
```

Nếu không có quyền dùng `install`, có thể dùng:

```bash
mkdir -p bin
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
mv minikube-linux-amd64 bin/minikube
chmod +x bin/minikube
```

### Step 4 - Kiểm tra version minikube

Trong Ubuntu/WSL, chạy:

```bash
./bin/minikube version
```

Kết quả mong đợi:

```text
minikube version: v...
```

### Step 5 - Start Kubernetes cluster bằng Docker driver

Trong Ubuntu/WSL, chạy:

```bash
./bin/minikube start --driver=docker
```

Nếu muốn lưu cấu hình minikube trong folder lab thay vì home directory, chạy:

```bash
env MINIKUBE_HOME="$PWD/.minikube" ./bin/minikube start --driver=docker
```

### Step 6 - Kiểm tra trạng thái cluster

Trong Ubuntu/WSL, chạy:

```bash
./bin/minikube status
```

Kết quả mong đợi là các thành phần chính ở trạng thái `Running`.

### Step 7 - Kiểm tra Kubernetes node

Nếu đã cài `kubectl`, chạy:

```bash
kubectl get nodes
```

Nếu muốn dùng kubectl đi kèm minikube:

```bash
./bin/minikube kubectl -- get nodes
```

Kết quả mong đợi:

```text
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   ...   v...
```

## Lệnh quản lý minikube

Stop cluster:

```bash
./bin/minikube stop
```

Xóa cluster:

```bash
./bin/minikube delete
```

Xem dashboard:

```bash
./bin/minikube dashboard
```

Mở service trong browser hoặc lấy URL:

```bash
./bin/minikube service <service-name> -n <namespace>
```

## NetworkPolicy Note

Docker driver mặc định có thể chưa đủ để test NetworkPolicy thật sự. Nếu lab cần NetworkPolicy có hiệu lực, tạo lại cluster với Calico:

```bash
./bin/minikube delete
./bin/minikube start --driver=docker --cni=calico
```

## Lỗi thường gặp

### Lỗi: Docker daemon is not running

Cách xử lý:

1. Mở Docker Desktop.
2. Đợi Docker Desktop chạy ổn định.
3. Trong Ubuntu/WSL, kiểm tra lại:

```bash
docker run --rm hello-world
```

### Lỗi: permission denied khi minikube gọi Docker

Cách xử lý:

```powershell
wsl --shutdown
```

Sau đó mở lại Ubuntu/WSL và chạy:

```bash
docker run --rm hello-world
./bin/minikube start --driver=docker
```

### Lỗi: minikube command not found

Nếu dùng binary trong repo, cần gọi đúng path:

```bash
./bin/minikube version
```

Hoặc thêm `install_tools/bin` vào `PATH`.

## Success Criteria

Hoàn thành file này khi các lệnh sau chạy thành công:

```bash
./bin/minikube version
./bin/minikube start --driver=docker
./bin/minikube status
./bin/minikube kubectl -- get nodes
```

## Trạng thái máy hiện tại

Kiểm tra ngày `2026-06-03 23:27:56 +07`:

* Windows package `Kubernetes.minikube` đã được cài.
* Binary Windows tồn tại tại `C:\Program Files\Kubernetes\Minikube\minikube.exe`.
* Binary Linux đã có tại `install_tools/bin/minikube`.
* `./bin/minikube version` đã verify thành công với version `v1.38.1`.
* Docker đã chạy thành công với `hello-world`.
* Cluster minikube đã start thành công bằng Docker driver.
* `MINIKUBE_HOME` đang dùng trong lab: `install_tools/.minikube`.

Verify `./bin/minikube status`:

```text
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```

Verify Kubernetes node:

```text
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   38s   v1.35.1
```

Kết luận: minikube đã sẵn sàng cho lab Kubernetes local.

## References

* minikube start documentation: <https://minikube.sigs.k8s.io/docs/start/>
* minikube Docker driver: <https://minikube.sigs.k8s.io/docs/drivers/docker/>

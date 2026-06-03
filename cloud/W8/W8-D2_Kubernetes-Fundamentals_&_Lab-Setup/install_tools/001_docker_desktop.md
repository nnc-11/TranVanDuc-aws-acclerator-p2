# 001 - Install Docker Desktop

## Mục tiêu

Cài Docker Desktop để có Docker Engine/container runtime. minikube sẽ dùng Docker để tạo Kubernetes cluster local.

## Điều kiện trước khi cài

* Máy Windows đã có WSL2 và Ubuntu.
* Có quyền cài phần mềm trên Windows.
* Mở được Docker Desktop sau khi cài.

## Step-by-step

### Step 1 - Cài Docker Desktop trên Windows

Mở PowerShell hoặc Windows Terminal trên Windows, chạy:

```powershell
winget install --id Docker.DockerDesktop -e --accept-source-agreements --accept-package-agreements
```

Nếu không dùng `winget`, tải installer từ trang chính thức:

```text
https://docs.docker.com/get-docker/
```

### Step 2 - Mở Docker Desktop

Sau khi cài xong:

1. Mở Docker Desktop từ Start Menu.
2. Đợi Docker Desktop chạy ổn định.
3. Nếu được hỏi dùng WSL2 backend, chọn WSL2.

### Step 3 - Bật WSL Integration

Trong Docker Desktop:

1. Vào `Settings`.
2. Chọn `Resources`.
3. Chọn `WSL Integration`.
4. Bật `Enable integration with my default WSL distro`.
5. Bật thêm distro `Ubuntu`.
6. Bấm `Apply & Restart`.

### Step 4 - Mở lại Ubuntu/WSL

Đóng terminal Ubuntu/WSL cũ, mở terminal Ubuntu/WSL mới.

Nếu Docker vẫn lỗi quyền hoặc không nhận lệnh, mở PowerShell chạy:

```powershell
wsl --shutdown
```

Sau đó mở lại Ubuntu/WSL.

### Step 5 - Kiểm tra Docker CLI

Trong Ubuntu/WSL, chạy:

```bash
docker --version
docker compose version
```

Kết quả mong đợi:

```text
Docker version ...
Docker Compose version ...
```

### Step 6 - Kiểm tra Docker daemon

Trong Ubuntu/WSL, chạy:

```bash
docker version
docker info
```

`docker version` phải có đủ phần `Client` và `Server`.

### Step 7 - Chạy container test

Trong Ubuntu/WSL, chạy:

```bash
docker run --rm hello-world
```

Kết quả thành công sẽ có dòng:

```text
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

## Lỗi thường gặp

### Lỗi: docker command could not be found

Nguyên nhân thường là Docker Desktop chưa bật WSL Integration cho Ubuntu.

Cách xử lý: step 3

### Lỗi: permission denied while trying to connect to docker.sock

Nguyên nhân thường là terminal WSL hiện tại chưa nạp lại quyền/socket mới.

Cách xử lý:

```powershell
wsl --shutdown
```

Sau đó mở lại Ubuntu/WSL và chạy lại:

```bash
docker run --rm hello-world
```

## Success Criteria

Hoàn thành file này khi các lệnh sau chạy thành công trong Ubuntu/WSL:

```bash
docker --version
docker compose version
docker version
docker info
docker run --rm hello-world
```
## References

* Docker install documentation: <https://docs.docker.com/get-docker/>
* Docker Desktop WSL2 backend: <https://docs.docker.com/desktop/features/wsl/>

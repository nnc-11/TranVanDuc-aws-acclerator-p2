# 004 - Probes, ConfigMap and Secret

## Tóm tắt

Bài này giới thiệu các cơ chế giúp ứng dụng vận hành ổn định và quản lý cấu hình trong Kubernetes.

Bao gồm:

- Probe: kiểm tra tình trạng ứng dụng.
- ConfigMap: lưu cấu hình không nhạy cảm.
- Secret: lưu dữ liệu nhạy cảm.

## What problem do they solve?

Kubernetes cần biết:

- Ứng dụng đã sẵn sàng nhận traffic hay chưa.
- Ứng dụng có đang hoạt động bình thường hay không.
- Cấu hình và thông tin nhạy cảm nên được quản lý như thế nào mà không phải rebuild image.

Các vấn đề này được giải quyết bởi:

```text
Application Health
        ↓
      Probe

Configuration
        ↓
   ConfigMap

Sensitive Data
        ↓
     Secret
```

## Probes

Probe là cơ chế để Kubernetes kiểm tra trạng thái của container và quyết định khi nào container đã khởi động xong, đã sẵn sàng nhận traffic, hoặc cần được restart.

| Probe | Mục đích | Kết quả khi fail |
| --- | --- | --- |
| `startupProbe` | Kiểm tra ứng dụng đã khởi động thành công chưa | Chưa chạy các probe khác |
| `readinessProbe` | Kiểm tra Pod đã sẵn sàng nhận traffic chưa | Service ngừng gửi traffic tới Pod |
| `livenessProbe` | Kiểm tra ứng dụng còn hoạt động bình thường không | Kubernetes restart container |

### startupProbe

- Kiểm tra ứng dụng đã khởi động thành công hay chưa.
- Dùng cho ứng dụng khởi động chậm.
- Chưa thành công thì Kubernetes chưa chạy các probe khác.

```text
Container Start
        ↓
   startupProbe
        ↓
     Success
```

Use Cases:

- Java applications.
- Spring Boot.
- Database initialization.

### readinessProbe

- Xác định Pod đã sẵn sàng nhận traffic hay chưa.
- Nếu probe thất bại, Service sẽ không gửi traffic tới Pod.

```text
Service
    ↓
Ready Pod
```

Use Cases:

- API đang khởi động.
- Ứng dụng cần kết nối database trước khi phục vụ request.

### livenessProbe

- Phát hiện ứng dụng bị treo hoặc không phản hồi.
- Khi probe thất bại, Kubernetes sẽ khởi động lại container.

```text
Application Hang
        ↓
  livenessProbe Fail
        ↓
 Container Restart
```

Use Cases:

- Deadlock.
- Infinite loop.
- Application không còn phản hồi request.

## ConfigMap

- Lưu cấu hình không nhạy cảm.
- Tách cấu hình khỏi container image.
- Có thể được inject vào Pod dưới dạng environment variables hoặc file.

```text
ConfigMap
      ↓
     Pod
      ↓
 Application
```

Use Cases:

- `APP_ENV`
- Feature Flags.
- Application Configuration Files.

## Secret

- Lưu dữ liệu nhạy cảm.
- Có thể được inject vào Pod dưới dạng environment variables hoặc file.
- Mặc định chỉ được Base64 encode.

```text
Secret
    ↓
   Pod
    ↓
Application
```

Use Cases:

- Password.
- API Token.
- TLS Certificate.
- Private Key.

## How applications use ConfigMap and Secret

- Nạp toàn bộ cấu hình bằng `envFrom`.
- Nạp từng giá trị bằng `valueFrom`.
- Mount ConfigMap hoặc Secret thành file bằng `volumeMounts`.

```text
ConfigMap / Secret
          ↓
     Environment Variables
```

Hoặc:

```text
ConfigMap / Secret
          ↓
       Mounted Files
```

## Security Notes

- Secret mặc định chỉ được Base64 encode, không phải encryption.
- Không lưu Secret trực tiếp trong Git repository.
- Nên sử dụng RBAC để giới hạn quyền truy cập Secret.
- Production nên sử dụng encryption at rest hoặc external secret manager.

Ví dụ:

- HashiCorp Vault.
- AWS Secrets Manager.
- Azure Key Vault.
- Google Secret Manager.

## Commands (Quick Practice)

```bash
kubectl get configmap
kubectl get secret
kubectl describe secret <name>
kubectl logs <pod>
```

## Key Terms

- Probe: cơ chế kiểm tra tình trạng ứng dụng.
- `startupProbe`: kiểm tra ứng dụng khởi động thành công.
- `readinessProbe`: kiểm tra Pod có sẵn sàng nhận traffic.
- `livenessProbe`: kiểm tra ứng dụng còn hoạt động bình thường.
- ConfigMap: lưu cấu hình không nhạy cảm.
- Secret: lưu dữ liệu nhạy cảm.
- `envFrom`: nạp nhiều biến môi trường từ ConfigMap hoặc Secret.
- `valueFrom`: nạp một giá trị cụ thể từ ConfigMap hoặc Secret.
- `volumeMount`: mount ConfigMap hoặc Secret thành file.

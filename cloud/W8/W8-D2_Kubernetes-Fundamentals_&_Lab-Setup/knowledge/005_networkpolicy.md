# 005 - NetworkPolicy 

## Tóm tắt

Bài này giới thiệu NetworkPolicy - cơ chế kiểm soát lưu lượng mạng giữa các Pod trong Kubernetes.

Thông qua NetworkPolicy, người vận hành có thể giới hạn kết nối giữa các ứng dụng theo nguyên tắc **least privilege**, giảm nguy cơ lateral movement khi xảy ra sự cố bảo mật.

Bài học cũng hướng dẫn thiết lập môi trường lab local để kiểm thử NetworkPolicy bằng Minikube và CNI hỗ trợ policy.

---

## What problem does NetworkPolicy solve?

- Giới hạn kết nối giữa các Pod.
- Áp dụng nguyên tắc least privilege.
- Giảm nguy cơ lateral movement trong cluster.

Mặc định, nhiều Kubernetes cluster cho phép Pod giao tiếp tự do với nhau.

```text
Pod A
  ↕
Pod B
  ↕
Pod C
```

Điều này giúp việc triển khai đơn giản hơn nhưng làm tăng rủi ro bảo mật khi một Pod bị xâm nhập.

NetworkPolicy cho phép giới hạn traffic giữa các Pod và chỉ cho phép những kết nối thực sự cần thiết.

```text
Frontend
    ↓
 Backend

Database
✕ Frontend
```
---

## What is NetworkPolicy?

- NetworkPolicy là Kubernetes object dùng để kiểm soát ingress (đi vào) và egress (đi ra) traffic của Pod.
- Rule có thể dựa trên Pod labels, Namespace, Port và Protocol.
- Chỉ có hiệu lực khi CNI hỗ trợ NetworkPolicy.

```text
NetworkPolicy
       ↓
      Pod
       ↓
Ingress / Egress Rules
```

---

## Ingress Policy

- Kiểm soát traffic đi vào Pod.
- Chỉ cho phép các nguồn được khai báo truy cập Pod.

Use Cases:

- Chỉ cho phép Frontend gọi Backend.
- Chỉ cho phép Monitoring truy cập Metrics Endpoint.

---

## Egress Policy

- Kiểm soát traffic đi ra khỏi Pod.
- Chỉ cho phép Pod kết nối tới các đích được khai báo.

Use Cases:

- Chỉ cho phép kết nối Database.
- Hạn chế truy cập Internet.

---

## Common NetworkPolicy Patterns

### Default Deny

- Chặn toàn bộ traffic ingress hoặc egress.
- Thường là bước đầu tiên khi xây dựng NetworkPolicy.

```text
All Traffic
     ✕
    Pod
```

### Allow Specific Pods

- Chỉ cho phép Pod có label cụ thể truy cập.

```text
app=frontend
      ↓
   Backend

Other Pods
      ✕
   Backend
```

### Allow Specific Namespaces

- Cho phép traffic từ Namespace được chỉ định.
- Sử dụng `namespaceSelector`.

```text
production
     ↓
 Backend

other-ns
    ✕
 Backend
```

### Restrict Ports

- Chỉ cho phép traffic trên các port được chỉ định.

```text
TCP/443
    ↓
 Backend

TCP/22
    ✕
 Backend
```

---

## CNI Requirement

- NetworkPolicy chỉ hoạt động khi CNI hỗ trợ NetworkPolicy.
- Nếu CNI không hỗ trợ, NetworkPolicy sẽ không có hiệu lực.

Ví dụ CNI hỗ trợ:

- Calico
- Cilium

---

## Key Terms

* NetworkPolicy: kiểm soát traffic giữa các Pod.
* Ingress: traffic đi vào Pod.
* Egress: traffic đi ra khỏi Pod.
* CNI: thành phần cung cấp mạng cho Pod.
* podSelector: chọn Pod bằng label.
* namespaceSelector: chọn Namespace bằng label.
* Default Deny: chặn toàn bộ traffic mặc định.

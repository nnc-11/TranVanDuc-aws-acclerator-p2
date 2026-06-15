# OPA & Rego — cơ bản

1. Tổng quan
- OPA (Open Policy Agent) cho phép đánh giá policy ở nhiều nơi (admission, API gateway, CI).
- Rego là ngôn ngữ viết policy cho OPA.

2. Cấu trúc Rego đơn giản

```rego
package kubernetes.admission

deny[msg] {
  input.request.kind.kind == "Pod"
  some i
  input.request.object.spec.containers[i].image == "busybox:latest"
  msg := "disallow using busybox:latest"
}
```

3. Test policy
- Dùng `opa test` và viết `*_test.rego` để cover cases.

4. Áp dụng cho Admission Controller
- OPA có thể chạy dưới dạng sidecar hoặc via Gatekeeper integration.

5. Best practices
- Viết policy nhỏ, test coverage cao.
- Reuse packages và functions.
- Sử dụng input schema khi cần validate.
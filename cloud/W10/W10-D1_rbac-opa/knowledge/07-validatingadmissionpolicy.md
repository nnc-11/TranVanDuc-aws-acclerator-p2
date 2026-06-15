# ValidatingAdmissionPolicy (Kubernetes 1.30+)

1. Giới thiệu
- `ValidatingAdmissionPolicy` là API native cho admission validation, bổ sung cho webhook.
- Cho phép viết policy bằng CEL (Common Expression Language) hoặc tham chiếu tới modules.

2. So sánh với Gatekeeper
- Native API: không cần CRD ngoài, tích hợp trực tiếp với API server.
- Gatekeeper dùng OPA/Rego, có hệ sinh thái và tooling phong phú.

3. Ví dụ CEL đơn giản

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicy
metadata:
  name: disallow-latest
spec:
  background: false
  rules:
  - operations: ["CREATE", "UPDATE"]
    apiGroups: [""]
    apiVersions: ["v1"]
    resources: ["pods"]
  validation:
    expression: "request.object.spec.containers.all(c, c.image.matches('.*:latest') == false)"
```

4. Lựa chọn khi triển khai
- Dùng `ValidatingAdmissionPolicy` nếu muốn native, ít dependency.
- Dùng Gatekeeper khi cần Rego/OPA ecosystem, tận dụng ConstraintTemplate.
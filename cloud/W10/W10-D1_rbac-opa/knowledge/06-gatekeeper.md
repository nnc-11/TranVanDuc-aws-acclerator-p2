# Gatekeeper — ConstraintTemplate vs Constraint

1. Tổng quan
- Gatekeeper là một implementation của OPA cho K8s, cung cấp CRD để quản lý policy: `ConstraintTemplate` và `Constraint`.

2. `ConstraintTemplate`
- Định nghĩa schema và Rego logic (đóng gói policy).
- Ví dụ: tạo một template để kiểm tra image registry.

3. `Constraint`
- Tạo instance của template, chứa parameters (ví dụ: danh sách registry cho phép).

Ví dụ ngắn:

```yaml
apiVersion: templates.gatekeeper.sh/v1
kind: ConstraintTemplate
metadata:
  name: k8srequiredlabels
spec:
  crd:
    spec:
      names:
        kind: K8sRequiredLabels
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8srequiredlabels
        violation[{
          "msg": msg
        }] {
          # rego logic
        }
```

và

```yaml
apiVersion: constraints.gatekeeper.sh/v1
kind: K8sRequiredLabels
metadata:
  name: ns-must-have-owner
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Namespace"]
  parameters:
    labels: ["owner"]
```

4. Best practices
- Tách template (logic) và constraint (config).
- Sử dụng `match` để giới hạn đối tượng áp dụng.
- Test template + constraint trên cluster kiểm thử.
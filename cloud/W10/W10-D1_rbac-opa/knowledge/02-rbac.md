# RBAC trong Kubernetes

1. Khái niệm
- `Role`: định nghĩa quyền trong một namespace.
- `ClusterRole`: định nghĩa quyền toàn cluster.
- `RoleBinding` / `ClusterRoleBinding`: gán `Role`/`ClusterRole` cho `User`/`Group`/`ServiceAccount`.

2. Ví dụ: tạo `Role` và `RoleBinding`

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: demo
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: read-pods-binding
  namespace: demo
subjects:
- kind: ServiceAccount
  name: demo-sa
  namespace: demo
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

3. Best practices
- Sử dụng `ClusterRole` chỉ khi cần quyền toàn cluster.
- Principle of least privilege: chỉ cấp verbs cần thiết.
- Quản lý bằng IaC (kubectl/helm/kustomize).
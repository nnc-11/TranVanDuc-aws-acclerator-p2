# `kubectl auth can-i`

1. Mục đích
- Kiểm tra liệu một `user`/`serviceaccount` có thể thực hiện hành động cụ thể hay không.

2. Các ví dụ

- Kiểm tra quyền hiện tại trên context:

```bash
kubectl auth can-i create deployments -n demo
```

- Kiểm tra với user/serviceaccount cụ thể:

```bash
kubectl auth can-i delete pods --as=system:serviceaccount:demo:app-sa -n demo
```

3. Troubleshooting
- `can-i` trả về `no` nghĩa là cần kiểm tra `RoleBinding`/`ClusterRoleBinding`.
- Dùng `kubectl get rolebinding -n <ns> -o yaml` để xem subjects.

4. Lời khuyên
- Dùng `--as` để giả lập quyền khi debug.
- Kết hợp `kubectl auth can-i` vào CI checks nếu cần.
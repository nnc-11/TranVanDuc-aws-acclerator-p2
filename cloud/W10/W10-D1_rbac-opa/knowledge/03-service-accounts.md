# ServiceAccount & kubeconfig

1. `ServiceAccount` là gì
- Tài khoản dành cho workload trong cluster.
- Gắn vào Pod qua `spec.serviceAccountName`.

2. Tạo ServiceAccount và role binding cho ứng dụng

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-sa
  namespace: demo
```

3. Lấy token từ ServiceAccount (k8s modern):
- K8s 1.24+ dùng `TokenRequest` để request token ngắn hạn.

```bash
kubectl create token app-sa -n demo
```

4. Sử dụng kubeconfig cho CI/CD
- Tạo kubeconfig dùng token ServiceAccount, chỉ cấp quyền cần thiết cho pipeline.
- Không lưu kubeconfig toàn quyền trong repo.

5. Best practices
- Token ngắn hạn, rotate thường xuyên.
- Gán NetworkPolicy + PodSecurityContext kết hợp RBAC.
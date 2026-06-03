# Assessment Answer Key

## Multiple Choice

1. B - Container đóng gói app cùng runtime và dependency để chạy nhất quán.
2. A - Orchestration tự động quản lý scheduling, scaling, restart và networking.
3. B - Pod là đơn vị nhỏ nhất Kubernetes tạo và quản lý.
4. A - Deployment quản lý replica, rollout và rollback.
5. A - Pod IP có thể thay đổi khi Pod bị xóa và tạo lại.
6. A - ClusterIP expose service nội bộ trong cluster.
7. A - Label selector giúp Service chọn đúng Pod đích.
8. A - Readiness probe quyết định Pod có nhận traffic từ Service hay không.
9. A - Liveness probe giúp restart container khi app không healthy.
10. A - ConfigMap dùng cho cấu hình không nhạy cảm.
11. A - Secret thường được biểu diễn base64 encoded.
12. A - NetworkPolicy kiểm soát ingress/egress traffic của Pod.
13. A - NetworkPolicy cần CNI plugin hỗ trợ để thực thi.
14. A - `kubectl get pods` dùng để xem Pod.
15. A - minikube chạy Kubernetes cluster local để học và test.

## Short-Answer Guidance

1. Pod IP không ổn định vì Pod có thể restart, scale hoặc bị thay thế. Service cung cấp endpoint ổn định và tự route traffic đến Pod matching label selector.

2. Readiness probe kiểm tra app đã sẵn sàng nhận traffic chưa. Liveness probe kiểm tra app còn healthy không; nếu fail, kubelet có thể restart container.

3. ConfigMap dùng cho cấu hình không nhạy cảm như mode, feature flag, config file. Secret dùng cho dữ liệu nhạy cảm như password, token, API key; không commit secret thật vào Git.

4. NetworkPolicy giảm traffic không cần thiết giữa Pod, áp dụng least privilege và hạn chế rủi ro lateral movement khi một workload bị compromise.

5. Kiểm tra `docker version`, `minikube version`, `kubectl version --client`, chạy `minikube start`, sau đó xác nhận cluster bằng `kubectl get nodes`.


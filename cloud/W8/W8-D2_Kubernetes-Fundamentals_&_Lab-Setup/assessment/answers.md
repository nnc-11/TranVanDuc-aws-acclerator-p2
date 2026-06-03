# Assessment Questions

## Multiple Choice

1. Container dùng để làm gì?
   A. Thay thế hoàn toàn hệ điều hành host
   B. Đóng gói app cùng runtime và dependency để chạy nhất quán
   C. Chỉ dùng để lưu source code
   D. Chỉ dùng cho database

2. Kubernetes orchestration giải quyết vấn đề chính nào?
   A. Tự động quản lý scheduling, scaling, restart và networking cho container
   B. Chỉ format YAML
   C. Chỉ build Docker image
   D. Chỉ thay thế Git

3. Pod là gì?
   A. Một loại cloud account
   B. Đơn vị nhỏ nhất Kubernetes tạo và quản lý để chạy container
   C. Một loại Docker registry
   D. Một loại firewall ngoài cluster

4. Deployment dùng để làm gì?
   A. Quản lý replica, rollout và rollback cho Pod
   B. Chỉ expose traffic ra internet
   C. Chỉ lưu password
   D. Chỉ quản lý node

5. Vì sao không nên gọi trực tiếp Pod IP?
   A. Pod IP có thể thay đổi khi Pod bị tạo lại
   B. Pod IP luôn public
   C. Pod không có network
   D. Kubernetes cấm mọi truy cập Pod

6. Service loại nào thường dùng để expose nội bộ trong cluster?
   A. ClusterIP
   B. LoadBalancer
   C. ExternalName
   D. IngressClass

7. Label selector trong Service dùng để làm gì?
   A. Chọn Pod đích để route traffic
   B. Chọn Dockerfile
   C. Chọn kubeconfig
   D. Chọn cloud region

8. Readiness probe quyết định điều gì?
   A. Pod có sẵn sàng nhận traffic từ Service hay không
   B. Node có cần xóa không
   C. Image có cần build không
   D. Secret có cần encode không

9. Liveness probe thường dùng để làm gì?
   A. Restart container khi app bị treo hoặc không healthy
   B. Tạo Namespace mới
   C. Tạo Docker image
   D. Mở port trên laptop

10. ConfigMap phù hợp để lưu gì?
    A. Cấu hình không nhạy cảm
    B. Password production dạng plain text
    C. Private key thật đưa vào Git
    D. Token root account

11. Secret trong Kubernetes mặc định thường được biểu diễn dưới dạng nào?
    A. Base64 encoded
    B. Plain binary không thể đọc
    C. Terraform state
    D. Docker image layer

12. NetworkPolicy dùng để làm gì?
    A. Kiểm soát ingress/egress traffic của Pod
    B. Build image nhanh hơn
    C. Tự động tạo cloud account
    D. Tăng dung lượng disk

13. NetworkPolicy có hiệu lực phụ thuộc vào điều gì?
    A. CNI plugin có hỗ trợ NetworkPolicy
    B. Tên Dockerfile
    C. Số lượng file Markdown
    D. Phiên bản Git

14. Lệnh nào dùng để xem Pod trong cluster?
    A. kubectl get pods
    B. docker build pods
    C. minikube delete pods
    D. terraform pods list

15. minikube chủ yếu dùng để làm gì trong bài lab này?
    A. Chạy Kubernetes cluster local để học và test
    B. Tạo EC2 trên AWS
    C. Thay thế hoàn toàn kubectl
    D. Lưu secret production

## Short Answer

1. Giải thích ngắn gọn vì sao Kubernetes cần Service thay vì chỉ dùng Pod IP.
2. So sánh readiness probe và liveness probe.
3. Khi nào dùng ConfigMap, khi nào dùng Secret?
4. Vì sao NetworkPolicy quan trọng trong bảo mật Kubernetes?
5. Liệt kê các bước kiểm tra local lab đã sẵn sàng với Docker Desktop, minikube và kubectl.


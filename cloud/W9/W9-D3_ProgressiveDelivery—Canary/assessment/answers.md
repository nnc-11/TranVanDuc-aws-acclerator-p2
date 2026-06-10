# Answers - Progressive Delivery Canary

## Trắc nghiệm

Chọn một đáp án đúng nhất.

1. Progressive delivery tập trung vào điều gì?
   - A. Release 100% traffic nhanh nhất có thể
   - B. Release dần dần, quan sát metric và tự động quyết định tiếp tục hoặc rollback
   - C. Chỉ thay đổi CI pipeline
   - D. Chỉ dùng cho database migration

2. Argo Rollouts dùng resource nào để thay thế Deployment khi cần canary nâng cao?
   - A. StatefulSet
   - B. Rollout
   - C. DaemonSet
   - D. CronJob

3. `setWeight: 20` trong canary step thường có nghĩa gì?
   - A. Xóa 20 pod
   - B. Route hoặc scale khoảng 20% sang canary
   - C. Tăng CPU limit 20%
   - D. Chờ 20 phút

4. `pause` trong Rollout canary dùng để làm gì?
   - A. Dừng kubelet
   - B. Dừng rollout tạm thời để quan sát hoặc chờ promotion
   - C. Xóa ReplicaSet cũ
   - D. Tắt Prometheus

5. AnalysisTemplate tạo ra đối tượng chạy thực tế nào?
   - A. AnalysisRun
   - B. HorizontalPodAutoscaler
   - C. PodDisruptionBudget
   - D. Secret

6. Provider nào thường dùng để query metric trong AnalysisTemplate?
   - A. Prometheus
   - B. Git
   - C. Dockerfile
   - D. Kubeconfig

7. `failureLimit` dùng để cấu hình gì?
   - A. Số replicas tối đa
   - B. Số lần metric fail được phép trước khi analysis fail
   - C. Số namespace được tạo
   - D. Thời gian image pull

8. Metric nào phù hợp nhất để gate canary?
   - A. Số dòng log debug
   - B. Error rate 5xx
   - C. Tên node Kubernetes
   - D. Kích thước Dockerfile

9. Burn rate là gì?
   - A. CPU usage chia memory usage
   - B. Tốc độ tiêu thụ error budget so với tốc độ cho phép
   - C. Số pod canary
   - D. Số request thành công tuyệt đối

10. Với SLO 99.9%, error budget là bao nhiêu?
    - A. 0.1%
    - B. 1%
    - C. 10%
    - D. 99.9%

11. Canary không phù hợp khi nào?
    - A. Ứng dụng hỗ trợ chạy nhiều version song song
    - B. Có traffic manager
    - C. Version cũ và mới không tương thích dữ liệu
    - D. Có Prometheus metric

12. Stable service trong canary thường trỏ đến gì?
    - A. Version đang phục vụ production ổn định
    - B. Prometheus server
    - C. Argo CD repo
    - D. Docker registry

13. Vì sao cần traffic tối thiểu trước khi analysis?
    - A. Để tránh metric thiếu mẫu hoặc nhiễu
    - B. Để giảm số node
    - C. Để xóa namespace
    - D. Để đổi imagePullPolicy

14. Manual abort dùng lệnh nào?
    - A. `kubectl argo rollouts abort <rollout>`
    - B. `kubectl delete node <node>`
    - C. `docker compose down`
    - D. `helm repo update`

15. Canary gate và SLO alert khác nhau thế nào?
    - A. Canary gate chỉ chạy trong rollout, SLO alert chạy liên tục
    - B. Canary gate thay thế hoàn toàn monitoring
    - C. SLO alert chỉ chạy khi deploy
    - D. Không có khác biệt

## Tự luận

1. Giải thích luồng canary rollout từ lúc update image đến lúc promote 100%.
2. Vì sao canary cần metric user-facing thay vì chỉ CPU/memory?
3. Viết PromQL tính error rate 5xx trong 5 phút cho service `checkout-api`.
4. Giải thích burn rate với ví dụ SLO 99.9% và error rate 1%.
5. Khi AnalysisRun fail, bạn cần kiểm tra những evidence nào trước khi retry?


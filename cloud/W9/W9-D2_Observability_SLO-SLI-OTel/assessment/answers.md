# Assessment Questions

## Trắc nghiệm

1. Observability giúp trả lời câu hỏi chính nào?
   - A. Vì sao hệ thống đang có hành vi như hiện tại
   - B. Repository có bao nhiêu branch
   - C. Docker image nặng bao nhiêu MB
   - D. Ai tạo VPC đầu tiên

2. Ba signal observability phổ biến là gì?
   - A. Metrics, logs, traces
   - B. Branches, commits, tags
   - C. CPU, RAM, disk only
   - D. Users, roles, policies

3. OpenTelemetry SDK chạy ở đâu?
   - A. Trong ứng dụng
   - B. Chỉ trong Grafana
   - C. Chỉ trong Prometheus
   - D. Trong DNS server

4. OpenTelemetry Collector thường dùng để làm gì?
   - A. Nhận, xử lý và export telemetry
   - B. Tạo pull request
   - C. Build Docker image
   - D. Thay thế toàn bộ database

5. OTLP là gì?
   - A. Protocol phổ biến để gửi telemetry OpenTelemetry
   - B. Một loại IAM role
   - C. Một định dạng Dockerfile
   - D. Một dashboard Grafana

6. Prometheus hoạt động chủ yếu theo mô hình nào?
   - A. Pull/scrape metrics từ target
   - B. Chỉ đọc log file
   - C. Chỉ chạy SQL query
   - D. Chỉ nhận email alert

7. PromQL dùng để làm gì?
   - A. Query dữ liệu metrics trong Prometheus
   - B. Query log trong Loki only
   - C. Viết Dockerfile
   - D. Build Python package

8. Grafana dùng chính để làm gì?
   - A. Dashboard và visualization từ datasource
   - B. Thay thế application code
   - C. Chỉ lưu metrics thô
   - D. Chỉ tạo Kubernetes namespace

9. Loki dùng cho loại dữ liệu nào?
   - A. Logs
   - B. Terraform state
   - C. Container image
   - D. Git commit

10. SLI là gì?
    - A. Chỉ số đo chất lượng dịch vụ
    - B. Mục tiêu kinh doanh năm
    - C. Tên một Kubernetes node
    - D. Một loại secret

11. SLO là gì?
    - A. Mục tiêu chất lượng dựa trên SLI
    - B. Log format
    - C. Docker registry
    - D. File backup

12. Với SLO 99.9%, error budget là bao nhiêu?
    - A. 0.1% hoặc 0.001
    - B. 1% hoặc 0.01
    - C. 10% hoặc 0.1
    - D. 100%

13. Availability SLI thường đo gì?
    - A. Tỷ lệ request thành công
    - B. Số lượng repository
    - C. Dung lượng Docker image
    - D. Số lần deploy trong tháng

14. Fast burn-rate page trong bài dùng window nào?
    - A. 1h và 5m
    - B. 6h và 30m
    - C. 3d và 6h
    - D. 30d và 1d

15. Slow burn-rate page trong bài dùng window nào?
    - A. 6h và 30m
    - B. 1h và 5m
    - C. 5m và 1m
    - D. 90d và 7d

## Tự luận

1. Giải thích ngắn gọn metrics, logs và traces khác nhau thế nào.
2. Mô tả vai trò của OTel SDK và OTel Collector trong pipeline telemetry.
3. Prometheus, Grafana và Loki mỗi công cụ phụ trách phần nào?
4. Cho ví dụ một availability SLI và một latency SLI cho HTTP API.
5. Giải thích vì sao multi-window burn rate alert cần cả long window và short window.

# Assessment Answer Key

## Đáp án trắc nghiệm

1. A
2. A
3. A
4. A
5. A
6. A
7. A
8. A
9. A
10. A
11. A
12. A
13. A
14. A
15. A

## Gợi ý trả lời tự luận

1. Metrics là số đo theo thời gian, phù hợp alert và trend. Logs là sự kiện chi tiết dạng text/JSON, phù hợp điều tra nguyên nhân. Traces là đường đi của một request qua nhiều service, phù hợp debug distributed system.

2. OTel SDK chạy trong app để tạo telemetry như span, metric và attribute. OTel Collector nhận telemetry qua receiver, xử lý bằng processor rồi export sang backend như Prometheus, Loki hoặc tracing backend.

3. Prometheus scrape và query metrics, tạo recording/alerting rules. Grafana hiển thị dashboard từ datasource. Loki lưu và query logs, thường qua LogQL.

4. Availability SLI: tỷ lệ request không phải HTTP 5xx trên tổng request. Latency SLI: tỷ lệ request hoàn thành dưới 300ms trên tổng request.

5. Long window giúp xác nhận lỗi đủ lớn để đáng alert, short window xác nhận lỗi vẫn đang xảy ra. Kết hợp hai window giúp giảm false positive và alert tự reset nhanh hơn khi lỗi dừng.

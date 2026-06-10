# Quiz - Đáp án

## Trắc nghiệm

1. B
2. B
3. B
4. B
5. A
6. A
7. B
8. B
9. B
10. A
11. C
12. A
13. A
14. A
15. A

## Gợi ý tự luận

1. Update image tạo ReplicaSet mới, Rollout đặt weight nhỏ, pause/analysis kiểm tra metric, nếu pass tăng weight theo steps, đến 100% thì version mới thành stable; nếu fail thì abort/rollback.
2. CPU/memory chỉ là resource signal, không khẳng định user có bị lỗi hay chậm không. User-facing metric như 5xx, availability, latency phản ánh tác động thật.
3. Ví dụ:

```promql
sum(rate(http_requests_total{service="checkout-api",status=~"5.."}[5m]))
/
sum(rate(http_requests_total{service="checkout-api"}[5m]))
```

4. SLO 99.9% có error budget 0.1% = 0.001. Nếu error rate 1% = 0.01 thì burn rate = 0.01 / 0.001 = 10, tức tiêu budget nhanh gấp 10 lần mức cho phép.
5. Kiểm tra Rollout status/events, AnalysisRun measurements, Prometheus graph/query result, service selector stable/canary, traffic routing rule, log canary pod và dashboard SLI/SLO.


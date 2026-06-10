# 005 - Abort Criteria and Rollback

## Abort criteria là gì?

Abort criteria là điều kiện khiến rollout dừng lại và không tiếp tục tăng exposure cho version mới. Trong Argo Rollouts, analysis fail thường làm rollout đi vào trạng thái degraded/aborted tùy cấu hình và step, sau đó traffic quay về stable version.

Abort nên dựa trên user-facing metrics:

- Error rate tăng vượt ngưỡng.
- Burn rate vượt ngưỡng.
- Latency p95/p99 vượt SLO.
- Availability giảm.
- Canary health checks fail.

## FailureLimit

`failureLimit` kiểm soát số measurement fail được phép. Ví dụ:

```yaml
failureCondition: result[0] > 1
failureLimit: 1
```

Nếu metric fail hơn 1 lần, AnalysisRun fail. Với canary nhạy cảm, dùng `failureLimit: 0` hoặc `1`. Với metric nhiễu, có thể tăng lên 2-3 nhưng phải hiểu rủi ro.

## Inconclusive

Analysis có thể inconclusive khi metric không đủ dữ liệu hoặc điều kiện không rõ pass/fail. Không nên coi inconclusive là pass trong production nếu metric là gate quan trọng. Cần xử lý bằng:

- Traffic tối thiểu trước khi analysis.
- Window đủ dài.
- Query trả về giá trị mặc định an toàn.
- Manual pause để người vận hành kiểm tra.

## Manual abort

Khi thấy dashboard hoặc alert xấu, có thể abort:

```bash
kubectl argo rollouts abort checkout-api -n progressive-delivery
```

Sau abort, cần kiểm tra:

- Rollout status.
- AnalysisRun status.
- Service selector stable/canary.
- Prometheus/Grafana evidence.
- Event trong namespace.

## Rollback và retry

Rollback không nên chỉ là thao tác kỹ thuật. Cần xác định nguyên nhân trước khi retry:

- Image/version sai.
- Regression code.
- Config/env var sai.
- PromQL query sai hoặc label thiếu.
- Traffic manager chưa chia traffic đúng.

Sau khi fix, có thể update image mới hoặc retry rollout nếu lỗi do môi trường tạm thời.


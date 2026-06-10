# 004 - AnalysisTemplate with Prometheus

## AnalysisTemplate

`AnalysisTemplate` định nghĩa một hoặc nhiều metric checks. Khi Rollout đến step `analysis`, controller tạo `AnalysisRun` từ template và truyền arguments như service name, namespace, threshold.

Một metric thường có:

- `interval`: tần suất query.
- `count`: số lần đo.
- `successCondition`: điều kiện để measurement thành công.
- `failureCondition`: điều kiện để measurement fail.
- `failureLimit`: số measurement fail được phép trước khi AnalysisRun fail.
- `provider.prometheus.address`: endpoint Prometheus.
- `query`: PromQL.

## Query error rate

Ví dụ đo tỷ lệ request lỗi 5xx trong 5 phút:

```promql
sum(rate(http_requests_total{service="checkout-api",status=~"5.."}[5m]))
/
sum(rate(http_requests_total{service="checkout-api"}[5m]))
```

Điều kiện canary đơn giản:

```yaml
successCondition: result[0] < 0.01
failureCondition: result[0] >= 0.01
failureLimit: 1
```

Nghĩa là error rate phải dưới 1%. Nếu error rate từ 1% trở lên quá số lần cho phép, analysis fail.

## Query latency p95

Với histogram Prometheus:

```promql
histogram_quantile(
  0.95,
  sum(rate(http_request_duration_seconds_bucket{service="checkout-api"}[5m])) by (le)
)
```

Điều kiện:

```yaml
successCondition: result[0] < 0.5
failureCondition: result[0] >= 0.5
```

Nghĩa là p95 latency phải dưới 500 ms.

## Query burn rate

Burn rate cho availability SLO:

```promql
(
  sum(rate(http_requests_total{service="checkout-api",status=~"5.."}[5m]))
  /
  sum(rate(http_requests_total{service="checkout-api"}[5m]))
)
/ 0.001
```

Nếu SLO 99.9%, error budget là `1 - 0.999 = 0.001`. Burn rate 10 nghĩa là đang tiêu error budget nhanh gấp 10 lần tốc độ cho phép.

## Lưu ý khi viết PromQL cho canary

- Query nên lọc đúng service/version/route canary nếu có label.
- Cần xử lý traffic thấp vì mẫu quá ít dễ gây nhiễu.
- Nên dùng window ngắn cho canary step, nhưng không quá ngắn đến mức metric thiếu dữ liệu.
- Dùng `clamp_min()` hoặc điều kiện traffic tối thiểu để tránh chia cho 0.
- Metric phải phản ánh user impact, không chỉ CPU/memory.


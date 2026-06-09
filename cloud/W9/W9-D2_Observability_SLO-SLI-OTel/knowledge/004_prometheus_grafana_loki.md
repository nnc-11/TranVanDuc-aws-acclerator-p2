# Prometheus, Grafana, Loki

## Prometheus

Prometheus là hệ thống metrics và alerting.

Nhiệm vụ chính:

- Scrape metrics từ endpoint như `/metrics`.
- Lưu time series.
- Query bằng PromQL.
- Tạo recording rules và alerting rules.

Ví dụ metric:

```text
http_requests_total{service="api",status="200"} 1234
http_request_duration_seconds_bucket{le="0.3"} 900
```

## Grafana

Grafana là công cụ dashboard và visualization.

Nhiệm vụ chính:

- Kết nối datasource như Prometheus, Loki.
- Vẽ dashboard.
- Hỗ trợ điều tra sự cố qua biểu đồ và log view.

## Loki

Loki là hệ thống log aggregation của Grafana stack.

Nhiệm vụ chính:

- Nhận log từ agent như Promtail.
- Lưu log theo label.
- Query bằng LogQL.

Ví dụ query:

```logql
{container="sample-app"} |= "error"
```

## Kết hợp trong lab

```text
Prometheus: metrics + SLO alert rules
Grafana: dashboard metrics/logs
Loki: logs
Promtail: ship container logs tới Loki
```

## Cần nhớ

- Prometheus không phải log database.
- Loki không thay Prometheus cho metrics.
- Grafana không tự tạo dữ liệu; Grafana đọc từ datasource.
- Label quá nhiều giá trị sẽ gây cardinality cao, cần tránh gắn user_id/request_id vào metric label.

## Nguồn

- Prometheus: https://prometheus.io/docs
- Grafana: https://grafana.com/docs/grafana/latest
- Loki: https://grafana.com/docs/loki/latest

# Observability Overview

## Định nghĩa ngắn

Observability là khả năng hiểu hệ thống đang hoạt động thế nào dựa trên dữ liệu nó phát ra.

Ba loại dữ liệu chính:

- Metrics: số đo theo thời gian, ví dụ request rate, error rate, latency.
- Logs: sự kiện dạng text/JSON, dùng để xem chuyện gì đã xảy ra.
- Traces: đường đi của một request qua nhiều service.

## Monitoring vs Observability

Monitoring trả lời: hệ thống có đang lỗi không?

Observability trả lời thêm: vì sao lỗi, lỗi ở service nào, request nào bị ảnh hưởng.

## Vì sao cần observability?

- Phát hiện lỗi sớm.
- Debug nhanh hơn khi production có sự cố.
- Đo trải nghiệm người dùng bằng SLI/SLO.
- Ra quyết định release dựa trên error budget.

## Luồng dữ liệu phổ biến

```text
Application
  -> OpenTelemetry SDK
  -> OpenTelemetry Collector
  -> Prometheus / Loki / tracing backend
  -> Grafana dashboard + alert
```

## Cần nhớ

- Metrics dùng tốt cho alert và xu hướng.
- Logs dùng tốt cho chi tiết sự kiện.
- Traces dùng tốt cho request đi qua nhiều service.
- Không nên alert trên mọi metric; ưu tiên alert theo SLO và user impact.

## Nguồn

- OpenTelemetry: https://opentelemetry.io/docs
- Google SRE Book: https://sre.google/sre-book/service-level-objectives

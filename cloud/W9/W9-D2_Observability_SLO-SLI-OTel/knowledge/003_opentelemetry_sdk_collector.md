# OpenTelemetry SDK + Collector

## OpenTelemetry là gì?

OpenTelemetry, thường viết là OTel, là bộ chuẩn và công cụ để instrument ứng dụng, thu thập telemetry và export sang backend quan sát.

OTel không phải là dashboard. Nó là lớp tạo và vận chuyển dữ liệu.

## OTel SDK

SDK chạy trong ứng dụng.

Nhiệm vụ chính:

- Tạo trace/span cho request.
- Tạo metric như counter, histogram.
- Gắn metadata như service name, environment, route.
- Export dữ liệu qua OTLP tới Collector hoặc backend.

Có hai kiểu instrumentation:

- Auto instrumentation: tự hook framework/library phổ biến.
- Manual instrumentation: developer tự thêm span, metric, attribute quan trọng.

## OTel Collector

Collector là service trung gian nhận, xử lý và gửi telemetry.

Pipeline thường có:

- Receiver: nhận dữ liệu, ví dụ OTLP.
- Processor: batch, memory limit, enrich, filter.
- Exporter: gửi ra backend, ví dụ Prometheus, Loki, Jaeger, Tempo.

Ví dụ:

```text
App SDK -> OTLP -> Collector -> Prometheus/Grafana/Tracing backend
```

## Vì sao dùng Collector?

- Không hard-code backend trong app.
- Có thể đổi backend mà ít sửa code.
- Gom telemetry từ nhiều app.
- Thêm batch, retry, filter, sampling tập trung.

## Cần nhớ

- SDK tạo telemetry trong app.
- Collector nhận và xử lý telemetry ngoài app.
- OTLP là protocol phổ biến để app gửi dữ liệu tới Collector.
- Luôn đặt `service.name` rõ ràng để query và dashboard dễ hơn.

## Nguồn

- OpenTelemetry Concepts: https://opentelemetry.io/docs/concepts
- OpenTelemetry Instrumentation: https://opentelemetry.io/docs/concepts/instrumentation
- OpenTelemetry Collector: https://opentelemetry.io/docs/collector

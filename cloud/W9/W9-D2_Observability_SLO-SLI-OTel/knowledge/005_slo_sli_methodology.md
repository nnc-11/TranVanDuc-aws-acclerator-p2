# SLO/SLI Methodology

## Định nghĩa

SLI là chỉ số đo chất lượng dịch vụ.

SLO là mục tiêu chất lượng dựa trên SLI trong một khoảng thời gian.

Error budget là phần lỗi được phép xảy ra mà vẫn đạt SLO.

Ví dụ:

```text
SLI: tỷ lệ request thành công
SLO: 99.9% request thành công trong 30 ngày
Error budget: 0.1% request được phép lỗi
```

## Availability SLI

Availability đo tỷ lệ request thành công.

Ví dụ:

```promql
good_requests / total_requests
```

Với HTTP service:

- Good: status không phải `5xx`.
- Bad: status `5xx`.

## Latency SLI

Latency đo tỷ lệ request đủ nhanh.

Ví dụ:

```text
99% request dưới 300ms
```

Với histogram Prometheus:

```promql
requests_le_300ms / total_requests
```

## Chọn SLO thế nào?

SLO nên:

- Gắn với trải nghiệm người dùng.
- Đủ rõ để đo được.
- Không quá cao nếu hệ thống chưa cần.
- Có window rõ ràng, ví dụ 7 ngày hoặc 30 ngày.

## Cần nhớ

- SLI là đo lường, SLO là mục tiêu.
- SLO 100% thường không thực tế và làm team không còn error budget.
- Alert tốt nên dựa trên tốc độ đốt error budget, không chỉ threshold CPU/RAM.
- Availability và latency thường là hai SLI quan trọng nhất cho web/API.

## Nguồn

- Google SRE Book: https://sre.google/sre-book/service-level-objectives
- Implementing SLOs: https://sre.google/workbook/implementing-slos

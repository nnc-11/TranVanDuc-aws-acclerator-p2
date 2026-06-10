# 006 - Burn Rate Integration

## Burn rate trong progressive delivery

Burn rate đo tốc độ tiêu thụ error budget so với tốc độ cho phép. Khi tích hợp vào canary, burn rate giúp quyết định version mới có đang làm tổn hại SLO hay không.

Ví dụ SLO availability 99.9%:

- Error budget = 0.1% = `0.001`.
- Error rate hiện tại = 1% = `0.01`.
- Burn rate = `0.01 / 0.001 = 10`.

Burn rate 10 nghĩa là nếu duy trì mức lỗi này, error budget sẽ bị tiêu nhanh gấp 10 lần.

## Vì sao burn rate tốt hơn error rate đơn lẻ?

Error rate 0.5% có thể nghiêm trọng với SLO 99.9%, nhưng ít nghiêm trọng hơn với SLO 99%. Burn rate chuẩn hóa error rate theo mục tiêu SLO, nên phù hợp để dùng chung giữa service có SLO khác nhau.

## Canary gate theo burn rate

Một canary gate thực tế có thể dùng:

- Fast burn: window 5m, fail nếu burn rate > 14.
- Slow burn: window 30m, fail nếu burn rate > 6.
- Latency p95: fail nếu vượt latency SLO.
- Traffic minimum: chỉ đánh giá khi có đủ request.

Trong lab, để ngắn gọn, dùng burn rate 5m:

```promql
(
  sum(rate(http_requests_total{service="checkout-api",status=~"5.."}[5m]))
  /
  clamp_min(sum(rate(http_requests_total{service="checkout-api"}[5m])), 1)
)
/ 0.001
```

Điều kiện:

```yaml
successCondition: result[0] < 6
failureCondition: result[0] >= 6
failureLimit: 1
```

## Thiết kế production

Nên kết hợp hai lớp:

- Rollout gate: analysis ngắn trong lúc canary để chặn release xấu.
- Alerting/SLO: multi-window burn rate alerts luôn chạy để phát hiện sự cố sau rollout.

Không nên phụ thuộc hoàn toàn vào canary gate, vì regression có thể chỉ xuất hiện sau khi traffic tăng cao, cache warm-up, job nền chạy, hoặc downstream đổi trạng thái.


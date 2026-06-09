# Multi-window Burn Rate Alert

## Burn rate là gì?

Burn rate là tốc độ tiêu thụ error budget.

Nếu SLO 99.9%, error budget là:

```text
1 - 0.999 = 0.001
```

Burn rate `1x` nghĩa là đang tiêu error budget đúng tốc độ cho phép. Burn rate `14.4x` nghĩa là tiêu nhanh hơn 14.4 lần.

## Vì sao cần multi-window?

Một window ngắn alert nhanh nhưng dễ noise.

Một window dài ít noise hơn nhưng reset chậm.

Multi-window kết hợp cả hai:

- Long window xác nhận lỗi có ý nghĩa.
- Short window xác nhận lỗi vẫn đang diễn ra.

## Fast page: 1h x 5m

Với SLO 99.9%:

```promql
error_ratio_1h > 14.4 * 0.001
and
error_ratio_5m > 14.4 * 0.001
```

Ý nghĩa:

- Đốt khoảng 2% error budget trong 1 giờ.
- Dùng để page nhanh khi lỗi nặng.

## Slow page: 6h x 30m

Với SLO 99.9%:

```promql
error_ratio_6h > 6 * 0.001
and
error_ratio_30m > 6 * 0.001
```

Ý nghĩa:

- Đốt khoảng 5% error budget trong 6 giờ.
- Dùng để bắt lỗi nhẹ hơn nhưng kéo dài.

## Alert mẫu

```promql
(
  error_ratio_1h > (14.4 * 0.001)
  and
  error_ratio_5m > (14.4 * 0.001)
)
or
(
  error_ratio_6h > (6 * 0.001)
  and
  error_ratio_30m > (6 * 0.001)
)
```

## Cần nhớ

- Threshold phụ thuộc SLO. SLO 99.9% có error budget `0.001`.
- Short window thường bằng 1/12 long window.
- Alert theo burn rate tốt hơn alert theo một vài lỗi đơn lẻ.
- Low-traffic service có thể cần cách alert khác vì dữ liệu ít và dễ nhiễu.

## Nguồn

- Alerting on SLOs: https://sre.google/workbook/alerting-on-slos

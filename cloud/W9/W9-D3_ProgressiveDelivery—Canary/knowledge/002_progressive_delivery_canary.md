# 002 - Progressive Delivery and Canary

## Progressive delivery là gì?

Progressive delivery là cách release thay đổi theo từng bước nhỏ, có kiểm soát, và dựa trên tín hiệu quan sát được. Thay vì đưa 100% user sang version mới ngay lập tức, hệ thống chỉ expose một phần traffic, đo metric, rồi quyết định tăng tiếp hoặc rollback.

Mục tiêu chính:

- Giảm blast radius khi version mới lỗi.
- Dùng automation thay vì chỉ dựa vào người quan sát dashboard.
- Gắn release với SLI/SLO thực tế như error rate, latency, saturation.
- Cho phép dừng, promote hoặc abort dựa trên dữ liệu.

## Canary deployment

Canary đưa một phần nhỏ traffic sang version mới, ví dụ 5%, 20%, 50%, rồi 100%. Sau mỗi bước, hệ thống kiểm tra metric để xác nhận version mới không làm xấu chất lượng dịch vụ.

Canary phù hợp khi:

- Ứng dụng có thể chạy song song nhiều version.
- Schema/database tương thích ngược hoặc đã có migration an toàn.
- Có metric đủ tin cậy để ra quyết định.
- Traffic có thể chia theo phần trăm bằng ingress/service mesh hoặc chia theo số pod.

Canary không phù hợp hoặc cần thận trọng khi:

- Worker queue không chia traffic rõ ràng.
- Version mới và cũ không tương thích dữ liệu.
- Request có session state khó định tuyến.
- Metric quá ít traffic nên không đủ ý nghĩa thống kê.

## Canary cơ bản và canary có traffic manager

Canary cơ bản thường dựa trên số lượng pod: nếu có 10 replicas và canary weight 20%, controller có thể chạy khoảng 2 pod version mới. Cách này đơn giản nhưng traffic thực tế có thể lệch nếu pod nhận tải không đều.

Canary với traffic manager dùng NGINX, Istio, AWS ALB, Gateway API hoặc service mesh để chia traffic theo phần trăm. Cách này chính xác hơn, hỗ trợ routing theo header/cookie và tách số pod khỏi traffic weight.

## Quy trình chuẩn

1. Deploy version mới dưới dạng ReplicaSet canary.
2. Route một phần nhỏ traffic sang canary.
3. Chạy analysis bằng Prometheus query.
4. Nếu metric tốt, tăng weight.
5. Nếu metric xấu, abort và rollback về stable.
6. Khi đạt 100%, promote version mới thành stable.


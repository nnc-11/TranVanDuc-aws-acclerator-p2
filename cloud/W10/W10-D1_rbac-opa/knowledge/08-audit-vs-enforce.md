# Audit Mode vs Enforce

1. Định nghĩa
- Audit: policy chỉ ghi log/alert, không chặn resource.
- Enforce: policy chặn hành động không hợp lệ (admission reject).

2. Khi nào dùng Audit
- Khi mới triển khai policy, để quan sát impact trước khi chặn.
- Đánh giá false positives và tune policy.

3. Khi nào dùng Enforce
- Khi policy đã được test và chấp nhận, cần bảo đảm an toàn runtime.

4. Cách chuyển từ Audit → Enforce
- Bật audit, thu thập logs, fix resources vi phạm, rồi chuyển sang enforce.
- Sử dụng tools: Gatekeeper `violation` CRs, OPA audit logs, hoặc audit webhook.
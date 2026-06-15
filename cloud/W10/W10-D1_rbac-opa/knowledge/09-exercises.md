# Bài tập thực hành D1

1. Tạo Role & RoleBinding
- Tạo namespace `demo`.
- Tạo `Role` cho phép `get,list` `pods`.
- Tạo `ServiceAccount` và `RoleBinding` và verify bằng `kubectl auth can-i`.

2.  token
- Tạo token short-lived cho `ServiceAccount` và cấu hình kubeconfig dùng token đó.

3. Viết Rego policy đơn giản
- Viết policy từ chặn `image:latest`.
- Test bằng `opa test` và sample admission input.

4. Triển khai Gatekeeper constraint
- Viết `ConstraintTemplate` + `Constraint` để bắt `Namespace` phải có label `owner`.
- Chạy audit mode, quan sát violations, sau đó chuyển sang enforce.

5. So sánh native
- Viết `ValidatingAdmissionPolicy` CEL tương đương chặn `image:latest`.
- So sánh behavior giữa Gatekeeper và native policy.

6. Report
- Ghi lại các lệnh đã chạy, YAML đã tạo, và ảnh chụp logs/violation.
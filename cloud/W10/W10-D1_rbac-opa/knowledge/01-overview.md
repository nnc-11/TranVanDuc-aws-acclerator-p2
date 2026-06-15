# D1 — Tổng quan

Mục tiêu bài học:
- Hiểu cơ bản về RBAC trong Kubernetes: `Role`, `ClusterRole`, `RoleBinding`, `ClusterRoleBinding`.
- Biết cách tạo và sử dụng `ServiceAccount` cho ứng dụng và CI.
- Sử dụng `kubectl auth can-i` để kiểm tra quyền.
- Nắm Rego cơ bản để viết policy với OPA.
- Hiểu khác biệt giữa Gatekeeper `ConstraintTemplate` và `Constraint`.
- Nắm ValidatingAdmissionPolicy (K8s 1.30+) và cách so sánh với Gatekeeper.
- Phân biệt `audit mode` vs `enforce` và áp dụng trong cluster.

Cấu trúc thư mục:
- 02-rbac.md
- 03-service-accounts.md
- 04-auth-can-i.md
- 05-opa-rego.md
- 06-gatekeeper.md
- 07-validatingadmissionpolicy.md
- 08-audit-vs-enforce.md
- 09-exercises.md
- 10-resources.md

Lưu ý: giữ nguyên các thuật ngữ tiếng Anh khi cần (ví dụ: `Role`, `ConstraintTemplate`).
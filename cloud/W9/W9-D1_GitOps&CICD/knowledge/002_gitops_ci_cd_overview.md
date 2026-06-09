# GitOps & CI/CD Overview

## Định nghĩa ngắn

GitOps là cách vận hành hệ thống bằng Git. Mọi trạng thái mong muốn của ứng dụng hoặc hạ tầng được khai báo trong Git, sau đó tool như ArgoCD hoặc Flux tự đồng bộ cluster theo Git.

CI/CD là pipeline tự động hóa từ lúc code thay đổi đến lúc sẵn sàng triển khai.

- CI: lint, test, build, scan.
- CD: đưa thay đổi đã được chấp nhận tới môi trường chạy thật.

## GitOps cần gì?

- Declarative: trạng thái được mô tả bằng YAML, Helm, Kustomize hoặc Terraform.
- Versioned: mọi thay đổi có commit history.
- Pull-based: controller trong cluster pull cấu hình từ Git.
- Reconciled: controller liên tục so sánh Git với cluster và sửa lệch.

## GitOps khác deploy thủ công

Deploy thủ công:

- Người vận hành chạy `kubectl apply`.
- Cluster có thể thay đổi mà Git không biết.
- Khó audit nếu nhiều người cùng thao tác.

Deploy GitOps:

- Người vận hành sửa Git qua pull request.
- ArgoCD hoặc Flux apply thay đổi.
- Git là nguồn sự thật để audit và rollback.

## Luồng phổ biến

1. Developer mở pull request.
2. CI chạy test, build, scan và plan.
3. Reviewer kiểm tra thay đổi.
4. Merge vào `main`.
5. GitOps controller phát hiện Git thay đổi.
6. Cluster được sync về trạng thái mới.

## Cần nhớ

- GitOps không thay CI. GitOps thường bắt đầu sau khi CI đã kiểm tra xong.
- Pipeline nên cập nhật manifest hoặc image tag trong Git, thay vì apply trực tiếp vào production.
- Không sửa cluster lâu dài bằng `kubectl`, vì sẽ làm cluster lệch Git.
- Secret cần giải pháp riêng như SOPS, Sealed Secrets hoặc External Secrets.

## Nguồn

- OpenGitOps: https://opengitops.dev
- GitHub Actions: https://docs.github.com/en/actions
- ArgoCD: https://argo-cd.readthedocs.io
- Flux: https://fluxcd.io/flux

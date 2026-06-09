# GitHub Actions: Plan on PR, Apply on Merge

## Định nghĩa ngắn

`plan-on-PR + apply-on-merge` là cách tách bước kiểm tra và bước thay đổi thật:

- Pull request: chỉ kiểm tra và tạo plan.
- Merge vào `main`: mới apply hoặc cập nhật GitOps repo.

Mục tiêu là để reviewer thấy tác động trước khi duyệt, còn production chỉ thay đổi sau khi code đã được merge.

## Plan on PR

Trigger thường dùng:

```yaml
on:
  pull_request:
    branches: [main]
```

Việc thường làm:

- Checkout code.
- Chạy format, validate, lint.
- Build hoặc render manifest.
- Chạy `terraform plan` nếu có IaC.
- Comment kết quả plan vào pull request.

Không nên cho workflow PR quyền apply production, đặc biệt với PR từ fork.

## Apply on Merge

Trigger thường dùng:

```yaml
on:
  push:
    branches: [main]
```

Việc thường làm:

- Checkout code sau merge.
- Validate lại.
- Chạy `terraform apply` nếu quản lý hạ tầng.
- Hoặc cập nhật image tag/manifest trong GitOps repo.
- ArgoCD hoặc Flux sync cluster.

## Ví dụ điều kiện job

```yaml
if: github.event_name == 'pull_request'
```

```yaml
if: github.event_name == 'push' && github.ref == 'refs/heads/main'
```

## Cần nhớ

- PR chỉ nên tạo plan, không apply production.
- Apply chỉ chạy từ nhánh tin cậy như `main`.
- Dùng `permissions` tối thiểu cần thiết.
- Dùng GitHub Environments nếu production cần approval.
- Secret không được expose cho workflow PR không tin cậy.

## Nguồn

- GitHub Actions: https://docs.github.com/en/actions
- OpenGitOps: https://opengitops.dev

# Official References

File này chỉ ghi nguồn nên đọc khi cần tra cứu thêm.

## OpenGitOps

- Link: https://opengitops.dev
- Dùng để học nguyên tắc GitOps.
- Cần nhớ: trạng thái mong muốn phải được khai báo, lưu version trong Git, được agent tự động pull và reconcile liên tục.

## GitHub Actions

- Link: https://docs.github.com/en/actions
- Dùng để học workflow, event trigger, job, secret, environment, permission.
- Cần nhớ: Actions chạy automation trong repository, thường dùng cho CI và bước chuẩn bị CD.

## ArgoCD

- Link: https://argo-cd.readthedocs.io
- Dùng để học Application, app-of-apps, sync policy, sync phases, sync waves, hooks.
- Cần nhớ: ArgoCD là GitOps CD tool cho Kubernetes, có UI mạnh để nhìn diff, sync và health.

## Flux

- Link: https://fluxcd.io/flux
- Dùng để học GitOps Toolkit, reconciliation, source controller, kustomize/helm controller và image automation.
- Cần nhớ: Flux là GitOps controller theo hướng Kubernetes-native, cấu hình chủ yếu bằng CRD.

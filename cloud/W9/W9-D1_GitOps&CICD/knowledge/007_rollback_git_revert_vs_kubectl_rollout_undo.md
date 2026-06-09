# Rollback: Git Revert vs kubectl Rollout Undo

## Định nghĩa ngắn

Rollback là đưa hệ thống về phiên bản ổn định trước đó.

Trong GitOps, rollback chuẩn là sửa Git trước, rồi để ArgoCD hoặc Flux sync cluster theo Git.

## `git revert`

`git revert` tạo commit mới để đảo ngược một commit cũ.

```bash
git revert <commit-sha>
git push
```

Ưu điểm:

- Đúng GitOps vì Git vẫn là nguồn sự thật.
- Có lịch sử rõ ràng để audit.
- ArgoCD hoặc Flux sẽ sync cluster theo commit revert.
- Phù hợp rollback production.

Nhược điểm:

- Không nhanh bằng thao tác trực tiếp trên cluster.
- Nếu lỗi đến từ nhiều commit, cần revert đúng commit liên quan.

## `kubectl rollout undo`

`kubectl rollout undo` rollback trực tiếp workload trong cluster, thường là Deployment.

```bash
kubectl rollout undo deployment/my-app -n my-namespace
```

Ưu điểm:

- Nhanh khi đang có sự cố.
- Hữu ích nếu GitOps controller đang lỗi hoặc sync quá chậm.

Nhược điểm:

- Không cập nhật Git.
- Cluster bị lệch khỏi trạng thái mong muốn trong Git.
- ArgoCD hoặc Flux có thể sync lại phiên bản lỗi nếu Git chưa được sửa.
- Không áp dụng cho mọi loại resource.

## So sánh nhanh

| Tiêu chí | `git revert` | `kubectl rollout undo` |
|---|---|---|
| Cập nhật Git | Có | Không |
| Đúng GitOps | Có | Chỉ là xử lý khẩn cấp |
| Audit | Rõ | Hạn chế |
| Tốc độ | Chậm hơn | Nhanh |
| Rủi ro bị GitOps ghi đè | Thấp | Cao |

## Quy tắc nhớ

- Rollback chuẩn: dùng `git revert`.
- Sự cố khẩn cấp: có thể dùng `kubectl rollout undo`, sau đó phải sửa Git ngay.
- Không để cluster chạy lâu ở trạng thái khác Git.

## Nguồn

- OpenGitOps: https://opengitops.dev
- ArgoCD: https://argo-cd.readthedocs.io
- Flux: https://fluxcd.io/flux

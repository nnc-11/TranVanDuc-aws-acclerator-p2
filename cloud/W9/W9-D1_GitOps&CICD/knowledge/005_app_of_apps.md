# App-of-Apps

## Định nghĩa ngắn

App-of-apps là pattern trong ArgoCD: một `Application` cha quản lý nhiều `Application` con.

Thay vì tạo từng app bằng UI, ta khai báo danh sách app trong Git. ArgoCD sync app cha, rồi app cha tạo hoặc cập nhật các app con.

## Dùng để làm gì?

- Bootstrap cluster mới từ một app gốc.
- Quản lý nhiều service trong một môi trường.
- Tách dev, staging, production rõ ràng.
- Giảm thao tác thủ công trong ArgoCD UI.

## Cấu trúc ví dụ

```text
gitops-repo/
  apps/
    root-app.yaml
    frontend.yaml
    backend.yaml
    ingress.yaml
    monitoring.yaml
```

`root-app.yaml` trỏ tới folder chứa các `Application` con như `frontend.yaml`, `backend.yaml`.

## Luồng hoạt động

1. Cài ArgoCD.
2. Tạo root Application.
3. Root Application sync folder `apps/`.
4. ArgoCD tạo các Application con.
5. Mỗi Application con sync workload riêng.

## Cần nhớ

- Root app nên quản lý app con, không nên nhồi toàn bộ workload vào root app.
- Đặt tên app, namespace và project rõ ràng.
- Cẩn thận với `prune`: xóa app khỏi Git có thể dẫn tới xóa resource trong cluster.
- Pattern này hợp với môi trường có nhiều service hoặc nhiều addon.

## Nguồn

- ArgoCD: https://argo-cd.readthedocs.io
- ArgoCD Cluster Bootstrapping: https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/

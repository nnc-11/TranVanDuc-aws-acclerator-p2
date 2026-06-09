# Sync Waves

## Định nghĩa ngắn

Sync waves là cơ chế của ArgoCD để điều khiển thứ tự apply resource khi sync.

Ví dụ: tạo Namespace trước, tạo CRD trước custom resource, chạy migration trước Deployment.

## Annotation chính

```yaml
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "1"
```

Quy tắc:

- Wave nhỏ chạy trước.
- Wave lớn chạy sau.
- Không khai báo thì mặc định là wave `0`.
- Có thể dùng số âm cho resource cần chạy sớm.

## Ví dụ thứ tự

```text
-1: Namespace
 0: ConfigMap, Secret, ServiceAccount
 1: CRD
 2: Database migration Job
 3: Backend Deployment
 4: Frontend Deployment
 5: Ingress
```

## Sync hooks liên quan

Hook dùng để chạy tác vụ ở thời điểm cụ thể:

- `PreSync`: trước khi sync resource chính.
- `Sync`: trong quá trình sync.
- `PostSync`: sau khi sync thành công.
- `SyncFail`: khi sync lỗi.

Hook thường dùng cho migration, smoke test hoặc cleanup.

## Cần nhớ

- Sync wave chỉ điều khiển thứ tự apply, không đảm bảo app đã thật sự sẵn sàng.
- Vẫn cần readiness probe, health check và retry logic tốt.
- Không cần dùng wave cho mọi resource; chỉ dùng khi có phụ thuộc rõ ràng.

## Nguồn

- ArgoCD: https://argo-cd.readthedocs.io
- Sync Phases and Waves: https://argo-cd.readthedocs.io/en/stable/user-guide/sync-waves/

# 003 - Argo Rollouts and Rollout CRD

## Argo Rollouts

Argo Rollouts là Kubernetes controller cung cấp progressive delivery cho ứng dụng Kubernetes. Nó dùng CRD `Rollout` thay cho `Deployment` khi cần canary, blue-green, traffic routing nâng cao, metric analysis và automated rollback.

Các thành phần chính:

- Rollout controller: reconcile Rollout CRD và quản lý ReplicaSet.
- Rollout CRD: mô tả workload, strategy và bước triển khai.
- AnalysisTemplate/AnalysisRun: kiểm tra metric hoặc job/web checks.
- Services: stable/canary service để traffic manager trỏ đến đúng pod.
- Kubectl plugin/dashboard: quan sát, promote, retry, abort.

## Rollout CRD khác Deployment thế nào?

Rollout có phần giống Deployment ở `replicas`, `selector`, `template`, nhưng thêm `strategy.canary` hoặc `strategy.blueGreen`.

Ví dụ khung canary:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: checkout-api
spec:
  replicas: 4
  selector:
    matchLabels:
      app: checkout-api
  template:
    metadata:
      labels:
        app: checkout-api
    spec:
      containers:
        - name: app
          image: ghcr.io/example/checkout-api:1.1.0
  strategy:
    canary:
      stableService: checkout-api-stable
      canaryService: checkout-api-canary
      steps:
        - setWeight: 10
        - pause:
            duration: 2m
        - analysis:
            templates:
              - templateName: checkout-canary-analysis
        - setWeight: 50
        - pause:
            duration: 5m
        - setWeight: 100
```

## Canary steps thường gặp

- `setWeight`: đặt phần trăm traffic hoặc tỷ lệ pod canary.
- `pause`: dừng rollout theo thời gian hoặc chờ promote thủ công.
- `analysis`: tạo AnalysisRun để kiểm tra metric.
- `setCanaryScale`: điều chỉnh số pod canary độc lập với traffic khi có traffic manager.
- `experiment`: chạy baseline/canary để so sánh nâng cao.

## Stable và canary service

Khi dùng traffic routing, Argo Rollouts cần biết service nào đại diện stable và service nào đại diện canary. Controller cập nhật selector của service để trỏ vào ReplicaSet đúng version.

Trong production, nên tách:

- `active/stable service`: nhận traffic chính.
- `canary service`: nhận traffic thử nghiệm.
- Ingress/service mesh rule: chia traffic giữa hai service.

## Lệnh vận hành hay dùng

```bash
kubectl argo rollouts get rollout checkout-api -n progressive-delivery --watch
kubectl argo rollouts promote checkout-api -n progressive-delivery
kubectl argo rollouts abort checkout-api -n progressive-delivery
kubectl argo rollouts retry rollout checkout-api -n progressive-delivery
kubectl argo rollouts undo checkout-api -n progressive-delivery
```


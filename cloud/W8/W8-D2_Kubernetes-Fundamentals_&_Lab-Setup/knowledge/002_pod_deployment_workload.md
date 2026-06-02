# 002 - Pod, Deployment and Workload

## Giới thiệu:

Bài này giới thiệu Pod và các controller quản lý workload trong Kubernetes. Sau khi học xong, người đọc có thể hiểu mối quan hệ giữa Pod, ReplicaSet, Deployment, StatefulSet và DaemonSet, đồng thời biết khi nào nên sử dụng từng loại.

## What is a Workload

Workload là thuật ngữ chung chỉ ứng dụng chạy trên Kubernetes.

Kubernetes quản lý ứng dụng thông qua các workload object như Deployment, StatefulSet và DaemonSet. Các workload này chịu trách nhiệm tạo và quản lý Pod trên cluster.

Workload
│
├── Deployment ──► Pod
├── StatefulSet ─► Pod
└── DaemonSet ───► Pod

Ví dụ:

- Web application → Deployment
- PostgreSQL → StatefulSet
- Log collector agent → DaemonSet

Ví dụ liên tưởng:

- Website công ty (Workload) cần người quản lý website như là cần 3 bản sao có thể thay thế lẫn nhau (Deployment)
- Workload là cái bạn muốn chạy. Deployment/StatefulSet/DaemonSet (controllers sẽ ở nội dung dưới) là cách Kubernetes quản lý cái đó.

Câu hỏi: Kubernetes thực sự nó chạy cái gì? (qua phần tiếp nè, nè nè nè :V)

## What is a Pod

Pod là đơn vị triển khai nhỏ nhất trong Kubernetes. Khi một Pod được tạo, Kubernetes Scheduler sẽ chọn một Node phù hợp để Pod chạy. (giả sử có node-1, node-2,node-3 thì scheduler sẽ quyếtđịnh việc pod chạy trên node nào)

Các container bên trong cùng 1 Pod sẽ chia sẻ:
- Network namespace
- IP address
- Volume

Pod
├── Container A
└── Container B

**Kubernetes chạy Pod. Pod chứa Container**

## Controllers Overview

Controller là thành phần trong Kubernetes chịu trách nhiệm theo dõi trạng thái thực tế của cluster và liên tục đưa hệ thống về trạng thái mong muốn **(Desired State)**.

Thay vì tạo và quản lý Pod thủ công, người dùng thường khai báo trạng thái mong muốn, sau đó controller sẽ tự động thực hiện các hành động cần thiết để duy trì trạng thái đó.

Controller là thành phần quản lý Pod

Ví dụ:

Nếu muốn ứng dụng luôn có 3 Pod chạy:

```text
Desired State:
3 Pods

Actual State:
2 Pods
```

Controller sẽ phát hiện sự khác biệt và tự động tạo thêm Pod để đưa hệ thống trở lại trạng thái mong muốn. 

Mối quan hệ giữa Controller và Pod:

```text
Controller
     ↓
    Pod
```

Trong Kubernetes, các controller phổ biến để quản lý workload bao gồm:

```text
Deployment
      ↓
     Pod

StatefulSet
      ↓
     Pod

DaemonSet
      ↓
     Pod
```

Mỗi controller được thiết kế cho một loại workload khác nhau:

- Deployment: ứng dụng stateless như web application, API, worker.
- StatefulSet: ứng dụng stateful như database hoặc message queue.
- DaemonSet: agent cần chạy trên mọi node như log collector hoặc monitoring agent.

## Deployment and ReplicaSet

Deployment là workload controller phổ biến nhất trong Kubernetes, thường được sử dụng cho các ứng dụng stateless như web application, API hoặc background worker.

Deployment không tạo Pod trực tiếp.

Thay vào đó, Deployment quản lý ReplicaSet và ReplicaSet chịu trách nhiệm tạo và duy trì các Pod.

Mối quan hệ:

```text
Deployment
      ↓
 ReplicaSet
      ↓
     Pod
      ↓
 Container
```

Vai trò của từng thành phần:

- Deployment: quản lý phiên bản ứng dụng, rolling update và rollback.
- ReplicaSet: đảm bảo luôn tồn tại số lượng Pod mong muốn.
- Pod: đơn vị triển khai nhỏ nhất trong Kubernetes.
- Container: tiến trình ứng dụng thực tế chạy bên trong Pod.

Ví dụ:

Một ứng dụng web cần luôn có 3 Pod chạy:

```text
Deployment
      ↓
 ReplicaSet (replicas=3)
      ↓
 Pod-1
 Pod-2
 Pod-3
```

Nếu một Pod gặp lỗi:

```text
Pod-2 ❌
```

ReplicaSet sẽ tự động tạo Pod mới:

```text
Pod-4 ✅
```

để luôn duy trì:

```text
3 Pods
```

Deployment còn hỗ trợ:

- Rolling Update: cập nhật phiên bản ứng dụng từng bước mà không gây downtime.
- Rollback: quay lại phiên bản trước khi bản cập nhật gặp sự cố.
- Scaling: tăng hoặc giảm số lượng Pod thông qua `spec.replicas`.

Trong thực tế, ReplicaSet hiếm khi được tạo trực tiếp mà thường được Deployment quản lý.

## StatefulSet

StatefulSet là workload controller dành cho các ứng dụng có trạng thái (stateful applications).

- Deployment phù hợp cho ứng dụng stateless. -> Web/API
- StatefulSet phù hợp cho ứng dụng stateful. -> Database

Khác với Deployment, StatefulSet cung cấp:

- Stable Pod name
- Stable network identity
- Persistent storage
- Ordered startup và shutdown

Ví dụ các ứng dụng thường sử dụng StatefulSet:

- PostgreSQL
- MySQL
- MongoDB
- Kafka
- Elasticsearch

Ví dụ:

```text
StatefulSet
      ↓
postgres-0
postgres-1
postgres-2
```

Nếu `postgres-1` gặp lỗi, Kubernetes sẽ tạo lại đúng Pod đó:

```text
postgres-1
```

thay vì tạo một Pod mới với tên ngẫu nhiên.

Khi nào dùng StatefulSet:

- Ứng dụng cần lưu dữ liệu lâu dài.
- Mỗi Pod cần danh tính riêng.
- Thứ tự khởi động hoặc tắt Pod là quan trọng.

## DaemonSet

DaemonSet là workload controller đảm bảo một Pod chạy trên mỗi Node trong cluster. Khi có Node mới được thêm vào cluster, DaemonSet sẽ tự động tạo Pod trên Node đó.

- Deployment: số Pod do người dùng quyết định.
- DaemonSet: số Pod phụ thuộc vào số lượng Node trong cluster. -> Agent trên Node

Ví dụ:

```text
Node-1  →  Log Agent
Node-2  →  Log Agent
Node-3  →  Log Agent
```

Nếu cluster có thêm Node:

```text
Node-4
```

DaemonSet sẽ tự động tạo:

```text
Node-4  →  Log Agent
```

Các ứng dụng thường sử dụng DaemonSet:

- Fluent Bit
- Fluentd
- Node Exporter
- Datadog Agent
- Falco

Khi nào dùng DaemonSet:

- Cần chạy một Pod trên mọi Node.
- Thu thập log.
- Thu thập metrics.
- Giám sát hoặc bảo mật ở cấp Node.

## Why use Controllers

Mặc dù có thể tạo Pod trực tiếp, nhưng Pod không tự phục hồi khi gặp lỗi và không hỗ trợ quản lý vòng đời ứng dụng.

Controllers giúp tự động quản lý Pod và duy trì trạng thái mong muốn của hệ thống.

Lợi ích chính:

- High availability: tự động tạo lại Pod khi Pod bị lỗi hoặc bị xóa.
- Scalability: dễ dàng tăng hoặc giảm số lượng Pod.
- Declarative management: khai báo trạng thái mong muốn thay vì quản lý thủ công.
- Rolling update: cập nhật ứng dụng từng bước mà không gây downtime.
- Rollback: quay lại phiên bản trước khi cập nhật gặp sự cố.

## Who is involved

- Developers: xây dựng container image và manifest để triển khai ứng dụng.
- Scheduler: chọn Node phù hợp để chạy Pod.
- kubelet: chạy và giám sát Pod trên Node.
- Controllers: Deployment, ReplicaSet, StatefulSet và DaemonSet chịu trách nhiệm duy trì trạng thái mong muốn.
- Platform / DevOps Engineers: vận hành cluster và quy trình CI/CD.

## When to use

- Dùng Pod (kubectl run / bare Pod) cho debug và test nhanh.
- Dùng Deployment cho ứng dụng stateless (web, API, worker) cần autoscale và rolling update.
- Dùng StatefulSet cho workload stateful (database, queue) cần stable network id và persistent storage.
- Dùng DaemonSet cho các agent cần chạy trên mọi node (log, metrics exporter).

## Where do Pods run

- Pod chạy trên các Node trong Kubernetes cluster.
- Kubernetes Scheduler lựa chọn Node phù hợp dựa trên tài nguyên và các ràng buộc của cluster.
- Một Node có thể chạy nhiều Pod.
- Pod thường được triển khai trong Namespace để phân tách tài nguyên giữa các môi trường hoặc nhóm người dùng.

Cluster
│
├── Node-1
│    ├── Pod-A
│    └── Pod-B
│
└── Node-2
     └── Pod-C

## How Pod and Deployment work 

Khi một Deployment được tạo, Kubernetes sẽ tự động tạo ReplicaSet. ReplicaSet sau đó tạo và duy trì các Pod theo số lượng mong muốn.

Các trường manifest quan trọng trong `Deployment`:

- `metadata.name`: tên object.
- `spec.replicas`: số bản sao mong muốn.
- `spec.selector`: xác định Pod nào thuộc Deployment.
- `spec.template.metadata.labels`: labels gắn cho Pod template.
- `spec.template.spec.containers`: khai báo container, `image`, `ports`, `resources`.

Best practice: 
- Luôn khai báo `spec.selector` rõ ràng.
- Sử dụng labels nhất quán giữa Deployment và Pod template.

## Commands (thực hành nhanh)

```bash
kubectl get pods
kubectl describe pod <pod-name>
kubectl get deployments
kubectl rollout status deployment/<deployment-name>
kubectl logs deployment/<deployment-name>
```

## Key Terms

- Workload: ứng dụng chạy trên Kubernetes.
- Controller: thành phần quản lý và duy trì trạng thái mong muốn của Pod.
- Pod: đơn vị triển khai nhỏ nhất trong Kubernetes.
- ReplicaSet: đảm bảo luôn tồn tại số lượng Pod mong muốn.
- Deployment: workload controller cho ứng dụng stateless.
- StatefulSet: workload controller cho ứng dụng stateful.
- DaemonSet: workload controller đảm bảo một Pod chạy trên mỗi Node.
- Scheduler: thành phần lựa chọn Node để chạy Pod.
- kubelet: agent chạy trên Node, chịu trách nhiệm thực thi và giám sát Pod.
- Node: máy (VM hoặc vật lý) chạy Pod.
- Namespace: cơ chế phân tách tài nguyên trong cluster.

## Further reading

- Kubernetes workloads: https://kubernetes.io/docs/concepts/workloads/



# 003 - Service and Kubernetes Networking

## Tóm tắt
> 002 đã có Pod. Thì bây giờ 003 làm sao truy cập Pod?

- Problems: Pod có IP động và có thể bị tạo lại bất cứ lúc nào. Điều này khiến việc truy cập ứng dụng trực tiếp thông qua IP Pod trở nên không đáng tin cậy.
- Bài này giới thiệu Service - cơ chế cung cấp endpoint ổn định để truy cập Pod trong Kubernetes. Đồng thời, bài học cũng trình bày các loại Service phổ biến (ClusterIP, NodePort, LoadBalancer, ExternalName), cơ chế service discovery thông qua DNS, và các thành phần mạng quan trọng như kube-proxy, CNI và CoreDNS.

## What problem does Service solve?

Pod có IP riêng nhưng IP này không ổn định. Khi Pod bị xóa hoặc tạo lại, Pod mới có thể nhận IP khác. Việc kết nối trực tiếp tới Pod có thể gây gián đoạn khi IP thay đổi.

```text
Pod A (10.244.1.5)
        ↓
Pod bị tạo lại
        ↓
Pod A (10.244.3.8)
```

Service giải quyết vấn đề này bằng cách cung cấp một endpoint ổn định để truy cập nhóm Pod. Client kết nối tới Service, Kubernetes tự động chuyển tiếp traffic tới các Pod phù hợp phía sau Service.

```text
Client
   ↓
Service
   ↓
Pods
```

## What is a Service?

Service là một Kubernetes object cung cấp endpoint ổn định để truy cập một hoặc nhiều Pod.

Service sử dụng **label selector** để xác định các Pod thuộc về Service và tự động chuyển tiếp traffic tới các Pod đó.

Khi Pod được tạo lại hoặc thay đổi IP, Service vẫn giữ nguyên endpoint và tiếp tục chuyển traffic tới các Pod phù hợp. 

Service đóng vai trò là một điểm truy cập cố định phía trước Pod. Dù Pod thay đổi IP, client vẫn kết nối tới cùng một Service và được chuyển tiếp tới Pod hiện tại.

```text
Service
   ↓
 app=demo-api
   ↓
Pod A Pod B Pod C
```

- Service cung cấp endpoint ổn định.
- Service chọn Pod bằng label selector.
- Service tự động route traffic tới Pod.

## Service Types

Kubernetes cung cấp nhiều loại Service để đáp ứng các nhu cầu truy cập khác nhau.

| Type | Use Case |
|--------|--------|
| ClusterIP | Truy cập nội bộ trong cluster |
| NodePort | Truy cập từ bên ngoài thông qua IP của Node |
| LoadBalancer | Truy cập từ bên ngoài thông qua Load Balancer |
| ExternalName | Ánh xạ tới dịch vụ bên ngoài bằng DNS |

ClusterIP    → Internal Service
NodePort     → Node IP + Port
LoadBalancer → External IP
ExternalName → External DNS

### ClusterIP

Cluster IP:

- Chỉ truy cập được trong cluster.
- Là loại Service mặc định.
- Phù hợp cho giao tiếp nội bộ giữa các ứng dụng.
- Nó không ngăn Pod gọi ra ngoài cluster.

Use Cases:

- Frontend gọi Backend API.
- Backend gọi Database.
- Giao tiếp giữa các service nội bộ.

### NodePort

- Truy cập được từ bên ngoài cluster.
- Sử dụng IP của Node và một port cố định được Kubernetes cấp phát.
- Kubernetes sẽ chuyển tiếp traffic từ NodePort tới các Pod phía sau Service.

```text
Client
   ↓
Node IP:30080
   ↓
NodePort Service
   ↓
Pods
```

Use Cases:

- Môi trường lab hoặc học tập.
- Kiểm tra ứng dụng từ máy bên ngoài cluster.
- Cluster không có Load Balancer.

### LoadBalancer

Thông tin cần nắm:

- Truy cập được từ bên ngoài cluster.
- Có địa chỉ IP bên ngoài (External IP).
- Kubernetes chuyển tiếp traffic từ LoadBalancer tới các Pod phía sau Service.

```text
Client
   ↓
LoadBalancer (External IP)
   ↓
Service
   ↓
Pods
```

Use Cases:

- Public Web Application.
- Public API.
- Production Workloads.

### ExternalName

- Không chuyển tiếp traffic tới Pod.
- Ánh xạ Service tới một tên DNS bên ngoài cluster.
- Cho phép ứng dụng trong cluster truy cập dịch vụ bên ngoài thông qua tên Service.

```text
Application
      ↓
ExternalName Service
      ↓
api.example.com
```

Use Cases:

- Truy cập database bên ngoài cluster.
- Truy cập API hoặc dịch vụ của bên thứ ba.
- Chuẩn hóa cách truy cập dịch vụ giữa môi trường development và production.
___
## DNS and Service Discovery

>Sau khi có Service, ứng dụng tìm Service bằng cách nào?

Kubernetes cung cấp DNS nội bộ để các Pod có thể tìm và truy cập Service bằng tên thay vì sử dụng IP.

Ví dụ:

```text
Frontend Pod
      ↓
backend-service
      ↓
Backend Pod
```

- Service có thể được truy cập bằng tên DNS.
- CoreDNS chịu trách nhiệm phân giải DNS trong cluster.
- DNS giúp ứng dụng không phụ thuộc vào địa chỉ IP.

___
## Kubernetes Networking Components

### kube-proxy

- Thực hiện việc định tuyến traffic từ Service tới Pod.
- Hoạt động trên mỗi Node trong cluster.

### CNI

- Cung cấp kết nối mạng cho Pod.
- Cho phép Pod giao tiếp với Pod khác trong cluster.

### CoreDNS

- Cung cấp DNS nội bộ cho Kubernetes.
- Cho phép Pod truy cập Service bằng tên DNS thay vì IP.



## Why use Service

- Cung cấp endpoint ổn định cho ứng dụng.
- Giảm phụ thuộc vào IP động của Pod.
- Hỗ trợ service discovery thông qua DNS.
- Tự động phân phối traffic tới các Pod phù hợp.
- Đơn giản hóa việc giao tiếp giữa các ứng dụng trong cluster.

## Who is involved

- Pod: consumer/producer của traffic.
- Service: định nghĩa cách route tới Pod.
- kube-proxy hoặc dataplane CNI: thực thi rules routing/load balancing.
- CoreDNS: cung cấp DNS nội bộ cho service discovery.

## Commands (Quick Practice)

Xem danh sách Service:

```bash
kubectl get svc
```

Xem chi tiết Service:

```bash
kubectl describe svc <service-name>
```

Forward port từ Service về máy local:

```bash
kubectl port-forward svc/<service-name> 8080:80
```

Truy cập Service trên Minikube:

```bash
minikube service <service-name>
```

## Key Terms

- Service: endpoint ổn định để truy cập Pod.
- ClusterIP: Service nội bộ trong cluster.
- NodePort: Service truy cập qua Node IP và Port.
- LoadBalancer: Service có External IP.
- ExternalName: Service ánh xạ tới DNS bên ngoài.
- kube-proxy: định tuyến traffic từ Service tới Pod.
- CNI: cung cấp kết nối mạng cho Pod.
- CoreDNS: DNS nội bộ của Kubernetes.
- Service Discovery: cơ chế tìm Service bằng DNS.

## Further Reading

- Services: https://kubernetes.io/docs/concepts/services-networking/service/
- DNS for Services and Pods: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/
- Networking Concepts: https://kubernetes.io/docs/concepts/cluster-administration/networking/
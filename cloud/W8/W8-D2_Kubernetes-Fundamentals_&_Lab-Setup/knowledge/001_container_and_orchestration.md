# 001 - Container and Orchestration

## What is Container and Orchestration

- Container: một môi trường chạy nhẹ và di động, đóng gói ứng dụng cùng các binary, thư viện và cấu hình cần thiết. Container chia sẻ kernel của host nhưng được cô lập về process, network và filesystem, giúp ứng dụng chạy nhất quán trên nhiều môi trường.
- Image: một artifact immutable, read-only chứa filesystem của container và metadata; image là bản mẫu để khởi tạo container.
- Container runtime: phần mềm chịu trách nhiệm tạo và quản lý process container từ image (ví dụ: containerd, runc, CRI-O).
- Orchestration: quản lý tự động nhiều container ở quy mô lớn — scheduling, deployment, service discovery, scaling, networking và self-healing (Kubernetes là một hệ thống orchestration phổ biến).
### Example
- Một image: nginx:1.27
- Khi chạy: docker run nginx:1.27; container runtime sẽ tạo một container từ image nginx:1.27 
- Nếu cần chạy 100 container nginx trên nhiều máy chủ khác nhau, một hệ thống orchestration như Kubernetes sẽ chịu trách nhiệm phân phối, giám sát và tự động khôi phục các container khi xảy ra lỗi.

## Why use Container and Orchestration

- Reproducibility (tái tạo): image lưu giữ môi trường cố định, giảm lỗi "chạy được trên máy tôi".
- Portability (di động): container có thể chạy trên bất kỳ host nào có runtime tương thích, dễ di chuyển môi trường.
- Resource efficiency (hiệu quả tài nguyên): container chia sẻ kernel của host và thường gọn nhẹ hơn VM.
- Scalability & resilience (mở rộng và bền bỉ): orchestrator tự động scale, cập nhật (rolling update) và phục hồi khi lỗi.
- CI/CD integration: image dễ tích hợp vào pipeline build và release, hỗ trợ deployment immutable và versioning.

## Who is involved in Container and Orchestration

### People

- Developers: xây dựng image ứng dụng và đảm bảo ứng dụng tương thích với container.
- Platform/DevOps engineers: provision và vận hành runtime, registry và cluster orchestration.
- Site Reliability Engineers (SREs): thiết lập monitoring, SLO/SLA và quy trình vận hành.

### System Components

- Kubernetes control plane: API Server, Scheduler, Controller Manager và etcd duy trì trạng thái mong muốn của cluster.
- kubelet: agent chạy trên mỗi node, giao tiếp với control plane và quản lý workload.
- Container runtime: thực thi container trên node (containerd, CRI-O, ...).

## When to use Container and Orchestration

- Dùng khi ứng dụng cần môi trường chạy nhất quán, triển khai tự động, mở rộng linh hoạt hoặc vận hành trên nhiều môi trường khác nhau. Mô hình microservices đặc biệt phù hợp nhưng không phải là yêu cầu bắt buộc.
- Không cần thiết nếu ứng dụng đơn giản, single-instance, hoặc khi cần isolation phần cứng mạnh hơn (trường hợp dùng VM).
- **microservices** được áp dụng chỉ khi nó là trường hợp hưởng lợi từ container/orchestration. 

## Where do containers run

- Containers cần kernel tương thích. Ví dụ, Linux containers sử dụng Linux kernel. Trên macOS và Windows, Docker Desktop sử dụng một Linux VM hoặc WSL2 để cung cấp môi trường kernel cần thiết cho Linux containers.(Docker Desktop -> Linux VM/WSL2 -> Linux Container)
- Trong môi trường production, containers chạy trên node do orchestrator quản lý (các dịch vụ Kubernetes cloud-managed hoặc cluster on-premise). (Production -> Kubernetes Node (Linux) -> Container Runtime -> Container)
- **Container không tự mang kernel theo nó.**

## How Container and Orchestration work

1. Build: tạo image (ví dụ, bằng `Dockerfile`) đóng gói các lớp file hệ thống và dependency.
2. Publish: đẩy image lên registry (Docker Hub, private registry, cloud registry).
3. Describe: khai báo trạng thái mong muốn của ứng dụng bằng YAML manifest (ví dụ: Deployment, Service).
4. Deploy: apply manifest lên Kubernetes; control plane quyết định node phù hợp để chạy workload.
5. Run: kubelet và container runtime trên node khởi tạo container từ image.
6. Operate: giám sát, scale, cập nhật (rollout) và rollback khi cần.

Developer -> Build Image -> Registry -> Kubernetes Manifest -> Kubernetes Cluster -> Pod -> Container

Ví dụ lệnh cơ bản:

```bash
docker build -t myapp:1.0 .
docker run --rm -it myapp:1.0 /bin/sh
minikube start
kubectl apply -f deployment.yaml
kubectl get pods -A
```

## Key Terms

- Image: artifact immutable bao gồm các lớp filesystem và metadata.
- Container: phiên bản đang chạy của một image, có thêm một writable layer.
- Layer: delta filesystem tái sử dụng giữa các image để tăng hiệu quả cache và phân phối.
- Runtime: thành phần thực thi container (ví dụ: containerd, runc).
- OCI (Open Container Initiative): tiêu chuẩn định nghĩa định dạng image và runtime container.
- CRI (Container Runtime Interface): giao diện để Kubernetes giao tiếp với container runtime.
- Registry: dịch vụ lưu trữ và phân phối image.
- Pod: đơn vị deploy nhỏ nhất trong Kubernetes, chứa một hoặc nhiều container chia sẻ mạng và lưu trữ.
- Node: máy (VM hoặc vật lý) chạy Pod.
- Control plane: tập hợp các thành phần quản lý cluster (API Server, Scheduler, Controller Manager, etcd), duy trì trạng thái mong muốn và điều phối workload.

## Further reading

- Docker documentation: https://docs.docker.com/get-started/
- Kubernetes concepts: https://kubernetes.io/docs/concepts/
- Minikube documentation: https://minikube.sigs.k8s.io/docs/



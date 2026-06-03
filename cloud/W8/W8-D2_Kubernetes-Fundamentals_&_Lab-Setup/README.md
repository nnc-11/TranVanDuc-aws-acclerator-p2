# W8-D2 - Kubernetes Fundamentals & Lab Setup

## Mục tiêu

Chuẩn bị môi trường Kubernetes local và học các khái niệm cơ bản:

* Docker Desktop
* minikube
* kubectl
* Pod, Deployment, Service
* Probe, ConfigMap, Secret
* NetworkPolicy

## Trạng thái hiện tại

Đã cài và kiểm tra xong trên máy:

* Docker Desktop: OK
* Docker Compose: OK
* minikube: OK
* kubectl: OK
* Kubernetes node `minikube`: `Ready`

Lệnh verify đã chạy thành công:

```bash
docker run --rm hello-world
./install_tools/bin/minikube status
./install_tools/bin/kubectl get nodes
./install_tools/bin/kubectl get namespaces
```

## Thứ tự xem

1. Đọc `install_tools/001_docker_desktop.md`
2. Đọc `install_tools/002_minikube.md`
3. Đọc `install_tools/003_kubectl.md`
4. Đọc `knowledge/001_container_and_orchestration.md`
5. Đọc `knowledge/002_pod_deployment_workload.md`
6. Đọc `knowledge/003_service_and_kubernetes_networking.md`
7. Đọc `knowledge/004_probes_configmap_secret.md`
8. Đọc `knowledge/005_networkpolicy.md`
9. Làm quiz trong `assessment/quiz.md`
10. Ghi câu trả lời vào `assessment/answers.md`

## Lệnh kiểm tra nhanh

```bash
cd install_tools
env MINIKUBE_HOME="$PWD/.minikube" ./bin/minikube status
./bin/kubectl get nodes
./bin/kubectl get namespaces
```

## note

Lab chạy local bằng Docker Desktop và minikube, không cần tạo tài nguyên cloud.

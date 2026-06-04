# Evidence

File này ghi bằng chứng lab đã apply thành công trước khi cleanup.

## Thông tin triển khai

- AWS Region: `ap-southeast-1`
- Kubernetes runtime: Minikube trên EC2
- EC2 instance type: `c7i-flex.large`
- Application: `hashicorp/http-echo:1.0`
- Service exposure: ALB -> EC2 NodePort `30080` -> Kubernetes Service -> Pod

## ALB URL

```text
http://k8s-minikube-alb-alb-1684144345.ap-southeast-1.elb.amazonaws.com
```

![ALB URL screenshot](picture/ALB%20URL.png)

## ALB evidence

```bash
curl -i http://k8s-minikube-alb-alb-1684144345.ap-southeast-1.elb.amazonaws.com
```

![ALB evidence screenshot](picture/ALB%20evidence.png)

## Kubernetes evidence

Lấy evidence từ EC2 console output bằng lệnh:

```bash
INSTANCE_ID=$(terraform output -raw minikube_instance_id)

aws ec2 get-console-output \
  --region ap-southeast-1 \
  --instance-id "$INSTANCE_ID" \
  --latest \
  --output text \
| sed -n '/Kubernetes resources:/,/Bootstrap completed/p' \
| sed 's/^\[[^]]*\] cloud-init\[[0-9]*\]: //' \
| grep -E 'pod/hello-app|service/hello-app|deployment.apps/hello-app|Bootstrap completed'
```

Output quan trọng:

```text
pod/hello-app-86b7db5474-lrzp4   1/1   Running   0   19s   10.244.0.4
pod/hello-app-86b7db5474-rnhsr   1/1   Running   0   19s   10.244.0.2
service/hello-app                NodePort        80:30080/TCP
deployment.apps/hello-app        2/2             2 available
Bootstrap completed at 2026-06-04T15:05:34+00:00
```

![Kubernetes evidence screenshot](picture/Kubernetes%20evidence.png)

Kết luận: application chạy trong Kubernetes/Minikube, không chạy trực tiếp trên EC2. Service `NodePort` expose port `30080` để ALB forward traffic vào cluster.

## Cleanup

Sau khi lấy evidence, destroy toàn bộ tài nguyên:

```bash
cd terraform
terraform destroy
```

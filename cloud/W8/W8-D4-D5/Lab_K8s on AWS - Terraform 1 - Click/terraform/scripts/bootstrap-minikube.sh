#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="/var/log/minikube-bootstrap.log"
exec > >(tee -a "$LOG_FILE") 2>&1

KUBECTL_VERSION="v1.33.0"
MINIKUBE_VERSION="v1.38.1"
CRICTL_VERSION="v1.33.0"
CNI_PLUGINS_VERSION="v1.6.2"

echo "Starting Minikube bootstrap at $(date -Is)"

export HOME="/root"
export MINIKUBE_HOME="/root/.minikube"
export KUBECONFIG="/root/.kube/config"
mkdir -p "/root/.kube" "/root/.minikube"

dnf update -y
dnf install -y conntrack iproute iptables socat ebtables ethtool tar gzip
dnf install -y docker

systemctl enable --now containerd
systemctl enable --now docker

if ! command -v kubectl >/dev/null 2>&1; then
  curl -fsSL -o /usr/local/bin/kubectl "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
  chmod +x /usr/local/bin/kubectl
fi

if ! command -v minikube >/dev/null 2>&1; then
  curl -fsSL -o /usr/local/bin/minikube "https://github.com/kubernetes/minikube/releases/download/${MINIKUBE_VERSION}/minikube-linux-amd64"
  chmod +x /usr/local/bin/minikube
fi

if ! command -v crictl >/dev/null 2>&1; then
  curl -fsSL -o /tmp/crictl.tar.gz "https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-amd64.tar.gz"
  tar -C /usr/local/bin -xzf /tmp/crictl.tar.gz crictl
  chmod +x /usr/local/bin/crictl
  rm -f /tmp/crictl.tar.gz
fi

if [ ! -x /opt/cni/bin/bridge ]; then
  mkdir -p /opt/cni/bin
  curl -fsSL -o /tmp/cni-plugins.tgz "https://github.com/containernetworking/plugins/releases/download/${CNI_PLUGINS_VERSION}/cni-plugins-linux-amd64-${CNI_PLUGINS_VERSION}.tgz"
  tar -C /opt/cni/bin -xzf /tmp/cni-plugins.tgz
  rm -f /tmp/cni-plugins.tgz
fi

minikube start \
  --driver=none \
  --kubernetes-version="${KUBECTL_VERSION}" \
  --container-runtime=containerd \
  --memory=2500mb \
  --force

for _ in $(seq 1 60); do
  if kubectl get nodes >/dev/null 2>&1; then
    break
  fi
  sleep 5
done

kubectl apply -f /opt/lab/k8s/namespace.yaml
kubectl apply -f /opt/lab/k8s/deployment.yaml
kubectl apply -f /opt/lab/k8s/service.yaml
kubectl rollout status deployment/hello-app -n lab --timeout=300s

echo "Kubernetes resources:"
kubectl get all -n lab -o wide

echo "Bootstrap completed at $(date -Is)"

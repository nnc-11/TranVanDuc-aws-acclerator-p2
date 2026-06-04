data "cloudinit_config" "minikube" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = "#cloud-config\n${yamlencode({
      write_files = [
        {
          path        = "/opt/lab/scripts/bootstrap-minikube.sh"
          permissions = "0755"
          encoding    = "b64"
          content     = filebase64("${path.module}/scripts/bootstrap-minikube.sh")
        },
        {
          path        = "/opt/lab/k8s/namespace.yaml"
          permissions = "0644"
          encoding    = "b64"
          content     = filebase64("${path.module}/k8s/namespace.yaml")
        },
        {
          path        = "/opt/lab/k8s/deployment.yaml"
          permissions = "0644"
          encoding    = "b64"
          content     = filebase64("${path.module}/k8s/deployment.yaml")
        },
        {
          path        = "/opt/lab/k8s/service.yaml"
          permissions = "0644"
          encoding    = "b64"
          content     = filebase64("${path.module}/k8s/service.yaml")
        }
      ]
      runcmd = [
        ["bash", "/opt/lab/scripts/bootstrap-minikube.sh"]
      ]
    })}"
  }
}

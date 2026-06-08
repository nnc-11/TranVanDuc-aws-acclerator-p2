output "alb_dns_name" {
  description = "Public ALB DNS name."
  value       = aws_lb.this.dns_name
}

output "application_url" {
  description = "HTTP URL for the deployed application."
  value       = "http://${aws_lb.this.dns_name}"
}

output "minikube_instance_id" {
  description = "EC2 instance ID running Minikube."
  value       = aws_instance.minikube.id
}

output "test_command" {
  description = "Command to test the application after ALB targets are healthy."
  value       = "curl http://${aws_lb.this.dns_name}"
}

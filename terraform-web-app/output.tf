output "instance_public_ip" {
  value = aws_instance.minikube_host.public_ip
}

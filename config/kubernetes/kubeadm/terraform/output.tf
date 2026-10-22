output "master_public_ip" {
  description = "Public IP address of the Control Plane (Master) node"
  value       = aws_instance.master.public_ip
}

output "master_private_ip" {
  description = "Private IP address of the Control Plane (Master) node (needed for worker joins)"
  value       = aws_instance.master.private_ip
}

output "worker_public_ips" {
  description = "Public IP addresses of the Worker nodes"
  value       = aws_instance.workers[*].public_ip
}

output "security_group_id" {
  description = "ID of the created Kubernetes Security Group"
  value       = aws_security_group.k8s_sg.id
}

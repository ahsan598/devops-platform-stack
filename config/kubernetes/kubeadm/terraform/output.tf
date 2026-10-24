# --------------------------------------------------
# Control Plane Outputs
# --------------------------------------------------
output "master_instance_id" {
  description = "Control plane EC2 instance ID"
  value       = aws_instance.master.id
}

output "master_public_ip" {
  description = "Control plane public IPv4 address"
  value       = aws_instance.master.public_ip
}

output "master_private_ip" {
  description = "Control plane private IPv4 address"
  value       = aws_instance.master.private_ip
}

# --------------------------------------------------
# Worker Outputs
# --------------------------------------------------
output "worker_instance_ids" {
  description = "Worker EC2 instance IDs"
  value       = aws_instance.workers[*].id
}

output "worker_public_ips" {
  description = "Worker public IPv4 addresses"
  value       = aws_instance.workers[*].public_ip
}

output "worker_private_ips" {
  description = "Worker private IPv4 addresses"
  value       = aws_instance.workers[*].private_ip
}

# --------------------------------------------------
# Security Group Output
# --------------------------------------------------
output "k8s_security_group_id" {
  description = "Kubernetes cluster security group ID"
  value       = aws_security_group.k8s_sg.id
}

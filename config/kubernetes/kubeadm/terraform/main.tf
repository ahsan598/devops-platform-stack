#--------------------------------------------------
# Terraform Configuration for Kubernetes Cluster on AWS
#--------------------------------------------------
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 6.69.0"
    }
  }
}

#--------------------------------------------------
# AWS Provider
#--------------------------------------------------
provider "aws" {
  region = var.region
}

#--------------------------------------------------
# Default VPC
#--------------------------------------------------
data "aws_vpc" "default" {
  default = true
}

#--------------------------------------------------
# Default Subnet
#--------------------------------------------------
data "aws_subnet" "default" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = var.availability_zone
  default_for_az    = true
}

#--------------------------------------------------
# Security Group for Kubernetes Cluster
#--------------------------------------------------
resource "aws_security_group" "k8s_sg" {
  name        = "k8s-cluster-sg"
  description = "Security group for Kubernetes control plane and worker nodes"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name        = "k8s-cluster-sg"
    Project     = "learning"
    ManagedBy    = "Terraform"
  }
}

#--------------------------------------------------
# Ingress Rules for Kubernetes Cluster
#--------------------------------------------------

# SSH - Allow access only from your trusted public IP.
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.k8s_sg.id

  description = "SSH access from trusted public IP"
  cidr_ipv4   = var.my_public_ip
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"

  tags = {
    Name = "ssh-access"
  }
}

# Kubernetes API Server - Administrative access.
resource "aws_vpc_security_group_ingress_rule" "kubernetes_api_admin" {
  security_group_id = aws_security_group.k8s_sg.id

  description = "Kubernetes API access from trusted public IP"
  cidr_ipv4   = var.my_public_ip
  from_port   = 6443
  to_port     = 6443
  ip_protocol = "tcp"

  tags = {
    Name = "kubernetes-api-admin"
  }
}

# Kubernetes API Server - Permit communication between cluster nodes.
resource "aws_vpc_security_group_ingress_rule" "kubernetes_api_internal" {
  security_group_id = aws_security_group.k8s_sg.id

  description                  = "Kubernetes API access between cluster nodes"
  referenced_security_group_id = aws_security_group.k8s_sg.id
  from_port                    = 6443
  to_port                      = 6443
  ip_protocol                  = "tcp"

  tags = {
    Name = "kubernetes-api-internal"
  }
}

# Etcd - Permit communication between cluster nodes.
resource "aws_vpc_security_group_ingress_rule" "etcd" {
  security_group_id = aws_security_group.k8s_sg.id

  description                  = "etcd client and peer communication"
  referenced_security_group_id = aws_security_group.k8s_sg.id
  from_port                    = 2379
  to_port                      = 2380
  ip_protocol                  = "tcp"

  tags = {
    Name = "etcd"
  }
}

# Kubelet API - Permit communication between cluster nodes.
resource "aws_vpc_security_group_ingress_rule" "kubelet" {
  security_group_id = aws_security_group.k8s_sg.id

  description                  = "Kubelet API access between cluster nodes"
  referenced_security_group_id = aws_security_group.k8s_sg.id
  from_port                    = 10250
  to_port                      = 10250
  ip_protocol                  = "tcp"

  tags = {
    Name = "kubelet-api"
  }
}

# Flannel CNI - Permit communication between cluster nodes.
resource "aws_vpc_security_group_ingress_rule" "flannel_vxlan" {
  security_group_id = aws_security_group.k8s_sg.id

  description                  = "Flannel VXLAN node-to-node traffic"
  referenced_security_group_id = aws_security_group.k8s_sg.id
  from_port                    = 8472
  to_port                      = 8472
  ip_protocol                  = "udp"

  tags = {
    Name = "flannel-cni-vxlan"
  }
}

# NodePort Services - Allow access to NodePort services from your trusted public IP.
resource "aws_vpc_security_group_ingress_rule" "nodeport" {
  security_group_id = aws_security_group.k8s_sg.id

  description = "Kubernetes NodePort testing from trusted public IP"
  cidr_ipv4   = var.my_public_ip
  from_port   = 30000
  to_port     = 32767
  ip_protocol = "tcp"

  tags = {
    Name = "nodeport-access"
  }
}

#--------------------------------------------------
# Egress Rules for Kubernetes Cluster
#--------------------------------------------------

# Allow all outbound IPv4 traffic from the security group.
resource "aws_vpc_security_group_egress_rule" "allow_all_ipv4" {
  security_group_id = aws_security_group.k8s_sg.id

  description = "Allow outbound IPv4 traffic"
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  tags = {
    Name = "allow-all-ipv4"
  }
}

#--------------------------------------------------
# Kubernetes Control Plane Instance
#--------------------------------------------------
resource "aws_instance" "master" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = data.aws_subnet.default.id
  vpc_security_group_ids      = [aws_security_group.k8s_sg.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name        = "k8s-master"
    Role        = "control-plane"
    Project = "learning"
    ManagedBy   = "Terraform"
  }
}

#--------------------------------------------------
# Kubernetes Worker Nodes
#--------------------------------------------------
resource "aws_instance" "workers" {
  count = 2

  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = data.aws_subnet.default.id
  vpc_security_group_ids      = [aws_security_group.k8s_sg.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name        = "k8s-worker-${count.index + 1}"
    Role        = "worker"
    Project = "learning"
    ManagedBy   = "Terraform"
  }
}

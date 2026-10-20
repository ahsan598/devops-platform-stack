data "aws_vpc" "default" {
  default = true
}

provider "aws" {
  region = var.region
}

# Automated Security Group for Kubernetes Cluster (Control Plane & Workers)
resource "aws_security_group" "k8s_sg" {
  name        = "k8s-cluster-sg"
  description = "Security group for Kubernetes master and worker nodes"
  vpc_id      = data.aws_vpc.default.id

  # SSH Access
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Kubernetes API Server
  ingress {
    description = "Kubernetes API Server"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # etcd server client API
  ingress {
    description = "etcd server client API"
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Kubelet API
  ingress {
    description = "Kubelet API"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # kube-scheduler & kube-controller-manager
  ingress {
    description = "Kube Scheduler & Controller"
    from_port   = 10259
    to_port     = 10257
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Flannel CNI Overlay Network (UDP)
  ingress {
    description = "Flannel CNI"
    from_port   = 8472
    to_port     = 8472
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # NodePort Services Range
  ingress {
    description = "NodePort Services"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all traffic within the same security group (Cluster internal communication)
  ingress {
    description = "Internal Cluster Communication"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  # Outbound Internet Access
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s-cluster-sg"
  }
}

# Control Plane (Master Node)
resource "aws_instance" "master" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]

  associate_public_ip_address = true

  root_block_device {
    volume_size = 20 # Recommended size for K8s master
    volume_type = "gp3"
  }

  tags = {
    Name = "k8s-master"
    Role = "master"
  }
}

# Worker Nodes
resource "aws_instance" "workers" {
  count                  = 2
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]

  associate_public_ip_address = true

  root_block_device {
    volume_size = 20 # Recommended size for K8s workers
    volume_type = "gp3"
  }

  tags = {
    Name = "k8s-worker-${count.index + 1}"
    Role = "worker"
  }
}

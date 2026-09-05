# Local Kubernetes Setup using KIND

This directory contains the multi-node **KIND (Kubernetes IN Docker)** configuration and setup instructions for local cluster provisioning, image management, and port mapping.

### 🏗️ Cluster Topology
The cluster is provisioned with 4 nodes to mimic a real-world multi-node Kubernetes environment:
```sh
KIND Cluster: dev-cluster
├── dev-cluster-control-plane (NodePort Ingress Mappings)
├── dev-cluster-worker  (Workloads)
├── dev-cluster-worker2 (Workloads)
└── dev-cluster-worker3 (Workloads)
```

### 📂 Configuration (`kind-config.yaml`)
This configuration maps critical DevOps NodePorts directly to your host machine (localhost).

### 🌐 Mapped Service Ports Summary
Once deployed, NodePort services listening on these ports inside the cluster become accessible on your host machine:
| Service Target | Container Port | Host Port |
| :--- | :--- | :--- |
| **Nginx Ingress** | `30080` | `30080` |
| **ArgoCD** | `30082` | `30082` |
| **Grafana** | `30030` | `30030` |
| **Prometheus** | `30090` | `30090` |

### 🚀 Quick Setup Guide

**1. Provision Cluster**
```sh
kind create cluster --name dev-cluster --config kind-config.yaml
```

**2. Verify Deployment**
```sh
# Verify API server and cluster connectivity
kubectl cluster-info

# Verify all 4 nodes are Ready
kubectl get nodes
```

**3. Manage Contexts**
```sh
# List all contexts
kubectl config get-contexts

# Ensure active context is set to dev-cluster
kubectl config use-context kind-dev-cluster

# verify context
kubectl config current-context
```

### 📦 Local Docker Image Management
Since KIND runs `containerd` inside Docker nodes, locally built your custom docker images must be loaded into the cluster before deployment:
```sh
# 1. Build image on host
docker build -t my-app:1.0 .

# 2. Load your custom image into KIND cluster
kind load docker-image my-app:1.0 --name dev-cluster

# 3. Verify image inside containerd cache
docker exec -it dev-cluster-control-plane crictl images | grep my-app
```

### 🛠️ Operational & Maintenance Commands
Cluster Lifecycle
```sh
# Stop cluster containers (Pause lab)
docker stop $(docker ps -q --filter "label=io.x-k8s.kind.cluster")

# Start cluster containers (Resume lab)
docker start $(docker ps -aq --filter "label=io.x-k8s.kind.cluster")

# Delete cluster (Teardown)
kind delete cluster --name dev-cluster
```

Helpful Shell Aliases (`~/.bashrc or ~/.zshrc`)
```sh
# Kind Kubernetes cluster container management

# Start all Kind cluster containers
alias kstart='docker start $(docker ps -aq --filter "label=io.x-k8s.kind.cluster")'

# Stop all Kind cluster containers
alias kstop='docker stop $(docker ps -q --filter "label=io.x-k8s.kind.cluster")'
```

### 🧩 KIND Image Management
```sh
# List kind clusters and nodes
kind get clusters
kind get nodes --name <cluster-name>

# View images inside KIND node (containerd images)
docker exec -it <node-name> crictl images

# Load local Docker image into KIND cluster
kind load docker-image <image-name>:<tag> --name <cluster-name>

# (Optional but Recommended) Verify image inside KIND
docker exec -it <node-name> crictl images | grep <image-name>:<tag>

# Login into KIND node (shell)
docker exec -it <node-name> bash

# List or Remove images (inside KIND)
crictl images
crictl rmi <IMAGE_ID>

# Remove unused images inside KIND
crictl rmi --prune
```
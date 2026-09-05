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
alias kstart='docker start $(docker ps -aq --filter "label=io.x-k8s.kind.cluster")'
alias kstop='docker stop $(docker ps -q --filter "label=io.x-k8s.kind.cluster")'
```
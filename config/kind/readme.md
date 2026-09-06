# 📦 Multi-Node Kubernetes Setup using KIND

This folder contains the configuration and operational guides for provisioning and maintaining a local **4-node Kubernetes** cluster using **Kind (Kubernetes in Docker)**.

### 🏛️ Cluster Topology
The cluster simulates a production-grade topology locally on WSL2/Linux:
- **1 Control-Plane Node:** Manages cluster state, API server, and scheduling.
- **3 Worker Nodes:** Executes workloads (Jenkins builds, Observability agents, and deployed microservices).
- Port Forwarding: Binds host ports `30000-32767` directly to node ports, allowing direct access to cluster services (`Argo CD`, `Grafana`, `Prometheus`, `Nginx Ingress`) via localhost.

### 🌐 Mapped Service Ports Summary
Once deployed, NodePort services listening on these ports inside the cluster become accessible on your host machine:
| Service Target | Container Port | Host Port |
| :--- | :--- | :--- |
| **Nginx Ingress** | `30080` | `30080` |
| **ArgoCD** | `30082` | `30082` |
| **Grafana** | `30030` | `30030` |
| **Prometheus** | `30090` | `30090` |


### 🚀 Cluster Provisioning

**1. Create the Cluster**
Deploy the cluster using the configuration manifest:
```sh
kind create cluster \
  --name dev-cluster \
  --config config/kind/kind-config.yaml \
  --image kindest/node:v1.36.4
```

**2. Verify Deployment**
Check that all 4 nodes are in the `Ready` state:
```sh
kubectl get nodes -o wide
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

**4. Delete Cluster**
```sh
# Delete cluster (Teardown)
kind delete cluster --name dev-cluster
```

### 🛠️ Operational & Maintenance Commands
- Cluster Lifecycle
```sh
# Stop cluster containers (Pause lab)
docker stop $(docker ps -q --filter "label=io.x-k8s.kind.cluster")

# Start cluster containers (Resume lab)
docker start $(docker ps -aq --filter "label=io.x-k8s.kind.cluster")
```
- Helpful Shell Aliases (`~/.bashrc or ~/.zshrc`)
```sh
# Kind Kubernetes cluster container management

# Start all Kind cluster containers
alias kstart='docker start $(docker ps -aq --filter "label=io.x-k8s.kind.cluster")'

# Stop all Kind cluster containers
alias kstop='docker stop $(docker ps -q --filter "label=io.x-k8s.kind.cluster")'
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

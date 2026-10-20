#  Kubernetes Setup using kubeadm (Ubuntu 24.04)

### Overview:

This guide provides step-by-step instructions to set up a production-ready Kubernetes cluster using kubeadm on AWS EC2 instances (1 Control Plane / Master node and 2 Worker nodes). The infrastructure configurations for provisioning these EC2 instances are available directly within this project repository.

### Cluster Specifications:
- **Control Plane (Master Node):** 1 Instance (t3.medium or higher recommended)
- **Worker Nodes:** 2 Instances (t3.small / t3.medium recommended)- **Container Runtime:** `containerd`
- **CNI:** `Flannel`
- **Kubernetes Version:** `1.36.4` (v1.36 repository)

### 1. Install Container Runtime [Master & Worker]
```sh
sudo apt-get update
sudo apt install -y containerd

# Create cgroupfs system driver for runtime
sudo mkdir -p /etc/containerd/

# Update the cgroup to 'true'
containerd config default | sed 's/SystemdCgroup = false/SystemdCgroup = true/' | sudo tee /etc/containerd/config.toml

# Verify the changes
cat /etc/containerd/config.toml | grep -i SystemdCgroup -B 50

# Restart containerd
sudo systemctl restart containerd
```

### 2. Install Kubernetes Packages [Master & Worker]
```sh
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
sudo mkdir -p -m 755 /etc/apt/keyrings

# Download GPG key for Kubernetes v1.36
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.36/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add Kubernetes v1.36 apt repository
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.36/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet=1.36.4-1.1 kubeadm=1.36.4-1.1 kubectl=1.36.4-1.1
sudo apt-mark hold kubelet kubeadm kubectl
```

### 3. Enable Networking Prerequisites [Master & Worker]
```sh
# Load required kernel module
sudo modprobe br_netfilter

# Verify module loaded
lsmod | grep br_netfilter

# Enable IP forwarding & bridge traffic to iptables
sudo tee /etc/sysctl.d/k8s.conf <<EOF
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply settings
sudo sysctl --system

# Verify
sysctl net.ipv4.ip_forward
sysctl net.bridge.bridge-nf-call-iptables

# Restart containerd
sudo systemctl restart containerd
```

### 4. Initialize Control Plane [Only Master]
```sh
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --kubernetes-version=1.36.4
```

- **Configure kubectl:**
```sh
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### 5. Install Flannel CNI [Only Master]
```sh
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
```

### 6. Join Worker Nodes [On Workers]
- Run the command shown after kubeadm init:
```sh
sudo kubeadm join <MASTER_PRIVATE_IP>:6443 \
 --token xxxx \
 --discovery-token-ca-cert-hash sha256:xxxx
```

### 7. Verify Cluster
```sh
kubectl get nodes -o wide

# Verify networking
kubectl get pods -n kube-system -o wide
kubectl get pods -n kube-flannel -o wide

# Test pod deployment
kubectl run nginx --image=nginx
kubectl get pods -o wide
```

### 8. Common Checks & Troubleshooting
```sh
ls /run/flannel
cat /run/flannel/subnet.env
journalctl -u kubelet -f
```

### 📚 Official References
Kubernetes Documentation: Installing [kubeadm] (https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)

Kubernetes Documentation: Creating a cluster with [kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)

Flannel CNI [Setup] (https://github.com/flannel-io/flannel)

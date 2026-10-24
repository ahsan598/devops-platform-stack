#  Kubernetes Setup using kubeadm (Ubuntu 24.04)

### Overview:

This guide builds a self-managed Kubernetes cluster on AWS EC2 using `kubeadm` (**1 Control Plane and 2 Worker nodes**). The Terraform files in this repository provision the EC2 infrastructure; the steps below install and configure software on those instances.

> [!NOTE] 
> This is a learning cluster, not a production-hardened deployment. Review AWS costs, restrict network access, and do not expose internal Kubernetes ports to the public internet.


### Cluster specifications

- **OS:** Ubuntu Server 24.04 LTS, `linux/amd64`
- **Control plane:** 1 EC2 instance (`t3.medium` or larger recommended)
- **Workers:** 2 EC2 instances (`t3.small` / `t3.medium`, depending on workloads)
- **Container runtime:** `containerd` **2.3.7**
- **OCI runtime:** `runc` **1.4.3**
- **CNI plugin binaries:** `containernetworking/plugins` **1.8.0**
- **CNI:** Flannel **v0.28.8**, VXLAN backend
- **Kubernetes:** **v1.36.4** (`kubelet`, `kubeadm`, and `kubectl` pinned to this patch release)
- **Pod CIDR:** `10.244.0.0/16` (must match Flannel's network configuration)


### 0. Before you begin

1. Provision three Ubuntu 24.04 EC2 instances using the Terraform configuration: one control plane and two workers.
2. Ensure all three nodes can reach one another over their **private IP addresses**. Use the control plane's private IP in the `kubeadm join` command.
3. Use an EC2 key pair to SSH into the instances. Keep the private `.pem` file private and outside version control.
4. In the EC2 Security Group, allow SSH (TCP `22`) only from your trusted public IP. Allow Kubernetes and CNI traffic only between cluster nodes or from specific trusted clients that need it. Do not expose etcd (`2379-2380`), kubelet (`10250`), scheduler (`10259`), or controller-manager (`10257`) to `0.0.0.0/0`.
5. For Flannel's VXLAN backend, allow **UDP `8472` between cluster nodes**. If you expose NodePort applications, restrict TCP `30000-32767` to the clients that need them.
6. Confirm the selected AWS region has the AMI, key pair, VPC, and subnet required by your Terraform variables.

The required Kubernetes ports depend on the components and networking mode. See the official [Kubernetes ports and protocols reference](https://kubernetes.io/docs/reference/networking/ports-and-protocols/).


### 1. Prepare the operating system [Master & Workers]

Run these commands on **all three nodes**. This guide uses the standard kubeadm configuration with swap disabled.

```bash
# Refresh Ubuntu package metadata and install basic download/certificate tools.
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

# Disable swap now and comment out swap entries so they stay disabled after reboot.
sudo swapoff -a
sudo sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab

# Load kernel modules required for container networking and persist them across reboots.
cat <<'K8S_MODULES' | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
K8S_MODULES
sudo modprobe overlay
sudo modprobe br_netfilter

# Enable IPv4 forwarding and bridge traffic visibility for iptables.
cat <<'K8S_SYSCTL' | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
K8S_SYSCTL

# Apply persistent kernel settings immediately.
sudo sysctl --system

# Verify the modules and sysctl values are enabled.
lsmod | grep -E '^(overlay|br_netfilter)'
sysctl net.ipv4.ip_forward net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables
```

Expected sysctl values should be `1`. If a check fails, resolve it before installing Kubernetes.

### 2. Install containerd [Master & Workers]

`containerd` pulls and manages container images and runs containers through the Container Runtime Interface (CRI). These commands install a pinned upstream binary release for Linux AMD64.

```bash
# Download the pinned containerd release. Keep all nodes on the same version.
curl -fLO https://github.com/containerd/containerd/releases/download/v2.3.7/containerd-2.3.7-linux-amd64.tar.gz
sudo tar -C /usr/local -xzf containerd-2.3.7-linux-amd64.tar.gz

# Install the systemd unit from the same release tag, not the moving main branch.
curl -fsSLO https://raw.githubusercontent.com/containerd/containerd/v2.3.7/containerd.service
sudo install -D -m 0644 containerd.service /usr/local/lib/systemd/system/containerd.service

# Generate the default configuration file.
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null

# Use systemd as the cgroup driver to align with kubelet's cgroup driver.
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

# Enable and start containerd.
sudo systemctl daemon-reload
sudo systemctl enable --now containerd
sudo systemctl restart containerd

# Verify service status, version, and cgroup setting.
sudo systemctl --no-pager --full status containerd
containerd --version
grep -n 'SystemdCgroup' /etc/containerd/config.toml
```

> [!NOTE]
> **Why `SystemdCgroup = true`?** Ubuntu 24.04 uses systemd, and Kubernetes recommends using the same cgroup driver for kubelet and the container runtime. Confirm that `SystemdCgroup = true` appears under the runc runtime options before continuing.

### 3. Install runc and CNI plugin binaries [Master & Workers]

`runc` is the low-level OCI runtime used by containerd to create containers. The standard CNI plugin bundle provides networking binaries such as `loopback`, `bridge`, and `host-local`. Flannel itself is installed as a Kubernetes DaemonSet in Step 7.

```bash
# Install the pinned runc binary for Linux AMD64.
curl -fLO https://github.com/opencontainers/runc/releases/download/v1.4.3/runc.amd64
sudo install -m 755 runc.amd64 /usr/local/sbin/runc

# Install the pinned standard CNI plugin binaries.
curl -fLO https://github.com/containernetworking/plugins/releases/download/v1.8.0/cni-plugins-linux-amd64-v1.8.0.tgz
sudo mkdir -p /opt/cni/bin
sudo tar -C /opt/cni/bin -xzf cni-plugins-linux-amd64-v1.8.0.tgz

# Verify runtime and CNI binary installation.
runc --version
ls -1 /opt/cni/bin | head

# Remove downloaded archives from the working directory if desired.
rm -f containerd-2.3.7-linux-amd64.tar.gz containerd.service runc.amd64 cni-plugins-linux-amd64-v1.8.0.tgz
```

### 4. Install Kubernetes packages [Master & Workers]

Use the Kubernetes v1.36 package repository and install the exact `1.36.4-1.1` package versions. `apt-mark hold` prevents ordinary package upgrades from unexpectedly changing the cluster version.

```bash
# Create the directory used for APT repository signing keys.
sudo install -m 0755 -d /etc/apt/keyrings

# Add the official signing key for the Kubernetes v1.36 package repository.
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.36/deb/Release.key \
  | sudo gpg --dearmor --yes -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 0644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Configure the official Kubernetes v1.36 APT repository.
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.36/deb/ /' \
  | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet=1.36.4-1.1 kubeadm=1.36.4-1.1 kubectl=1.36.4-1.1

# Prevent accidental package upgrades from changing Kubernetes versions.
sudo apt-mark hold kubelet kubeadm kubectl

# Verify the installed versions.
kubeadm version
kubelet --version
kubectl version --client
```

If APT reports that the exact package version is unavailable, check the package versions published in the official repository before changing the pin. Do not silently install a different Kubernetes patch release.

### 5. Configure the container runtime endpoint [Master & Workers]

`crictl` is a diagnostic CLI for inspecting containers and pods through CRI. Configure it to use containerd's Unix socket so runtime checks do not rely on automatic endpoint discovery.

```bash
# Configure crictl if it is installed on the node.
# Install crictl from a pinned cri-tools release first if it is not present.
sudo crictl config --set runtime-endpoint=unix:///run/containerd/containerd.sock
sudo crictl config --set image-endpoint=unix:///run/containerd/containerd.sock

# Check containerd through CRI (requires crictl to be installed).
sudo crictl info
```

> [!NOTE]
> If `crictl` is not installed, either install a pinned `cri-tools` release compatible with your environment or skip these diagnostic commands. `kubeadm` does not require the `crictl` CLI to be installed.

### 6. Initialize the control plane [Control plane only]

Run this on the control-plane node only. Pod CIDR `10.244.0.0/16` matches the Flannel manifest used in Step 7. The advertise address should be the control plane's **private EC2 IP**, reachable by the workers.

```bash
# Replace <MASTER_PRIVATE_IP> with the control plane's actual private IPv4 address.
sudo kubeadm init \
  --apiserver-advertise-address=<MASTER_PRIVATE_IP> \
  --pod-network-cidr=10.244.0.0/16 \
  --kubernetes-version=v1.36.4
```

When initialization completes, **copy and securely keep the `kubeadm join` command** printed at the end. It is required to add workers. Treat bootstrap tokens as credentials and do not publish them in a repository or screenshot.

### Configure kubectl [Control plane only]

Run these commands as the regular user that will administer the cluster (not from a root shell). The admin kubeconfig grants powerful cluster privileges, so keep it private.

```bash
mkdir -p "$HOME/.kube"
sudo cp /etc/kubernetes/admin.conf "$HOME/.kube/config"
sudo chown "$(id -u):$(id -g)" "$HOME/.kube/config"

# Confirm kubectl can reach the API server.
kubectl get nodes
```

The node may remain `NotReady` until the CNI is installed; this is expected at this stage.

### 7. Install Flannel CNI [Control plane only]

Flannel supplies Pod networking across nodes. This guide uses its VXLAN backend, which encapsulates traffic between nodes; the pod network in its manifest must match `10.244.0.0/16` from `kubeadm init`.

```bash
# Apply the pinned Flannel manifest from the v0.28.8 release.
kubectl apply -f https://github.com/flannel-io/flannel/releases/download/v0.28.8/kube-flannel.yml

# Watch Flannel and system pods start.
kubectl get pods -n kube-flannel -w
```

Wait for Flannel pods to become `Running` before diagnosing node readiness. Ensure the EC2 Security Group allows UDP `8472` between cluster nodes for Flannel VXLAN traffic. Do not open this port to the public internet.

### 8. Join worker nodes [Run on each worker]

Run the join command printed by `kubeadm init` on **each worker node**. Use the control plane's private IP address and the full token and CA certificate hash generated by kubeadm.

```bash
sudo kubeadm join <MASTER_PRIVATE_IP>:6443 \
  --token <TOKEN> \
  --discovery-token-ca-cert-hash sha256:<CA_CERT_HASH>
```

If the command was not saved, generate a new one on the control plane:

```bash
sudo kubeadm token create --print-join-command
```

Do not copy placeholder values literally; replace them with the actual values generated by kubeadm.

### 9. Verify the cluster [Control plane]

```bash
# All three nodes should eventually show Ready.
kubectl get nodes -o wide

# Inspect Kubernetes system pods and Flannel pods.
kubectl get pods -n kube-system -o wide
kubectl get pods -n kube-flannel -o wide

# Create a simple test workload.
kubectl run nginx --image=nginx:stable --restart=Never
kubectl get pod nginx -o wide
kubectl describe pod nginx

# Clean up the test pod after validation, if no longer needed.
kubectl delete pod nginx
```

Node and Pod statuses may take a few minutes to settle. Do not proceed until nodes are `Ready` and networking pods are healthy.

### 10. Common checks and troubleshooting

Run these on the node where the issue occurs, unless a command says otherwise.

```bash
# Check containerd and kubelet services.
sudo systemctl --no-pager --full status containerd
sudo systemctl --no-pager --full status kubelet

# Follow kubelet logs while troubleshooting node registration or pod startup.
sudo journalctl -u kubelet -f

# Review containerd logs.
sudo journalctl -u containerd --since '15 minutes ago'

# Check Flannel pod status and logs from the control plane.
kubectl get pods -n kube-flannel -o wide
kubectl logs -n kube-flannel -l app=flannel --all-containers=true --tail=100

# Inspect Flannel's subnet file on a node after Flannel has started there.
ls -la /run/flannel
cat /run/flannel/subnet.env

# Check node addresses and routes.
ip -br address
ip route
```

### Common causes of `NotReady` nodes

- **Swap is still enabled:** verify with `swapon --show` and disable it for this standard kubeadm setup.
- **Containerd is unhealthy:** check its service logs, confirm `SystemdCgroup = true`, and verify the CRI socket at `/run/containerd/containerd.sock`.
- **Pod CIDR mismatch:** `kubeadm init` uses `10.244.0.0/16`; Flannel's configured network must match it.
- **Security Group blocks node traffic:** verify private-node connectivity, TCP `6443` to the API server, required Kubernetes node ports, and UDP `8472` between nodes for Flannel VXLAN.
- **Incorrect public/private address selection:** use the control plane's private IP for worker joining and ensure each node advertises a reachable address.
- **Wrong CPU architecture:** these download URLs are for Linux AMD64; use matching ARM64 artifacts if your EC2 instances use ARM.

---

### 📚 References & Official Guides

- [Kubernetes: Installing kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)
- [Kubernetes: Creating a cluster with kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)
- [Kubernetes: Ports and protocols](https://kubernetes.io/docs/reference/networking/ports-and-protocols/)
- [Kubernetes: Container runtimes](https://kubernetes.io/docs/setup/production-environment/container-runtimes/)
- [containerd releases and Kubernetes compatibility](https://github.com/containerd/containerd/blob/main/RELEASES.md)
- [runc releases](https://github.com/opencontainers/runc/releases)
- [CNI plugins releases](https://github.com/containernetworking/plugins/releases)
- [Flannel releases](https://github.com/flannel-io/flannel/releases)
- [Flannel Kubernetes installation notes](https://github.com/flannel-io/flannel/blob/master/Documentation/kubernetes.md)

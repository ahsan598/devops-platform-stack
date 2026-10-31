#  Kubernetes Multi-Node Cluster using kubeadm

### Overview:

This guide builds a self-managed Kubernetes cluster on **Ubuntu 24.04 LTS** with **1 Control Plane and 2 Worker nodes**. Terraform provisions EC2 instance and the security group; kubeadm bootstraps Kubernetes; Calico provides Pod networking and NetworkPolicy support.

> [!IMPORTANT]
> This is a learning setup, not production hardened. Restrict SSH/API access to trusted IPs, keep nodes communicating over private IPs, and never expose internal Kubernetes ports to the public internet. Review AWS costs before provisioning.


### Architecture
![architecture](/assets/kubernetes/kubeadm-architecture.png)


### Key components

- **Terraform:** Provision ec2 instance for control-plane and worker nodes.
- **kubeadm:** bootstraps the control plane and joins worker nodes.
- **kube-apiserver:** Kubernetes API entry point.
- **etcd:** stores cluster state (runs on the control plane).
- **kube-scheduler:** selects nodes for newly created Pods.
- **kube-controller-manager:** runs controllers that reconcile desired and actual state.
- **kubelet:** manages Pods on each node; **containerd** is the container runtime.
- **kube-proxy:** implements Service networking on nodes.
- **Calico:** CNI networking and NetworkPolicy.

### Pinned versions and network

| Component | Version / setting |
|---|---|
| OS / architecture | Ubuntu Server 24.04 LTS, Linux AMD64 |
| Kubernetes (`kubelet`, `kubeadm`, `kubectl`) | `1.36.4-1.1` packages |
| containerd | `2.3.7` |
| runc | `1.4.3` |
| crictl (optional diagnostics) | `v1.36.0` |
| Calico | `v3.32.2` |
| Pod CIDR | `192.168.0.0/16` (matches Calico manifest default) |



### 1. Before you begin

1. Set Terraform variables for your AWS region, Ubuntu 24.04 AMD64 AMI, key pair, availability zone, instance type, and your trusted public IP (`my_public_ip`, CIDR notation such as `203.0.113.10/32`).
2. Provision three EC2 instances: one control plane and two workers. For a learning cluster, use at least `t3.medium` for the control plane; size workers for your workloads.
3. Make sure all nodes can communicate over their **private IPs**. Use the control plane's private IP for `kubeadm init` and `kubeadm join`.
4. Keep the `.pem` key and Kubernetes admin credentials out of Git.
5. Security group requirements: SSH `22` from your trusted IP; API `6443` from trusted admin IPs and cluster nodes; required node-to-node Kubernetes traffic; Restrict NodePort `30000-32767` to trusted clients only if needed.

The required Kubernetes ports depend on the components and networking mode. See the official [Kubernetes ports and protocols reference](https://kubernetes.io/docs/reference/networking/ports-and-protocols/).


### 2. Prepare all nodes (control plane + workers)

Run these commands on **all three nodes**. This guide uses the standard kubeadm configuration with swap disabled.

```sh
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

### 3. Install containerd  (control plane + workers)

`containerd` pulls and manages container images and runs containers through the Container Runtime Interface (CRI). These commands install a pinned upstream binary release for Linux AMD64.

```sh
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

Confirm `SystemdCgroup = true` is set in `/etc/containerd/config.toml` under the runc runtime options before continuing.

### 4. Install runc and CNI plugin binaries  (control plane + workers)

`runc` is the low-level OCI runtime used by containerd to create containers. The standard CNI plugin bundle provides networking binaries such as `loopback`, `bridge`, and `host-local`. Flannel itself is installed as a Kubernetes DaemonSet in Step 7.

```sh
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

### 5. Install Kubernetes packages  (control plane + workers)

Use the Kubernetes v1.36 package repository and install the exact `1.36.4-1.1` package versions. `apt-mark hold` prevents ordinary package upgrades from unexpectedly changing the cluster version.

```sh
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

### 6. Configure the container runtime endpoint  (control plane + workers)

**crictl** is a diagnostic CLI for inspecting containers and pods through the Container Runtime Interface (CRI). Configure it to use containerd's Unix socket so runtime checks do not rely on automatic endpoint discovery.

**Step 1: Install a pinned crictl release**
```sh
# Set the crictl version.
CRICTL_VERSION="v1.36.0"

# Download the pinned release.
wget "https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-amd64.tar.gz"

# Extract the binary.
tar -xzf "crictl-${CRICTL_VERSION}-linux-amd64.tar.gz"

# Install crictl.
sudo install -m 755 crictl /usr/local/bin/crictl

# Clean up downloaded files.
rm -f crictl crictl-${CRICTL_VERSION}-linux-amd64.tar.gz

# Verify the installed version.
crictl --version
```

**Step 2: Configure the containerd endpoint**
```sh
# Configure the containerd runtime endpoint.
sudo crictl config --set runtime-endpoint=unix:///run/containerd/containerd.sock

# Configure the containerd image endpoint.
sudo crictl config --set image-endpoint=unix:///run/containerd/containerd.sock
```

**Step 3: Verify the runtime connection**
```sh
# Display container runtime information.
sudo crictl info

# List running containers.
sudo crictl ps

# List downloaded container images.
sudo crictl images
```

> [!NOTE]
> If crictl info returns containerd runtime information, the CRI connection is working. If crictl is not installed, install a compatible pinned cri-tools release or skip these diagnostic commands. kubeadm does not require the crictl CLI to be installed.

### 7. Initialize the control plane (Control plane only)

Run this on the control-plane node only. Pod CIDR `10.244.0.0/16` matches the Flannel manifest used in Step 7. The advertise address should be the control plane's **private EC2 IP**, reachable by the workers.

```sh
# Replace <MASTER_PRIVATE_IP> with the control plane's actual private IPv4 address.
sudo kubeadm init \
  --apiserver-advertise-address=<MASTER_PRIVATE_IP> \
  --pod-network-cidr=10.244.0.0/16 \
  --kubernetes-version=v1.36.4
```

When initialization completes, **copy and securely keep the `kubeadm join` command** printed at the end. It is required to add workers. Treat bootstrap tokens as credentials and do not publish them in a repository or screenshot.

### 8. Configure kubectl (Control plane only)

Run these commands as the regular user that will administer the cluster (not from a root shell). The admin kubeconfig grants powerful cluster privileges, so keep it private.

```sh
mkdir -p "$HOME/.kube"
sudo cp /etc/kubernetes/admin.conf "$HOME/.kube/config"
sudo chown "$(id -u):$(id -g)" "$HOME/.kube/config"

# Confirm kubectl can reach the API server.
kubectl get nodes
```
The node may remain `NotReady` until the CNI is installed; this is expected at this stage.

> [!IMPORTANT]
> Use either Calico or Flannel as the CNI plugin for Pod networking. Do not use both simultaneously.

### 9.1. Install pinned Calico CNI (control plane)

Calico supplies Pod networking across nodes. Its default Pod pool is `192.168.0.0/16`, matching from `kubeadm init`.

```sh
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.32.2/manifests/calico.yaml
kubectl get pods -n kube-system -w
```

Wait for Calico to become healthy before joining workers. If the manifest's namespace differs in the selected release, inspect the created Calico pods with `kubectl get pods -A | grep -i calico`.


### 9.2. Install Flannel CNI (Control plane only) (Optional)
Flannel supplies Pod networking across nodes. This guide uses its VXLAN backend, which encapsulates traffic between nodes; the pod network in its manifest must match `10.244.0.0/16` from `kubeadm init`.

```sh
# Apply the pinned Flannel manifest from the v0.28.8 release.
kubectl apply -f https://github.com/flannel-io/flannel/releases/download/v0.28.8/kube-flannel.yml

# Watch Flannel and system pods start.
kubectl get pods -n kube-flannel -w
```
Wait for Flannel pods to become `Running` before diagnosing node readiness. Ensure the EC2 Security Group allows UDP `8472` between cluster nodes for Flannel VXLAN traffic. Do not open this port to the public internet.

### 10. Join worker nodes (Run on each worker)

Run the join command printed by `kubeadm init` on **each worker node**. Use the control plane's private IP address and the full token and CA certificate hash generated by kubeadm.

```sh
sudo kubeadm join <MASTER_PRIVATE_IP>:6443 \
  --token <TOKEN> \
  --discovery-token-ca-cert-hash sha256:<CA_CERT_HASH>
```

If the command was not saved, generate a new one on the control plane:

```sh
sudo kubeadm token create --print-join-command
```

Do not copy placeholder values literally; replace them with the actual values generated by kubeadm.

### 11. Verify the cluster (Control plane only)

```sh
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

### Common checks and troubleshooting

Run these on the node where the issue occurs, unless a command says otherwise.

```sh
# Check containerd and kubelet services.
sudo systemctl --no-pager --full status containerd
sudo systemctl --no-pager --full status kubelet

# Follow kubelet logs while troubleshooting node registration or pod startup.
sudo journalctl -u kubelet -f --since '15 minutes ago' --no-pager

# Review containerd logs.
sudo journalctl -u containerd --since '15 minutes ago' --no-pager

# Check Calico pod status and logs from the control plane.
kubectl describe node <NODE_NAME>
kubectl get pods -A -o wide
kubectl logs -n kube-system <calico_pod_name> --all-containers=true --tail=100

# Check node addresses and routes.
ip -br address
ip route
```

### Common causes of `NotReady` nodes

- **Swap is still enabled:** verify with `swapon --show` and disable it for this standard kubeadm setup.
- **Containerd is unhealthy:** check its service logs, confirm `SystemdCgroup = true`, and verify the CRI socket at `/run/containerd/containerd.sock`.
- **Pod CIDR mismatch:** `kubeadm init` uses `192.168.0.0/16`; Calico's configured network must match it.
- **Security Group blocks node traffic:** verify private-node connectivity, TCP `6443` to the API server, required Kubernetes node ports.
- **Incorrect public/private address selection:** use the control plane's private IP for worker joining and ensure each node advertises a reachable address.
- **Wrong CPU architecture:** these download URLs are for Linux AMD64; use matching ARM64 artifacts if your EC2 instances use ARM.

---

### 📚 References & Official Guides

- [Kubernetes kubeadm installation](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)
- [Create a cluster with kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)
- [Calico on Kubernetes](https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart)
- [Kubernetes Container runtimes](https://kubernetes.io/docs/setup/production-environment/container-runtimes/)
- [Kubernetes Network plugins](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/)
- [Kubernetes Addons](https://kubernetes.io/docs/concepts/cluster-administration/addons/)
- [Flannel Kubernetes installation notes](https://github.com/flannel-io/flannel/blob/master/Documentation/kubernetes.md)

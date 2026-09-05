# Monitoring, Logging & Argo CD Setup

Kubernetes-based setup for local DevOps practice using Kind.

### 1. Prerequisites
- Kubernetes cluster running
- `kubectl`
- `helm`

**Verify**
```sh
kubectl get nodes
helm version
```

---

## 2. Metrics Server
Metrics Server is required for resource usage commands such as `kubectl top`.

### Install

```sh
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.9.0/components.yaml
```

### Kind / local cluster configuration

```sh
kubectl patch deployment metrics-server -n kube-system   --type='json'   -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
```

Restart and verify:

```sh
kubectl rollout restart deployment metrics-server -n kube-system
kubectl rollout status deployment metrics-server -n kube-system

kubectl get pods -n kube-system | grep metrics
kubectl top nodes
kubectl top pods -A
```

---

## 3. Create Namespaces

```sh
kubectl create namespace monitoring
kubectl create namespace logging
kubectl create namespace argocd
```

---

# 4. Prometheus + Grafana

`kube-prometheus-stack` installs:

- Prometheus
- Grafana
- Alertmanager
- Node Exporter
- Kubernetes monitoring components

### Add Helm repository

```sh
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

### Install

```sh
helm install monitoring prometheus-community/kube-prometheus-stack   --namespace monitoring   --version 88.5.4   --set grafana.service.type=NodePort   --set grafana.service.nodePort=30030   --set prometheus.service.type=NodePort   --set prometheus.service.nodePort=30090
```

### Verify

```sh
kubectl get pods -n monitoring
kubectl get svc -n monitoring
```

### Access

**Grafana:**  
`http://localhost:30030`

**Prometheus:**  
`http://localhost:30090`

Grafana default username:

```text
admin
```

Get the password:

```sh
kubectl get secret -n monitoring monitoring-grafana   -o jsonpath="{.data.admin-password}" | base64 -d
echo
```

---

# 5. Argo CD

### Install Argo CD

Use the pinned release instead of the floating `stable` manifest.

```sh
# Install Argo CD v3.5.1
kubectl apply -n argocd \
  --server-side \
  --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/v3.5.1/manifests/install.yaml

# verify CRDs are installed
kubectl get crd | grep argoproj.io

# Expose Argo CD using NodePort
kubectl patch svc argocd-server -n argocd \
  -p '{"spec":{"type":"NodePort","ports":[{"name":"https","port":443,"targetPort":8080,"nodePort":30082}]}}'
```

### Verify ArgoCD
```sh
kubectl get pods -n argocd
kubectl get svc argocd-server -n argocd
```

### Access UI
For local access:
```text
https://localhost:30082
```

### Get admin password
Username:
```sh
admin

# get admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
echo
```

---

# 6. Loki

Loki stores application and Kubernetes logs.

## Add Grafana Helm repository

```sh
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

## Create values file

```sh
mkdir -p ~/k8s-observability/loki
vi ~/k8s-observability/loki/values.yaml
```

Use the Loki values configuration prepared for the local Kind environment.

## Install Loki

```sh
helm install loki grafana/loki   --namespace logging   --version 18.11.3   -f ~/k8s-observability/loki/values.yaml
```

### Verify

```sh
kubectl get pods -n logging
kubectl get svc -n logging
```

Loki is available inside the cluster at:

```text
loki.logging.svc.cluster.local:3100
```

---

# 7. Fluent Bit

Fluent Bit collects logs from Kubernetes nodes and sends them to Loki.

Fluent Bit runs as a **DaemonSet**, so one Fluent Bit pod runs on each Kubernetes node.

## Add Helm repository

```sh
helm repo add fluent https://fluent.github.io/helm-charts
helm repo update
```

## Create values file

```sh
mkdir -p ~/k8s-observability/fluent-bit
nano ~/k8s-observability/fluent-bit/values.yaml
```

Use the Fluent Bit configuration prepared for the Loki setup.

## Install Fluent Bit

```sh
helm install fluent-bit fluent/fluent-bit   --namespace logging   --version 0.58.1   -f ~/k8s-observability/fluent-bit/values.yaml
```

### Verify

```sh
kubectl get pods -n logging -o wide
kubectl get daemonset -n logging
```

You should have one Fluent Bit pod per Kubernetes node.

---

# 8. Verify Logging

Create a temporary test pod:

```sh
kubectl run log-test   --image=busybox   --restart=Never   -- sh -c 'for i in $(seq 1 10); do echo "Loki test log $i"; sleep 2; done'
```

Verify the pod and its logs:

```sh
kubectl get pod log-test
kubectl logs log-test
```

Then check Grafana's Loki datasource to confirm the logs are available.

---

# 9. Cleanup Test Resources

Remove only the temporary resources created for testing:

```sh
kubectl delete pod log-test
```

If an Argo CD test application and its Kubernetes resources were created:

```sh
kubectl delete application nginx-demo -n argocd
kubectl delete deploy nginx-demo
kubectl delete svc nginx-demo
```

Verify:

```sh
kubectl get pods -A
kubectl get all
kubectl get applications -A
```

---

# 10. Stack Versions

These are the versions used and verified in the local setup.

| Component | Version |
|---|---:|
| Kubernetes | 1.34.0 |
| Metric Server | 0.9.0 |
| Argo CD | 3.5.1 |
| Loki | 3.7.6 |
| Fluent Bit | 5.1.1 |
| kube-prometheus-stack | 88.5.4 |
| Loki Helm Chart | 18.11.3 |
| Fluent Bit Helm Chart | 0.58.1 |

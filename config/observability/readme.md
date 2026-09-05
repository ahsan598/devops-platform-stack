# 📊 Kubernetes Observability & GitOps Stack Setup (Kind)
A complete, production-ready guide to deploying Metrics Server, Prometheus, Grafana, Argo CD, Loki, and Fluent Bit on a local multi-node Kind cluster.

### 🏗️ Stack Architecture & Version Matrix
```txt
                                [ Local Host ]
                                      │
    ┌──────────────────┬──────────────┼──────────────┬──────────────────┐
    │ :30080           │ :30082       │ :30030       │ :30090           │
    ▼                  ▼              ▼              ▼                  ▼
┌─────────┐      ┌──────────┐   ┌──────────┐   ┌────────────┐   ┌───────────────┐
│ Ingress │      │ Argo CD  │   │ Grafana  │   │ Prometheus │   │  Metrics Top  │
└─────────┘      └──────────┘   └──────────┘   └────────────┘   └───────────────┘
                                      ▲              │
                                      │ (Logs Query) │ (Metrics Query)
                                ┌─────┴────┐         ▼
                                │   Loki   │◄────[ Fluent Bit DaemonSet ]
                                └──────────┘
```

| Component | Stack Version | Helm Chart / Manifest Version | Namespace | Mapped Host Access |
| :--- | :--- | :--- | :--- | :--- |
| **Metrics Server** | `v0.9.0` | Manifest (`releases/v0.9.0`) | `kube-system` | Cluster Internal |
| **kube-prometheus-stack** | - | `88.5.4` | `monitoring` | Grafana: `30030`, Prometheus: `30090` |
| **ArgoCD** | `v3.5.1` | Manifest (`v3.5.1`) | `argocd` | HTTPS: `30082` |
| **Loki** | `v3.7.6` | `18.11.3` | `logging` | `loki.logging.svc:3100` |
| **FluentBit** | `v5.1.1` | `0.58.1` | `logging` | Node-level DaemonSet |

### 🛠️ Step 1: Prerequisites & Namespace Initialization
Verify tools connectivity and create isolated namespaces for the stack:
```sh
# 1. Verify Prerequisites
kubectl get nodes
helm version

# 2. Provision Isolated Namespaces
kubectl create namespace monitoring
kubectl create namespace logging
kubectl create namespace argocd
```

### 📈 Step 2: Metrics Server Setup
Metrics Server provides container CPU/Memory metrics required for `kubectl top`.
```sh
# 1. Deploy Metrics Server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.9.0/components.yaml

# 2. Patch Deployment for Kind (Bypass TLS verification)
kubectl patch deployment metrics-server -n kube-system --type='json' \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'

# 3. Restart and Verify
kubectl rollout restart deployment metrics-server -n kube-system
kubectl rollout status deployment metrics-server -n kube-system

# Test resource metrics
kubectl top nodes
kubectl top pods -A
```

### 🎯 Step 3: Monitoring Stack (Prometheus + Grafana)
Deploys Prometheus, Grafana, Alertmanager, and Node Exporters using `kube-prometheus-stack`.
```sh
# 1. Add Community Repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# 2. Install kube-prometheus-stack with NodePort mappings
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --version 88.5.4 \
  --set grafana.service.type=NodePort \
  --set grafana.service.nodePort=30030 \
  --set prometheus.service.type=NodePort \
  --set prometheus.service.nodePort=30090

# 3. Retrieve Grafana Admin Password (Username: admin)
kubectl get secret -n monitoring monitoring-grafana \
  -o jsonpath="{.data.admin-password}" | base64 -d; echo
```
- Grafana Dashboard: http://localhost:30030
- Prometheus UI: http://localhost:30090

### 🚀 Step 4: Argo CD (GitOps)
Deploy Argo CD and expose the web dashboard via NodePort.
```sh
# 1. Install Pinned Argo CD Release
kubectl apply -n argocd \
  --server-side \
  --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/v3.5.1/manifests/install.yaml

# 2. Expose Server UI via NodePort 30082
kubectl patch svc argocd-server -n argocd \
  -p '{"spec":{"type":"NodePort","ports":[{"name":"https","port":443,"targetPort":8080,"nodePort":30082}]}}'

# 3. Retrieve Initial Admin Password (Username: admin)
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d; echo
```
- Argo CD UI: https://localhost:30082

### 🪵 Step 5: Logging Stack (Loki + Fluent Bit)
**1. Install Loki**
```sh
# Add Grafana Helm Repository
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install Loki
helm install loki grafana/loki \
  --namespace logging \
  --version 18.11.3 \
  -f config/observability/loki/values.yaml
```

**2. Install Fluent Bit (Log Collector)**
```sh
# Add Fluent Repository
helm repo add fluent https://fluent.github.io/fluent-bit/
helm repo update

# Install Fluent Bit DaemonSet
helm install fluent-bit fluent/fluent-bit \
  --namespace logging \
  --version 0.58.1 \
  -f config/observability/fluent-bit/values.yaml
```
- Cluster-Internal Loki Endpoint:
`(http://loki.logging.svc.cluster.local:3100)`

### 🧪 Step 6: Verification & Test Workflow
Run a temporary generator pod to test log forwarding into Loki and Grafana:
```sh
# 1. Run Log Generator Pod
kubectl run log-test --image=busybox --restart=Never \
  -- sh -c 'for i in $(seq 1 10); do echo "Loki test log $i"; sleep 2; done'

# 2. Verify Local Execution
kubectl logs log-test

# 3. Clean Up Test Resources
kubectl delete pod log-test
```
**Grafana Verification:** Navigate to http://localhost:30030 -> Explore -> Select **Loki Datasource** -> **Query {pod="log-test"}**.

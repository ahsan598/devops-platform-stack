# 📊 Kubernetes Observability & GitOps Stack Setup (Kind)
A modular, GitOps-ready Kubernetes workbench deployed on WSL2 using Kind (Kubernetes `v1.36+`). Features strict namespace isolation (`monitoring`, `logging`, `argocd`) with pinned helm releases and zero-friction log ingestion.

### 🏛️ Stack Overview & Version Matrix
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

| Tool / Service | Namespace | Access URL / Internal Endpoint |
| :--- | :--- | :--- |
| **Grafana** | `monitoring` | `http://localhost:30030` |
| **Prometheus UI** | `monitoring` | `http://localhost:30090` |
| **Argo CD UI** | `argocd` | `https://localhost:30082` |
| **Loki Engine** | `logging` | `http://loki.logging.svc.cluster.local:3100` |
| **Fluent Bit** | `logging` | DaemonSet |


### 🛠️ Step 1: Namespace Initialization
Verify tools connectivity and create isolated namespaces for the stack:
```sh
# 1. Verify Prerequisites
kubectl get nodes
helm version

# 2. Provision Isolated Namespaces
kubectl create namespace argocd
kubectl create namespace logging
kubectl create namespace monitoring
```

### 📈 Step 2: Metrics Server Setup
Deploys Metrics Server with Kubelet TLS verification bypassed for local Kind nodes.
```sh
# 1. Deploy Metrics Server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.9.0/components.yaml

# 2. Patch Deployment for Kind (Bypass TLS verification)
kubectl patch deployment metrics-server -n kube-system --type='json' \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'

# 3. Rollout and Verify
kubectl rollout restart deployment metrics-server -n kube-system
kubectl rollout status deployment metrics-server -n kube-system

# 4. Test resource metrics pipeline
kubectl top nodes
kubectl top pods -A
```

### 🚀 Step 3: Argo CD Deployment (GitOps Engine)
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

### 🪵 Step 4: Logging Stack (Loki + Fluent Bit)
**1. Install Loki**
```sh
# 1. Add & Update Grafana Repository
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# 2. List all available Grafana Loki Helm chart versions.
helm search repo grafana/loki --versions

# 3. Install Loki
helm install loki grafana/loki \
  --namespace logging \
  --version 7.1.0 \
  -f config/observability/loki/values.yaml
```

**2. Install Fluent Bit (Log Collector)**
Installs Fluent Bit using chart to parse and forward node container logs into Loki.
```sh
# 1. Add & Update FluentBit Repository
helm repo add fluent https://fluent.github.io/fluent-bit/
helm repo update

# 2. List all available Fluent Bit Helm chart versions.
helm search repo fluent/fluent-bit --versions

# 3. Install Fluent Bit DaemonSet
helm install fluent-bit fluent/fluent-bit \
  --namespace logging \
  --version 0.58.0 \
  -f config/observability/fluent-bit/values.yaml

# 4. Restart DaemonSet to hook inotify handles
kubectl rollout restart daemonset fluent-bit -n logging
kubectl get pods -n logging
```

### 🎯 Step 5: Monitoring Stack (kube-prometheus-stack)
Deploys Prometheus, Grafana, Alertmanager, and Node Exporter with Loki pre-provisioned as a default log datasource.
```sh
# 1. Add & Update Community Repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# 2. List all available kube-prometheus-stack Helm chart versions.
helm search repo prometheus-community/kube-prometheus-stack --versions

# 3. Install kube-prometheus-stack with Loki pre-configured as Datasource
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --version 88.5.4 \
  --set grafana.service.type=NodePort \
  --set grafana.service.nodePort=30030 \
  --set prometheus.service.type=NodePort \
  --set prometheus.service.nodePort=30090 \
  --set "grafana.additionalDataSources[0].name=Loki" \
  --set "grafana.additionalDataSources[0].type=loki" \
  --set "grafana.additionalDataSources[0].url=[http://loki.logging.svc.cluster.local:3100](http://loki.logging.svc.cluster.local:3100)" \
  --set "grafana.additionalDataSources[0].access=proxy"

# 4. Verify Loki Health & Cross-Namespace DNS
kubectl exec -it -n monitoring deployment/prometheus-grafana -c grafana -- \
  wget -qO- http://loki.logging.svc.cluster.local:3100/ready

# 5. Retrieve Grafana Admin Password (Username: admin)
kubectl get secret -n monitoring monitoring-grafana \
  -o jsonpath="{.data.admin-password}" | base64 -d; echo
```

### 🧪 Step 6: Log Forwarding Verification & Test Workflow
Deploy a temporary container to generate test log entries:
```sh
# 1. Execute Log Generator Pod
kubectl run log-test --namespace=default --image=busybox --restart=Never \
  -- sh -c 'for i in $(seq 1 10); do echo "Loki integration test log line $i"; sleep 2; done'

# 2. Verify Local Execution
kubectl logs log-test -n default

# 3. Clean Up Test Resources
kubectl delete pod log-test -n default
```

### Grafana Verification
1. Open Grafana UI: http://localhost:30030
2. Navigate to Explore (/explore).
3. Select Loki Data Source from the dropdown.
4. Run LogQL Query: `{pod="log-test"}`
5. Confirm that log lines `Loki integration test log line X` are stream-rendered under log analytics!

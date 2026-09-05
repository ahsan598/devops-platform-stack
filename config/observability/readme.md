# Monotoring & Logging, ArgoCD setup using Kubernetes

```sh
# install metric server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

kubectl get pods -n kube-system | grep metrics

kubectl patch deployment metrics-server -n kube-system \
  --type='json' \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'

kubectl rollout restart deployment metrics-server -n kube-system
kubectl rollout status deployment metrics-server -n kube-system


kubectl top nodes
kubectl top pods -A
```
```sh
# create namespace for each stack
kubectl create namespace monitoring
kubectl create namespace logging
kubectl create namespace argocd
```

### Prometheus + Grafana Setup
```sh
# kube-prometheus-stack contains
Prometheus, Grafana, Alertmanager, Node Exporter, Kubernetes monitoring components

# add prometheus helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# install prometheus
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --version 88.5.4 \
  --set grafana.service.type=NodePort \
  --set grafana.service.nodePort=30030 \
  --set prometheus.service.type=NodePort \
  --set prometheus.service.nodePort=30090

# verify pods
kubectl get pods -n monitoring

# access grafana
localhost:30090

# get login password (user: admin)
kubectl get secret -n monitoring monitoring-grafana \
  -o jsonpath="{.data.admin-password}" | base64 -d
echo
```

### Argo CD Setup
```sh
# install argo using yaml file
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

OR

kubectl apply -n argocd \
  --server-side \
  --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/v3.5.1/manifests/install.yaml

# verify pods
kubectl get pods -n argocd

# access argocd
kubectl port-forward svc/argocd-server -n argocd 8085:443
localhost:8085

# get login password (user: admin)
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
echo
```

### Loki + Fluentbit Setup
```sh
# add grafana helm repo
helm repo add grafana-community https://grafana-community.github.io/helm-charts
helm repo update

helm search repo grafana-community/loki

# Create a Loki values file
mkdir -p ~/k8s-observability/loki
vi ~/k8s-observability/loki/values.yaml

# put content provided in values.yaml file

# install loki using values.yaml file
helm install loki grafana-community/loki  \
--namespace logging \
--version 18.11.3 \
-f ~/k8s-observability/loki/values.yaml

# verify pods
kubectl get pods -n logging
kubectl get svc -n logging
```

### Fluent Bit will run as a DaemonSet, meaning one log collector per Kubernetes node.
```sh
# add fluentbit helm repo
helm repo add fluent https://fluent.github.io/helm-charts
helm repo update

# Create a fluentbit values file
mkdir -p ~/k8s-observability/fluent-bit
nano ~/k8s-observability/fluent-bit/values.yaml

# install fluentbit
helm install fluent-bit fluent/fluent-bit \
  --namespace logging \
    --version 0.58.1 \
  -f ~/k8s-observability/fluent-bit/values.yaml

# verify fluentbit daemonset
kubectl get pods -n logging -o wide
kubectl get daemonset -n logging

# verify by running test pod
kubectl run log-test \
  --image=busybox \
  --restart=Never \
  -- sh -c 'for i in $(seq 1 10); do echo "Loki test log $i"; sleep 2; done'

# verify logs
kubectl get pod log-test
kubectl logs log-test


# cleanup resoruces
kubectl get all

kubectl delete application nginx-demo -n argocd
kubectl get pods
kubectl get deploy
kubectl get svc

kubectl delete pod log-test
kubectl delete deploy nginx-demo
kubectl delete svc nginx-demo

kubectl get pods -A
kubectl get all
kubectl get applications
```


### Stack Versions

| Component | Version |
|---|---:|
| Kubernetes | 1.34.0 |
| Argo CD | 3.5.1 |
| Loki | 3.7.6 |
| Fluent Bit | 5.1.1 |
| kube-prometheus-stack | 88.5.4 |
| Loki Helm Chart | 18.11.3 |
| Fluent Bit Helm Chart | 0.58.1 |
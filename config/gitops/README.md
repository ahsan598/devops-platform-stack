# 🚀 GitOps Engine Setup (Argo CD)
A declarative GitOps continuous delivery setup deployed on Kubernetes. Features non-destructive server-side manifest apply, namespace isolation, and deterministic NodePort routing for local access.

### 📌 Access & Endpoints
| Tool / Service | Namespace | Access URL / Internal Endpoint | Credentials |
| :--- | :--- | :--- | :--- |
| **Argo CD UI** | `argocd` | `https://localhost:30082` | `admin` / *(Generated below)* |
| **Nginx Demo App** | `argocd` | `http://localhost:30080` | N/A |

### 🛠️ Namespace Initialization
```sh
# 2. Provision Isolated Namespaces
kubectl create namespace argocd
```

### 🚀 Argo CD Deployment (GitOps Engine)
1. Deploy Argo CD and expose the web dashboard via NodePort.
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

# 4. Verify all Argo CD pods are running
kubectl get pods -n argocd

# 5. Check the NodePort exposure
kubectl get svc argocd-server -n argocd
```

2. Deploy Nginx demo application to ArgoCD
```sh
# deploy nginx demo application to ArgoCD
kubectl apply -f gitops/apps/nginx-demo-app.yaml

# verify nginx demo application
kubectl get applications -n argocd

# 3. Verify Deployed Pods & Service in argocd namespace
kubectl get pods -n argocd -l app=nginx-demo
kubectl get svc nginx-demo -n argocd
```
![argocd-deploy](/assets/argocd-deploy.jpg)

3. Test Local Application Access
```sh
# Access the Nginx demo application directly via the exposed NodePort endpoint
curl -I http://localhost:30080
```
![app-verify](/assets/nginx-app.jpg)

4. Delete Application via Argo CD
```sh
# Delete the Argo CD Application resource
kubectl delete -f gitops/apps/nginx-demo-app.yaml

# Verify pods & service are terminated
kubectl get pods -n argocd -l app=nginx-demo
kubectl get svc nginx-demo -n argocd
```

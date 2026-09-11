# 🚀 GitOps Engine Setup (Argo CD)
A declarative GitOps continuous delivery setup deployed on Kubernetes. Features non-destructive server-side manifest apply, namespace isolation, and deterministic NodePort routing for local access.

### 📌 Access & Endpoints
| Tool / Service | Namespace | Access URL / Internal Endpoint | Credentials |
| :--- | :--- | :--- | :--- |
| **Argo CD UI** | `argocd` | `https://localhost:30082` | `admin` / *(Generated below)* |
| **Nginx Demo App** | `argocd` | `http://localhost:30080` | N/A |


### 🚀 Argo CD Deployment (GitOps Engine)

1. Namespace Initialization
```sh
# Provision Isolated Namespaces
kubectl create namespace argocd
kubectl create namespace dev
```

2. Deploy Argo CD and expose the web dashboard via NodePort.
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
![argo-pods](/assets/argocd-pods.jpg)

3. ArgoCD server login `http://localhost:30082` and set the credentials

4. Deploy Nginx demo application to ArgoCD
```sh
# deploy nginx demo application to ArgoCD
kubectl apply -f gitops/apps/nginx-app.yaml

# verify nginx demo application
kubectl get applications -n argocd

# 3. Verify Deployed Pods & Service in argocd namespace
kubectl get pods -n dev
kubectl get svc -n dev
```
![nginx-pods](/assets/nginx-pods.jpg)
![argocd-deploy](/assets/argocd-deploy.jpg)

5. Test Local Application Access
```sh
# Access the Nginx demo application directly via the exposed NodePort endpoint
curl -I http://localhost:30080
```
![app-verify](/assets/nginx-app.jpg)

6. Delete Application via Argo CD
```sh
# Delete the Argo CD Application resource
kubectl delete -f gitops/apps/nginx-app.yaml

# Verify pods & service are terminated
kubectl get pods -n dev
kubectl get svc -n dev
```


# 🛠️ GitOps CLI Operations (Optional)
While Argo CD operates declaratively via Git commits and the Web UI, the **Argo CD CLI** is useful for scripting, manual triggers, and integrating with CI/CD runners (e.g., Jenkins, GitHub Actions).

1. CI/CD Server Authentication & Login
Follow these non-interactive steps to authenticate the CLI against your local cluster endpoint.
```sh
# 1. Set the Argo CD NodePort Endpoint
ARGOCD_SERVER="localhost:30082"

# 2. Retrieve the Initial Admin Password
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# 3. Authenticate Non-Interactively (--insecure bypasses self-signed SSL certs)
argocd login $ARGOCD_SERVER \
  --username admin \
  --password "$ARGOCD_PASSWORD" \
  --insecure
```

2. Common CI Pipeline Commands
Use these commands within automation scripts to manage and monitor deployments:
```sh
# List all managed applications and their status
argocd app list

# Force an immediate sync for an application
argocd app sync nginx-app

# Block execution until the application reaches a Healthy state (ideal for CI stages)
argocd app wait nginx-app --health

# View sync history and revision logs
argocd app history nginx-app
```

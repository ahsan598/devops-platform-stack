

## 🗺️ Recommended Stack Setup Order
1. Create External Networks (`docker network create cicd_network`)
2. Create Kind Cluster (`kind create cluster --name dev-cluster --config kind-config.yaml`)
3. Extract Host Docker GID & Patch Kubeconfig (`.env` & `jenkins-kubeconfig`)
4. Build Jenkins Image & Deploy Stack (`docker compose up -d --build`)
5. Verify Integrations (`kubectl get nodes` inside Jenkins)
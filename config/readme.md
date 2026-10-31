# 🛠️ DevOps Workbench

A **local DevOps learning lab** on WSL2/Linux featuring Jenkins (Docker-in-Docker), SonarQube, Nexus Repository Manager, a multi-node KIND Kubernetes cluster, observability tools (Prometheus, Grafana, Loki, Fluent Bit), and GitOps with Argo CD.

Designed for hands-on practice with modern CI/CD pipelines, Infrastructure as Code, continuous testing, and cloud-native observability on **WSL2 / Linux.**


### 📂 Repository Layout
```txt
devops-platform-stack/
├── config/
│   ├── gitops/                 # Argo CD manifests and application definitions
│   ├── jenkins/                # Custom Jenkins Dockerfile, Compose, and kubeconfig patch
│   ├── kubernetes/           # Multi-node cluster setup
│   └── observability/          # Helm values and configs for Prometheus, Grafana & FluentBit
```

Each component in `config/` handles a specific layer of the platform architecture:

**1. Core CI/CD & Automation Layer (`config/jenkins/`)**
- **Jenkins (DInD Engine):** Custom Jenkins image with embedded `docker CLI and kubectl`. Connected to the host's Docker socket via GID patching to execute Docker-in-Docker workflows and deploy straight into KIND.
- **SonarQube Community:** Automated Static Application Security Testing (SAST) and code quality gate analysis integrated directly into Jenkins pipelines.
- **Nexus Repository Manager:** Local artifact storage serving as a private Docker registry, Helm repo, and build cache to optimize network usage.

**2. Multi-Node Kubernetes Topology (`config/kubernetes/`)**
- **KIND (Kubernetes in Docker):** Provisions a 4-node Kubernetes cluster (1 Control Plane + 3 Worker Nodes) inside Docker containers to practice multi-node deployments, scheduling, networking, and cluster operations.
- **Kubeadm:** Provisions a multi-node Kubernetes cluster (1 Control Plane + 2 Worker Nodes) on cloud infrastructure using Terraform.

**3. Observability Ecosystem (`config/observability/`)**
- **Prometheus & Grafana (kube-prometheus-stack):** End-to-end metrics collection, alerting, and pre-built dashboards for host, container, and cluster-level monitoring.
- **Loki & Fluent Bit:** Lightweight log aggregation system. Fluent Bit collects and parses stdout/stderr container logs across nodes and ships them directly to Loki for central query access in Grafana.

**4. GitOps (`config/gitops/`)**
- **Argo CD:** Declarative GitOps continuous delivery tool managing application state synchronization directly inside the KIND cluster.

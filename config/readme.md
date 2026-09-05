# 🛠️ DevOps Workbench
A production-grade local DevOps lab environment featuring **Jenkins (DInD), SonarQube, Nexus, a Multi-Node Kind Kubernetes Cluster, Observability (Prometheus, Grafana, Loki, Fluent Bit), and GitOps (Argo CD)**.

Designed for hands-on practice with modern CI/CD pipelines, Infrastructure as Code, continuous testing, and cloud-native observability on **WSL2 / Linux.**

### 📂 Repository Layout
```txt
devops-platform-stack/
├── config/
│   ├── jenkins/              # Custom Jenkins Dockerfile, compose, and kubeconfig patch setup
│   ├── kind/                 # Multi-node Kind cluster config with mapped NodePorts
│   └── observability/        # Helm configurations for Monitoring, Logging, and Argo CD
├── scripts/                  # Automated setup and verification utility scripts
├── docs/                     # Additional guides and version matrix documentation
└── README.md                 # Master execution guide
```

### 🏗️ Platform Stack Overview
Each component in config/ handles a specific layer of the platform architecture:
**1. Multi-Node Kubernetes Topology (`config/kind/`)**
- **Kind (Kubernetes in Docker):** Provisions a 4-node cluster (1 Control Plane + 3 Worker Nodes) simulating production-like Kubernetes topologies locally.
- **NodePort & Ingress Mappings:** Pre-configures host port forwardings (`30000-32767`) to directly expose cluster-hosted applications (**Argo CD, Grafana, Prometheus**) without complex load balancer drivers.

**2. Core CI/CD & Automation Layer (`config/jenkins/`)**
- **Jenkins (DInD Engine):** Custom Jenkins image with embedded `docker CLI and kubectl`. Connected to the host's Docker socket via GID patching to execute Docker-in-Docker workflows and deploy straight into Kind.
- **SonarQube Community:** Automated Static Application Security Testing (SAST) and code quality gate analysis integrated directly into Jenkins pipelines.
- **Nexus Repository Manager:** Local artifact storage serving as a private Docker registry, Helm repo, and build cache to optimize network usage.

**3. Observability & GitOps Ecosystem (`config/observability/`)**
- **Prometheus & Grafana (kube-prometheus-stack):** End-to-end metrics collection, alerting, and pre-built dashboards for host, container, and cluster-level monitoring.
- **Loki & Fluent Bit:** Lightweight log aggregation system. Fluent Bit collects and parses stdout/stderr container logs across nodes and ships them directly to Loki for central query access in Grafana.
- **Argo CD:** Declarative GitOps continuous delivery tool managing application state synchronization directly inside the Kind cluster.

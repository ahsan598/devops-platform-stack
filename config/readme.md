# 🛠️ DevOps Workbench
A production-grade local DevOps lab environment featuring **Jenkins (DInD), SonarQube, Nexus, a Multi-Node Kind Kubernetes Cluster, Observability (Prometheus, Grafana, Loki, Fluent Bit), and GitOps (Argo CD)**.

Designed for hands-on practice with modern CI/CD pipelines, Infrastructure as Code, continuous testing, and cloud-native observability on **WSL2 / Linux.**


### 🏛️ Stack Overview of KIND Cluster
```txt
                                [ KIND Cluster]
                                      │
    ┌──────────────────┬──────────────┼──────────────┬──────────────────┐
    │ :30080           │ :30082       │ :30030       │ :30090           │
    ▼                  ▼              ▼              ▼                  ▼
┌─────────┐      ┌──────────┐   ┌──────────┐   ┌────────────┐   ┌───────────────┐
│ Nginx   │      │ Argo CD  │   │ Grafana  │   │ Prometheus │   │  Metrics Top  │
└─────────┘      └──────────┘   └──────────┘   └────────────┘   └───────────────┘
                                      ▲              │
                                      │ (Logs Query) │ (Metrics Query)
                                ┌─────┴────┐         ▼
                                │   Loki   │◄────[ Fluent Bit DaemonSet ]
                                └──────────┘
```

### 📂 Repository Layout
```txt
devops-platform-stack/
├── config/
│   ├── gitops/                 # Argo CD manifests and application definitions
│   ├── jenkins/                # Custom Jenkins Dockerfile, Compose, and kubeconfig patch
│   ├── kind/                    # Multi-node Kind cluster setup with mapped NodePorts
│   └── observability/      # Helm values and configurations for Prometheus, Grafana & Logging
```

Each component in `config/` handles a specific layer of the platform architecture:

**1. Core CI/CD & Automation Layer (`config/jenkins/`)**
- **Jenkins (DInD Engine):** Custom Jenkins image with embedded `docker CLI and kubectl`. Connected to the host's Docker socket via GID patching to execute Docker-in-Docker workflows and deploy straight into Kind.
- **SonarQube Community:** Automated Static Application Security Testing (SAST) and code quality gate analysis integrated directly into Jenkins pipelines.
- **Nexus Repository Manager:** Local artifact storage serving as a private Docker registry, Helm repo, and build cache to optimize network usage.

**2. Multi-Node Kubernetes Topology (`config/kind/`)**
- **Kind (Kubernetes in Docker):** Provisions a 4-node cluster (1 Control Plane + 3 Worker Nodes) simulating production-like Kubernetes topologies locally.
- **NodePort Mappings:** Pre-configures host port forwardings (`30000-32767`) to directly expose cluster-hosted applications (Argo CD, Grafana, Prometheus) without complex load balancer drivers.

**3. Observability & GitOps Ecosystem (`config/observability/`)**
- **Prometheus & Grafana (kube-prometheus-stack):** End-to-end metrics collection, alerting, and pre-built dashboards for host, container, and cluster-level monitoring.
- **Loki & Fluent Bit:** Lightweight log aggregation system. Fluent Bit collects and parses stdout/stderr container logs across nodes and ships them directly to Loki for central query access in Grafana.

4. **GitOps (`config/gitops/`)**
- **Argo CD:** Declarative GitOps continuous delivery tool managing application state synchronization directly inside the Kind cluster.

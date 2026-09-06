# 📌 Detailed Tool Matrix & Environment Details

### Base OS & Subsystem Environment
| Component | Specification / Version | Context |
| :--- | :--- | :--- |
| **Host OS Context** | Windows Subsystem for Linux (`WSL2`) | Hyper-V Subsystem |
| **Kernel Version** | `5.15.167.4-microsoft-standard-WSL2` | Linux Kernel |
| **Linux OS Distribution** | Ubuntu `24.04.4 LTS (Noble Numbat)` | WSL Distro Base |

---

### 1. Runtimes & Build Engines
| Category | Tool / Utility | Pin Version |
| :--- | :--- | :--- |
| **Java Runtime** | OpenJDK | `21.0.12 LTS` |
| **Python Runtime** | Python 3 | `v3.12.3` |
| **Node.js Runtime** | Node.js | `v22.23.1 LTS` |
| **Package Managers** | nvm / npm | `v0.40.3` / `v10.9.8` |
| | pip | `v24.0` |
| **Build Tool** | Apache Maven | `v3.8.7` |


### 2. Containers & Local Kubernetes
| Category | Tool / Binary | Pin Version |
| :--- | :--- | :--- |
| **Container Engine** | Docker Engine | `v27.5.1` |
| **Docker Plugins** | Docker Buildx | `v0.37.0` |
| | Docker Compose | `v5.5.1` |
| **Container Runtime** | Containerd | `v2.3.4` |
| **Local K8s Engine** | KIND (Kubernetes in Docker) | `v0.32.0` |
| **K8s CLI Tools** | kubectl | `Client v1.36.4` |
| | kustomize | `v5.8.1` |
| | Helm | `v3.17.3` |

### 3. CI/CD, Registry & Security (SAST)
| Service / Tool | Deployment / Base Image | Pin Version |
| :--- | :--- | :--- |
| **Jenkins** | Enterprise LTS Release | `v2.568.2` |
| **SonarQube** | Community Build Image | `v25.12.0.117093` |
| **PostgreSQL** | Database Image (`postgres:17-alpine`) | `17-alpine` |
| **Nexus Manager** | Sonatype Image (`sonatype/nexus3`) | `v3.87.2` |
| **Argo CD** | GitOps Controller / Server | `v3.5.1` |

### 4. Observability Stack
| Component | Layer / Package | Pin Version / Tag |
| :--- | :--- | :--- |
| **kube-prometheus-stack** | Helm Chart | `Chart v88.5.4` |
| | Prometheus Engine | `v3.14.0-distroless` |
| | Prometheus Operator | `v0.93.1` |
| | Alertmanager | `v0.28.0` |
| **Grafana** | Visualization Platform | `v13.2.0` |
| **Grafana Loki** | Log Aggregator | `App v3.7.6` (`Chart v18.11.3`) |
| **Fluent Bit** | Log Shipper | `App v5.1.1` (`Chart v0.58.1`) |

### 5. IaC, Automation & System Utilities
| Tool Name | Primary Purpose | Pin Version |
| :--- | :--- | :--- |
| **Terraform** | Infrastructure as Code | `v1.15.9` |
| **Ansible Core** | Configuration Management | `v2.20.3` |
| **Trivy** | Container & Vulnerability Scanner | `v0.71.1` |
| **AWS CLI** | Cloud Management CLI | `v2.35.24` |
| **Git** | Distributed Version Control | `v2.43.0` |
| **JQ / YQ** | JSON & YAML Processors | `jq-1.7` / `v4.53.3` |
| **GNU Make** | Build Automation | `v4.3` |

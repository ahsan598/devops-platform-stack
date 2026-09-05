# 🚀 DevOps Platform Stack

An enterprise-grade, reproducible DevOps lab environment for learning, building, deploying, monitoring, and troubleshooting modern application delivery infrastructure.

This repository serves as a central blueprint, organizing installation, configuration, verification, and cleanup workflows for each component.

> [!NOTE]
> This setup is compatible with **Ubuntu/Debian-based** Linux distributions and **Windows via WSL2**. All installation workflows have been actively tested and verified on **Windows WSL2 running on Ubuntu 24.04 LTS**.
>
> **RHEL-based** distributions (e.g., **Rocky Linux, AlmaLinux, CentOS, Fedora**) are not currently covered, as they utilize `dnf/yum` package managers instead of `apt`.


## 📂 Repository Structure
```text
devops-platform-stack/
├── commands/               # Common CLI commands and operational references
├── config/                 # Configuration files for platform tools and services
├── deployments/            # Kubernetes manifests, Helm charts, and Compose files
├── docs/                   # Setup guides, prerequisites, and verification steps
├── examples/               # Sample applications for testing and validation
├── scripts/                # Installation, automation, maintenance, and cleanup scripts
├── .gitignore              # Git ignore rules
└── README.md               # Main project documentation
```

## 🛠️ Technology Stack Overview

### 💻 Application Development
- **Java & Maven:** Enterprise backend runtime and build automation.
- **Node.js & npm:** Modern frontend/microservices runtime and package manager.
- **Python & pip:** Automation scripting, data utilities, and package manager.

### 🔄 CI/CD & Artifact Management
- **Jenkins:** Core continuous integration and pipeline engine.
- **Argo CD:** GitOps-driven continuous delivery for Kubernetes.
- **Nexus Repository:** Private registry for binaries and artifacts.
- **SonarQube & PostgreSQL:** Automated code quality analysis (SAST) backed by Postgres DB

### ⎈ Containerization & Orchestration
- **Docker, Compose & containerd:** Local container engine, multi-container orchestration, and core container runtime.
- **Kubernetes (Kind):** Multi-node local Kubernetes clusters running over Docker.
- **Helm & Kustomize:** Package management and declarative manifest customization for Kubernetes deployments.

### 📊 Observability & Core Infrastructure
- **Prometheus & Metrics Server:** Infrastructure and application metric collection.
- **Grafana:** Centralized visualization dashboards.
- **Loki & Fluent Bit:** Log aggregation, routing, and parsing.

### ⚙️ IaC & Automation
- **Terraform:** Declarative Infrastructure as Code for cloud provisioning.
- **Ansible:** Configuration management and application deployment.

### 🧰 CLI Utilities
- **AWS CLI:** Cloud resource management
- **kubectl:** Kubernetes cluster control
- **Trivy:** Vulnerability scanning for images and repositories.
- **Git:** Distributed version control
- **jq / yq:** Command-line JSON and YAML processors.
- **Make:** Build automation and workflow shortcut manager.


## ⚡ Quick Start

### 1. Prerequisites
Ensure your local machine meets all hardware, WSL2, or Linux configuration requirements before starting the lab:
```sh
# Clone the repository
git clone https://github.com/ahsan598/devops-platform-stack.git
cd devops-platform-stack

# View the prerequisites document in the terminal
cat docs/01-prerequisites.md
```

### 2. Inspect Verified Tool Matrix
Check all pinned versions across runtimes, container engines, and observability stacks verified for this stack:
```sh
# View all pinned versions
cat docs/00-tools-version.md
```

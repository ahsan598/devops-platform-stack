# 🚀 DevOps Platform Stack

An enterprise-grade, reproducible DevOps lab environment for learning, building, deploying, monitoring, and troubleshooting modern application delivery infrastructure.

This repository serves as a central blueprint, organizing installation, configuration, verification, and cleanup workflows for each component.

> **💻 OS Compatibility Note:**  
> These installation workflows and setup steps are fully compatible with **native Linux distributions (Ubuntu/Debian)** as well as **Windows via WSL2**. While all configurations were actively tested and verified on a **Windows WSL2 (Ubuntu 24.04 LTS)** environment, the exact same commands apply seamlessly to native Linux environments.


## 📂 Repository Structure
```text
devops-platform-stack/
├── config/             # Configuration files for tools (Jenkins, Prometheus, etc.)
├── deployments/        # Kubernetes manifests, Helm charts, and Compose files
├── docs/               # Setup guides, verification steps, and lab documentation
├── examples/           # Sample applications (Java, Node.js, Python)
├── scripts/            # Automation, installation, and cleanup scripts
├── .gitignore          # Git ignore rules
└── README.md           # Main project documentation
```

## 🛠️ Technology Stack Overview

### 💻 Application Development
- **Java & Maven:** Enterprise backend stack.
- **Node.js:** Modern frontend and microservices runtime.
- **Python:** Automation scripting and data utilities.

### 🔄 CI/CD & Artifact Management
- **Jenkins:** Core continuous integration and pipeline engine.
- **Argo CD:** GitOps-driven continuous delivery for Kubernetes.
- **Nexus Repository:** Private registry for binaries and artifacts.
- **SonarQube:** Automated code quality and static security analysis (SAST).

### ⎈ Containerization & Orchestration
- **Docker & Compose:** Local container runtime and multi-container setups.
- **Kubernetes (Kind):** Local Kubernetes clusters running in Docker.
- **Helm:** Package management for Kubernetes deployments.

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
git clone https://github.com/<your-username>/devops-platform-stack.git
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

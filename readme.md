# 🚀 DevOps Platform Stack

An enterprise-grade, reproducible DevOps lab environment for learning, building, deploying, monitoring, and troubleshooting modern application delivery infrastructure.

This repository serves as a central blueprint, organizing installation, configuration, verification, and cleanup workflows for each component.

> [!NOTE]
> This setup is compatible with **Ubuntu/Debian-based** Linux distributions and **Windows via WSL2**. All installation workflows have been actively tested and verified on **AWS EC2 & Windows WSL2 running on Ubuntu 24.04 LTS**.
>
> **RHEL-based** distributions (e.g., **Rocky Linux, AlmaLinux, CentOS, Fedora**) are not currently covered, as they utilize `dnf/yum` package managers instead of `apt`.


## 📂 Repository Structure
```text
devops-platform-stack/
├── assets/					# Images and other visual assets
├── config/					# Configuration files for platform tools and services
├── deployments/			# Deployment manifests, and deployment-related files
├── docs/					# Setup guides, prerequisites, and verification steps
├── scripts/				# Installation, automation, maintenance, and cleanup scripts
├── .gitignore				# Git ignore rules
├── LICENSE					# Project license
└── README.md				# Main project documentation
```

## 🛠️ Technology Stack Overview

### 💻 Application Development
- **Java & Maven:** Enterprise backend runtime and build automation.
- **Node.js, npm:** JavaScript, TypeScript runtime and package manager 
  - **nvm:** Node.js version manager for installing and switching between Node.js versions.
- **Python, pip & venv:** Automation scripting, package management, and isolated virtual environment utilities.

### 🔄 CI/CD & Artifact Management
- **Jenkins:** Core continuous integration and pipeline engine.
- **Nexus Repository:** Private registry for binaries and artifacts.
- **SonarQube & PostgreSQL:** Automated code quality analysis (SAST) backed by Postgres DB

### ⎈ Containerization, Orchestration & GitOps
- **Docker, Compose & containerd:** Local container engine, multi-container orchestration, and core container runtime.
- **Kubernetes (Kind):** Multi-node local Kubernetes clusters running over Docker.
- **Helm & Kustomize:** Package management and declarative manifest customization for Kubernetes deployments.
- **Argo CD:** GitOps-driven continuous delivery for Kubernetes.

### 📊 Observability Stack
- **Prometheus & Metrics Server:** Infrastructure and application metric collection.
- **Grafana:** Centralized visualization dashboards.
- **Loki & Fluent Bit:** Log aggregation, routing, and parsing.

### ⚙️ IaC & Automation
- **Terraform:** Declarative Infrastructure as Code for cloud provisioning.
- **Ansible:** Configuration management and application deployment.

### 🧰 CLI Utilities
- **AWS CLI:** Cloud resource management
- **ArgoCD CLI:** Application deployment and management
- **kubectl:** Kubernetes cluster control
- **Trivy:** Vulnerability scanning for images and repositories.
- **Git:** Distributed version control
- **jq / yq:** Command-line JSON and YAML processors.
- **Make:** Build automation and workflow shortcut manager.


## ⚡ Quick Start

### 1. Prerequisites
Ensure your local machine meets all hardware requirements before starting the lab:
```sh
# Clone the repository
git clone https://github.com/ahsan598/devops-platform-stack.git

cd devops-platform-stack/

# View the prerequisites document in the terminal
cat docs/01-prerequisites.md
```

### 2. Inspect Verified Tool Matrix
Check all pinned versions across runtimes, container engines, and observability stacks verified for this stack:
```sh
# View all pinned versions
cat docs/00-tools-version.md
```

### 3. DevOps Tool Setup
1. The `scripts/` contains installation or cleanup scripts for required tools and packages.
   ```sh
   # Navigate to installation scripts
   cd scripts/install/

   # Navigate to cleanup scripts
   cd scripts/cleanup/
   ```

2. The `config/` contains the configuration setup required for each platform component
   ```sh
   # Navigate to GitOps configuration
   cd config/gitops/

   # Navigate to Jenkins configuration
   cd config/jenkins/

   # Navigate to Kind configuration
   cd config/kind/

   # Navigate to Observability configuration
   cd config/observability/
   ```
3. The `deployments/` contains the deployment configuartion for each tools
   ```sh
   # Navigate to Jenkins deployment
   cd deployments/jenkins/

   # Navigate to Kubernetes deployment
   cd deployments/kubernetes/
   ```

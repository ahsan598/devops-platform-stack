# 🚀 DevOps Platform Stack

A hands-on DevOps learning environment designed to explore, configure, automate, deploy, monitor, and troubleshoot modern software delivery infrastructure.

This repository brings together a collection of DevOps tools, installation scripts, configuration files, practical examples, and setup guides in one place. It provides a structured environment for learning how different components work individually and how they integrate into a broader DevOps workflow.

From application development and CI/CD pipelines to containerization, Kubernetes, GitOps, infrastructure automation, and observability, this project provides a practical foundation for experimenting with commonly used DevOps technologies.

**The primary goal is learning through implementation**: building practical skills, understanding tool integrations, validating configurations, and developing repeatable workflows in a controlled lab environment.

> [!NOTE]
> **Project Scope**: This repository is intended for learning, experimentation, and hands-on DevOps practice. It is not presented as a production-ready or enterprise-validated platform. Production deployments require additional engineering, security hardening, access controls, high availability, backup and recovery strategies, capacity planning, and operational validation appropriate to the target environment.

> [!IMPORTANT]
> **Supported Environments**: The installation workflows are designed primarily for Ubuntu/Debian-based Linux distributions and Windows through WSL2.
>
> The setup has been tested and verified on AWS EC2 and Ubuntu 24.04 LTS running under Windows WSL2, as documented by the project.
>
> RHEL-based distributions, including Rocky Linux, AlmaLinux, CentOS, and Fedora, are not currently covered by the installation workflows. Their package management and system configuration requirements may differ from the supported environments.

### 🎯 Project Objectives

- **Application Development**: Set up development runtimes, programming languages, and build tools.
- **CI/CD Automation**: Explore continuous integration, pipeline automation, and artifact management.
- **Containerization**: Build and run containerized applications using Docker and related tools.
- **Kubernetes**: Practice cluster setup, workload deployment, and application management using KIND and kubeadm-based environments.
- **GitOps & Deployment**: Understand declarative application delivery and Kubernetes deployment workflows with Argo CD.
- **Code Quality & Security**: Experiment with code quality analysis and vulnerability scanning.
- **Infrastructure Automation**: Learn infrastructure provisioning and configuration management using Terraform and Ansible.
- **Observability**: Collect metrics, visualize system behavior, and work with centralized logging.


### 📂 Repository Structure
```text
devops-platform-stack/
├── assets/       # Images, diagrams, and other visual assets
├── config/       # Configuration files for platform tools and services
├── examples/     # Sample configurations and practical usage examples
├── docs/         # Setup guides, prerequisites, and verification steps
├── scripts/      # Installation, automation, maintenance, and cleanup scripts
├── .gitignore    # Git ignore rules
├── LICENSE       # Project license
└── README.md     # Main project documentation
```

### 🛠️ Technology Stack Overview

### 💻 Application Development
- **Java & OpenJDK**: Java runtime and development environment.
- **Maven**: Build automation and dependency management for Java projects.
- **Go (Golang)**: Systems programming, backend development, and DevOps tooling.
- **Node.js & npm**: JavaScript runtime and package management for JavaScript and TypeScript projects.
- **Python & pip**: Automation scripting and package installation.

### 🔄 CI/CD & Artifact Management
- **Jenkins:** Continuous integration and pipeline automation..
- **Nexus:** Private artifact and package repository.

### ⎈ Containerization, Orchestration & GitOps
- **Docker & Docker Compose**: Container image management and multi-container application environments.
- **containerd**: Container runtime technology.
- **Kubernetes**: Container orchestration and workload management.
  - **KIND:** Local Kubernetes clusters running in Docker containers.
  - **Kubeadm:** Tools for bootstrapping Kubernetes clusters in suitable lab or infrastructure environments.
- **Helm:** Kubernetes application packaging and release management.
- **Kustomize**: Declarative Kubernetes manifest customization.
- **Argo CD:** GitOps-based continuous delivery for Kubernetes applications.

### 📊 Observability & Monitoring
- **Prometheus**: Metrics collection and monitoring.
- **Metrics Server**: Resource metrics for Kubernetes workloads and cluster components.
- **Grafana**: Metrics visualization and monitoring dashboards.
- **Loki**: Log aggregation and querying.
- **Fluent Bit**: Log collection, processing, and forwarding.

### ⚙️ Infrastructure as Code (IaC) & Automation
- **Terraform:** Declarative Infrastructure cloud provisioning.
- **Ansible:** Configuration management and task automation.

### 🛡️ Code Quality & Security
- **SonarQube**: Static code analysis and code quality assessment.
- **Trivy**: Vulnerability scanning for supported container images, repositories, and configuration files.

### 🧰 CLI Utilities & Developer Tools
- **AWS CLI**: Command-line access to AWS services.
- **Argo CD CLI**: Command-line interaction with Argo CD.
- **kubectl**: Kubernetes cluster and workload management.
- **Git**: Distributed version control.
- **JQ & YQ**: Command-line JSON and YAML processing.
- **Make**: Build automation and reusable workflow commands.


## ⚡ Quick Start

### 1. Prerequisites

Before starting, review the documentation to understand the supported environment, required resources, and tool versions.

**1. Clone the repository**:
  ```sh
  git clone https://github.com/ahsan598/devops-platform-stack.git

  cd devops-platform-stack/
  ```

**2. Review the tool versions**:
Check the documented versions of the runtimes, container tools, and other components.
  ```sh
  cat docs/00-tools-version.md
  ```

**3. Prepare Windows Subsystem for Linux (WSL2)**:
If you are using Windows, follow the WSL setup guide before installing the tools.
  ```sh
  cat docs/01-wsl-setup.md
  ```

**4. Check the hardware requirements**:
Review the resource requirements before setting up Kubernetes clusters, CI/CD services, and observability components.
  ```sh
  cat docs/02-hardware-requirements.md
  ```


### 2. Explore the Installation & Cleanup Scripts

The `scripts/` directory contains the available installation, automation, and cleanup workflows.
  ```sh
  # Navigate to installation scripts
  cd scripts/install/

  # Return to the repository root before exploring cleanup scripts
  cd ../cleanup/
  ```

Review each script before executing it, particularly when it modifies system packages, services, permissions, networking, or existing configurations.


### 3. Explore Component Configurations

The `config/` directory organizes configuration files by platform component.
  ```sh
  # From the repository root

  # GitOps configuration
  cd config/gitops/

  # Jenkins configuration
  cd ../jenkins/

  # Kubernetes configuration
  cd ../kubernetes/

  # Observability configuration
  cd ../observability/
  ```

Use the configuration files and accompanying documentation to understand how individual components are configured and integrated.

### 4. Explore Practical Examples

The `examples/` directory provides sample configurations and reference implementations for supported components.
  ```sh
  # From the repository root

  # Jenkins examples
  cd examples/jenkins/

  # Kubernetes examples
  cd ../kubernetes/
  ```

Use these examples as starting points for experimentation, troubleshooting, and further customization.


### 📚 Learning Outcomes

By working through this repository, you will gain practical experience with DevOps tools, CI/CD pipelines, containerization, Kubernetes, GitOps, Infrastructure as Code, automation, monitoring, logging, and security scanning through practical setup, configuration, deployment, and troubleshooting exercises in a learning-focused environment.

<!-- ### 🤝 Contributions
Suggestions, documentation improvements, example configurations, and bug reports are welcome. Contributions that improve reproducibility, clarity, compatibility, and the learning experience are especially valuable.

### 📄 License
See the [LICENSE](/LICENSE) file for licensing information. -->

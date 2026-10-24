# Kubernetes Infrastructure Stacks

This directory contains multi-node Kubernetes cluster configurations for both local development and cloud-based learning environments.


### 📂 Directory Structure

- **`Kind/`** – A local multi-node Kubernetes cluster running inside Docker containers for development, experimentation and testing.
- **`Kubeadm/`** – A multi-node Kubernetes learning cluster bootstrapped on cloud using Terraform, providing practical experience with cloud infrastructure and cluster setup.


### 🚀 Environment Comparison

| Setup | Environment | Purpose |
| :--- | :--- | :--- |
| **Kind** | Local Docker | Fast iteration, local workflows, & manifest testing. |
| **Kubeadm** | AWS EC2 (VMs) | Real-world sysadmin practice, CNI setup, & staging simulation. |

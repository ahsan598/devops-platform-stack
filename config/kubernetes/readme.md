# Kubernetes Infrastructure Stacks

This directory contains multi-node Kubernetes cluster configurations for both local development and cloud-based production-like environments.


### 📂 Directory Structure

* **`Kind/`** – Local multi-node Kubernetes cluster running inside Docker containers for rapid development and testing.
* **`Kubeadm/`** – Production-grade multi-node Kubernetes cluster bootstrapped on AWS EC2 instances via Terraform.


### 🚀 Environment Comparison

| Setup | Environment | Purpose |
| :--- | :--- | :--- |
| **Kind** | Local Docker | Fast iteration, local workflows, & manifest testing. |
| **Kubeadm** | AWS EC2 (VMs) | Real-world sysadmin practice, CNI setup, & staging simulation. |


### 📚 References & Official Guides

- Set up local multi-node clusters using the [KIND Quick Start Guide](https://kind.sigs.k8s.io/docs/user/quick-start/).
- Provision production-grade clusters via the [Kubeadm Installation Guide](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/).
- Install cluster management tools using the [Kubectl Installation Guide](https://kubernetes.io/docs/tasks/tools/).
- Manage Kubernetes packages with the [Helm Installation Guide](https://helm.sh/docs/intro/install/).

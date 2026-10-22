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

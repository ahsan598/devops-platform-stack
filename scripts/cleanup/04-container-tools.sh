#!/usr/bin/env bash
set -euo pipefail

echo "============================================="
echo " Cleaning Up Docker, KIND, & K8s Tools"
echo "============================================="

# 1. Delete Active Kind Clusters
if command -v kind &>/dev/null; then
  echo "Deleting active Kind clusters..."
  kind get clusters 2>/dev/null | xargs -I {} kind delete cluster --name {} || true
fi

# 2. Stop Docker Service & Remove Custom K8s Binaries
echo "Stopping Docker service and removing kubectl, kind, helm..."
if command -v systemctl &>/dev/null && systemctl is-systemd-running &>/dev/null; then
  sudo systemctl stop docker 2>/dev/null || true
else
  sudo service docker stop 2>/dev/null || true
fi

sudo rm -f /usr/local/bin/kubectl
sudo rm -f /usr/local/bin/kind
sudo rm -f /usr/local/bin/helm

# 3. Purge Docker Engine & Plugins
echo "Purging Docker, containerd, and plugins..."
sudo apt-mark unhold docker-ce docker-ce-cli containerd.io 2>/dev/null || true
sudo apt purge -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin || true

# 4. Remove Docker Repository Configs, Keys & Local Data
echo "Removing Docker repositories, keyrings, and data directories..."
sudo rm -f /etc/apt/sources.list.d/docker.sources
sudo rm -f /etc/apt/keyrings/docker.asc

# Wipe residual Docker/Kube configuration directories
sudo rm -rf /var/lib/docker /var/lib/containerd /etc/docker
rm -rf "${HOME}/.kube" "${HOME}/.kind" "${HOME}/.helm" "${HOME}/.docker"

# 5. Clean APT Cache and Dependencies
echo "Cleaning apt package cache..."
sudo apt autoremove -y
sudo apt clean

echo " Container & K8s Tools Cleanup Completed!"
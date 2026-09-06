#!/usr/bin/env bash
set -euo pipefail

echo "============================================="
echo " Installing Docker, KIND, & K8s Tools"
echo "============================================="

# 1. Update Package Index & Install Repo Prereqs
sudo apt update
sudo apt install -y gnupg lsb-release curl wget

# 2. Install Docker Engine
DOCKER_VERSION="5:27.5.1-1~ubuntu.24.04~noble"
echo "Installing Docker Engine ${DOCKER_VERSION}..."

# Docker official GPG key
sudo install -m 0755 -d /etc/apt/keyrings

sudo curl -fsSL \
  https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc

sudo chmod a+r /etc/apt/keyrings/docker.asc

# Docker official APT repository - Deb822 .sources format
sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
sudo apt install -y \
  docker-ce="${DOCKER_VERSION}" \
  docker-ce-cli="${DOCKER_VERSION}" \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

# Prevent accidental docker upgrades
sudo apt-mark hold docker-ce docker-ce-cli containerd.io

# Gracefully start Docker Service (WSL2 + Native Linux friendly)
if command -v systemctl &>/dev/null && systemctl is-systemd-running &>/dev/null; then
    sudo systemctl enable --now docker || true
else
    sudo service docker start || true
fi

# Add current user to docker group
sudo usermod -aG docker "$USER"
echo "Note: Log out and back in (or run 'newgrp docker') to use Docker without sudo."

# 3. Install kubectl
KUBECTL_VERSION="v1.36.4"
echo "Installing kubectl ${KUBECTL_VERSION}..."
curl -fsSLO \
  "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -f kubectl

# 4. Install KIND
KIND_VERSION="v0.32.0"
echo "Installing KIND ${KIND_VERSION}..."
curl -fsSLo \
  kind \
  "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64"
chmod +x kind
sudo install -m 0755 kind /usr/local/bin/kind
rm -f kind

# 5. Install Helm
HELM_VERSION="v3.17.3"
echo "Installing Helm ${HELM_VERSION}..."
wget -q \
  "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz"

tar -xzf \
  "helm-${HELM_VERSION}-linux-amd64.tar.gz" \
  linux-amd64/helm

sudo install -m 0755 \
  linux-amd64/helm \
  /usr/local/bin/helm

rm -rf \
  linux-amd64 \
  "helm-${HELM_VERSION}-linux-amd64.tar.gz"

# 6. Verify Installations
echo "Container & K8s Tools Installed:"
echo "Docker: $(docker --version)"
echo "Docker Compose: $(docker compose version)"
echo "Docker Buildx: $(docker buildx version)"
echo "Containerd: $(containerd --version | awk '{print $3}')"
echo "kubectl: $(kubectl version --client)"
echo "KIND: $(kind --version)"
echo "Helm: $(helm version --short)"
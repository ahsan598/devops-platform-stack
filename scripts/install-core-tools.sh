#!/usr/bin/env bash
set -euo pipefail

echo "=============================================="
echo " Installing Core System & Debug Tools"
echo "=============================================="

# Update Package Index
sudo apt update

# 1. Install Essential Build & Debugging Packages
sudo apt install -y \
  build-essential ca-certificates software-properties-common \
  curl wget git tree vim unzip jq less \
  iproute2 net-tools dnsutils traceroute tcpdump htop strace lsof

# 2. Install Official Go-based yq
YQ_VERSION="v4.53.3"
echo "Installing yq ${YQ_VERSION}..."
sudo wget -q https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 -O /usr/local/bin/yq
sudo chmod +x /usr/local/bin/yq

# Verify Core Tools Installations
echo "Core Tools Installed Successfully:"
echo "Git: $(git --version)"
echo "Make: $(make --version | head -n1)"
echo "JQ: $(jq --version)"
echo "YQ: $(yq --version)"
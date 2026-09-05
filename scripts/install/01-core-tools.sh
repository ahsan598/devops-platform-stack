#!/usr/bin/env bash
set -euo pipefail

echo "=============================================="
echo " Installing Core System & Debug Tools"
echo "=============================================="

# 1. Update Package Index
sudo apt update

# 2. Install Essential Build & Debugging Packages
sudo apt install -y \
  build-essential ca-certificates software-properties-common \
  curl wget git tree vim unzip jq less make \
  iproute2 net-tools dnsutils traceroute tcpdump htop strace lsof

# 3. Install YQ (YAML Processor)
YQ_VERSION="v4.53.3"
echo "Installing yq ${YQ_VERSION}..."
sudo wget -q https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 -O /usr/local/bin/yq
sudo chmod +x /usr/local/bin/yq

# 4. Verify Core Tools Installations
echo "Core Tools Installed Successfully:"
echo "Git: $(git --version)"
echo "Make: $(make --version | head -n1)"
echo "JQ: $(jq --version)"
echo "YQ: $(yq --version)"
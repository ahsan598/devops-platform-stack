#!/usr/bin/env bash
set -euo pipefail

echo "=============================================="
echo " Cleaning Up Core System & Debug Tools"
echo "=============================================="

# 1. Remove Custom Installed Binary (yq)
if [ -f /usr/local/bin/yq ]; then
  echo "Removing /usr/local/bin/yq..."
  sudo rm -f /usr/local/bin/yq
fi

# 2. Purge System Installed Packages
echo "Purging installed debug & system tools..."
sudo apt purge -y \
  build-essential software-properties-common \
  tree vim unzip jq less make \
  net-tools dnsutils traceroute tcpdump htop strace lsof || true

# 3. Auto-remove Unused Dependencies & Clean Cache
echo "Cleaning apt packages and cache..."
sudo apt autoremove -y
sudo apt clean

echo " Core System Tools Cleanup Completed!"
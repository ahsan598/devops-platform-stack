#!/usr/bin/env bash
set -euo pipefail

echo "=============================================="
echo " Cleaning Up Runtimes & Package Managers"
echo "=============================================="

# 1. Remove NVM and Node.js Installations
NVM_DIR="${HOME}/.nvm"
if [ -d "${NVM_DIR}" ]; then
  echo "Removing NVM directory (${NVM_DIR})..."
  rm -rf "${NVM_DIR}"
fi

# Clean NVM lines from shell configuration profiles
echo "Cleaning up shell environment variables for NVM..."
sed -i '/NVM_DIR/d' ~/.bashrc ~/.profile 2>/dev/null || true
sed -i '/\[ -s "$NVM_DIR\/nvm.sh" \]/d' ~/.bashrc ~/.profile 2>/dev/null || true
sed -i '/\[ -s "$NVM_DIR\/bash_completion" \]/d' ~/.bashrc ~/.profile 2>/dev/null || true

# 2. Purge Java 21 LTS, Maven, and Python Stack
echo "Purging Java, Maven, and Python 3 stack..."
sudo apt purge -y \
  openjdk-21-jdk \
  maven \
  python3-pip \
  python3-venv \
  python3-full || true

# 3. Auto-remove Unused Dependencies & Clean Cache
echo "Cleaning up residual packages..."
sudo apt autoremove -y
sudo apt clean

echo " Runtimes Cleanup Completed Successfully!"
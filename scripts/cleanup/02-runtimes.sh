#!/usr/bin/env bash
set -euo pipefail

echo "=============================================="
echo " Cleaning Up Runtimes & Package Managers"
echo "=============================================="

# 1. Completely Remove NVM, Node.js, and Environment Variables
NVM_DIR="${HOME}/.nvm"
if [ -d "${NVM_DIR}" ]; then
  echo "Removing NVM directory (${NVM_DIR})..."
  rm -rf "${NVM_DIR}"
fi

# Wipe NVM & Node environment paths from interactive & login shells
echo "Purging NVM/Node configurations from shell files..."
sed -i '/NVM_DIR/d' ~/.bashrc ~/.profile ~/.bash_profile ~/.zshrc 2>/dev/null || true
sed -i '/nvm\.sh/d' ~/.bashrc ~/.profile ~/.bash_profile ~/.zshrc 2>/dev/null || true
sed -i '/bash_completion/d' ~/.bashrc ~/.profile ~/.bash_profile ~/.zshrc 2>/dev/null || true

# Unset NVM variables from current active shell session
unset NVM_DIR NVM_BIN NVM_INC NVM_CD_FLAGS 2>/dev/null || true
hash -r 2>/dev/null || true

# 2. Purge Java 21 LTS, Maven, and Python Stack
echo "Purging Java, Maven, and Python 3 stack..."
sudo apt purge -y \
  openjdk-21-jdk openjdk-21-jre-headless \
  maven \
  python3-pip \
  python3-venv \
  python3-full || true

# 3. Auto-remove Unused Dependencies & Clean APT Cache
echo "Cleaning up residual packages..."
sudo apt autoremove --purge -y
sudo apt clean

echo " Runtimes Cleanup Completed Successfully!"
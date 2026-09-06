#!/usr/bin/env bash
set -euo pipefail

echo "=============================================="
echo " Cleaning Up Cloud, IaC & Security Tools"
echo "=============================================="

# 1. Remove AWS CLI v2
echo "Removing AWS CLI v2..."
sudo rm -rf /usr/local/aws-cli
sudo rm -f /usr/local/bin/aws
sudo rm -f /usr/local/bin/aws_completer

# 2. Remove Terraform Binary
if [ -f /usr/local/bin/terraform ]; then
  echo "Removing Terraform binary..."
  sudo rm -f /usr/local/bin/terraform
fi

# 3. Uninstall Ansible Core via pipx & Purge pipx
echo "Uninstalling Ansible Core and cleaning pipx..."
export PATH="${HOME}/.local/bin:${PATH}"
if command -v pipx >/dev/null 2>&1; then
  pipx uninstall ansible-core 2>/dev/null || true
  pipx uninstall-all 2>/dev/null || true
fi
rm -rf "${HOME}/.local/pipx" "${HOME}/.local/bin/ansible"* 2>/dev/null || true
sudo apt purge -y pipx || true

# 4. Remove Trivy Security Scanner, Repo, and Keyring
echo "Removing Trivy scanner and repository settings..."
sudo apt-mark unhold trivy 2>/dev/null || true
sudo apt purge -y trivy || true
sudo rm -f /etc/apt/sources.list.d/trivy.list
sudo rm -f /usr/share/keyrings/trivy.gpg

# 5. Clean APT Cache and Dependencies
echo "Cleaning apt package cache..."
sudo apt autoremove -y
sudo apt clean

echo " DevOps Tools Cleanup Completed Successfully!"
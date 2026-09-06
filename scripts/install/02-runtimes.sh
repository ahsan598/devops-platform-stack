#!/usr/bin/env bash
set -euo pipefail

echo "==============================================="
echo " Installing Runtimes & Package Managers"
echo "==============================================="

# 1. Update Package Index
sudo apt update

# 2. Install Java 21 LTS + Maven
echo "Installing Java 21 LTS & Maven..."
sudo apt install -y openjdk-21-jdk maven

# 3. Install Python 3, Pip, and Venv Stack
echo "Installing Python 3 & environment utilities..."
sudo apt install -y \
  python3 \
  python3-pip \
  python3-venv \
  python3-full

# 4. Install Node.js 22 LTS via NVM
NODE_VERSION="22.23.1"
NVM_VERSION="v0.40.3"

export NVM_DIR="${HOME}/.nvm"

if [ ! -d "${NVM_DIR}" ]; then
  echo "Installing NVM ${NVM_VERSION}..."
  curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
fi

# Safe-source NVM under 'set -e'
if [ -s "${NVM_DIR}/nvm.sh" ]; then
  # Temporarily disable pipefail/exit-on-error for NVM internal script execution
  set +e +u
  # shellcheck disable=SC1091
  source "${NVM_DIR}/nvm.sh"
  set -eu
else
  echo "NVM installation script not found in ${NVM_DIR}."
  exit 1
fi

echo "Setting up Node.js ${NODE_VERSION}..."
if ! nvm ls "${NODE_VERSION}" &>/dev/null; then
  nvm install "${NODE_VERSION}"
fi

nvm alias default "${NODE_VERSION}"
nvm use "${NODE_VERSION}"

# 5. Verify Runtime & Package Manager Versions
echo "Runtimes & Build Tools Installed:"
echo "Java: $(java -version 2>&1 | head -n1)"
echo "Maven: $(mvn --version | head -n1)"
echo "Node.js: $(node --version)"
echo "npm: $(npm --version)"
echo "nvm: $(nvm --version)"
echo "Python: $(python3 --version)"
echo "Pip: $(pip3 --version)"
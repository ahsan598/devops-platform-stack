#!/usr/bin/env bash
set -euo pipefail

echo "============================="
echo " Installing Runtimes & Package Managers"
echo "============================="

# Update Package Index
sudo apt update

# 1. Install Java 21 LTS + Maven
echo "Installing Java 21 LTS & Maven..."
sudo apt install -y openjdk-21-jdk maven

# 2. Install Python 3 + pip + venv
echo "Installing Python 3 & pip..."

sudo apt install -y \
  python3 \
  python3-pip \
  python3-venv \
  python3-full

# 3. Install Node.js 22 + npm via NVM
NODE_VERSION="22.23.1"
NVM_VERSION="v0.40.3"

echo "Installing NVM ${NVM_VERSION}..."

if [ ! -d "${HOME}/.nvm" ]; then
    curl -fsSL \
      "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" \
      | bash
fi

# Load NVM into current shell
export NVM_DIR="${HOME}/.nvm"

if [ -s "${NVM_DIR}/nvm.sh" ]; then
    # shellcheck disable=SC1091
    source "${NVM_DIR}/nvm.sh"
else
    echo "NVM installation failed."
    exit 1
fi

echo "Installing Node.js ${NODE_VERSION}..."

nvm install "${NODE_VERSION}"
nvm alias default "${NODE_VERSION}"
nvm use "${NODE_VERSION}"

# Verify Runtime & Package Manager Versions
echo "Runtimes & Build Tools Installed:"
echo "Java: $(java -version 2>&1 | head -n1)"
echo "Maven: $(mvn --version | head -n1)"
echo "Node.js: $(node --version)"
echo "npm: $(npm --version)"
echo "Python: $(python3 --version)"
echo "Pip: $(pip3 --version)"
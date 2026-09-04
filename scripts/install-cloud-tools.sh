#!/usr/bin/env bash
set -euo pipefail

echo "=============================================="
echo " Installing Cloud, IaC & Security Tools"
echo "=============================================="

# Update Package Index
sudo apt update

# 1. Install AWS CLI v2
AWS_CLI_VERSION="2.35.24"
echo "Installing AWS CLI v${AWS_CLI_VERSION}..."
curl -fsSL \
  "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip" \
  -o awscliv2.zip
unzip -q awscliv2.zip
sudo ./aws/install --update
rm -rf aws awscliv2.zip

# 2. Install Terraform
TERRAFORM_VERSION="1.15.9"
echo "Installing Terraform v${TERRAFORM_VERSION}..."
wget -q "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
unzip -q "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
sudo mv terraform /usr/local/bin/
rm "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"

# 3. Install Ansible Core
ANSIBLE_VERSION="2.20.3"
echo "Installing Ansible Core v${ANSIBLE_VERSION}..."
sudo apt install -y pipx
pipx ensurepath

if command -v ansible >/dev/null 2>&1; then
    pipx upgrade ansible-core
else
    pipx install "ansible-core==${ANSIBLE_VERSION}"
fi

# 4. Install Trivy Security Scanner
TRIVY_VERSION="0.71.1"
echo "Installing Trivy v${TRIVY_VERSION}..."
wget -q "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.deb"
sudo dpkg -i "trivy_${TRIVY_VERSION}_Linux-64bit.deb"
sudo apt-mark hold trivy
rm "trivy_${TRIVY_VERSION}_Linux-64bit.deb"

# Verify Installations
echo "Cloud, IaC & Security Tools Installed:"
echo "AWS CLI: $(aws --version)"
echo "Terraform: $(terraform --version | head -n1)"
echo "Ansible: $(ansible --version | head -n1)"
echo "Trivy: $(trivy --version | head -n1)"
#!/usr/bin/env bash
set -euo pipefail

echo "=============================================="
echo " Installing Cloud, IaC & Security Tools"
echo "=============================================="

# 1. Update Package Index
sudo apt update

# 2. Install AWS CLI v2
AWS_CLI_VERSION="2.35.24"
echo "Installing AWS CLI v${AWS_CLI_VERSION}..."
curl -fsSL \
  "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip" \
  -o awscliv2.zip
unzip -q awscliv2.zip
sudo ./aws/install --update
rm -rf aws awscliv2.zip

# 3. Install Terraform
TERRAFORM_VERSION="1.15.9"
echo "Installing Terraform v${TERRAFORM_VERSION}..."
wget -q "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
unzip -q "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
sudo mv terraform /usr/local/bin/
rm "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"

# 4. Install Ansible Core via pipx
ANSIBLE_VERSION="2.20.3"
echo "Installing Ansible Core v${ANSIBLE_VERSION}..."
sudo apt install -y pipx
pipx ensurepath

# Ensure pipx binary directory is immediately in current script's PATH
export PATH="${HOME}/.local/bin:${PATH}"

if command -v ansible >/dev/null 2>&1; then
    pipx upgrade ansible-core || true
else
    pipx install "ansible-core==${ANSIBLE_VERSION}"
fi

# 5. Install Trivy Security Scanner
TRIVY_VERSION="0.71.1"
echo "Installing Trivy v${TRIVY_VERSION}..."

sudo install -m 0755 -d /usr/share/keyrings

wget -qO- https://aquasecurity.github.io/trivy-repo/deb/public.key \
    | gpg --dearmor \
    | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" \
    | sudo tee /etc/apt/sources.list.d/trivy.list > /dev/null

sudo apt update
sudo apt install -y "trivy=${TRIVY_VERSION}"
sudo apt-mark hold trivy

# 6. Verify Installations
echo "Cloud, IaC & Security Tools Installed:"
echo "AWS CLI: $(aws --version)"
echo "Terraform: $(terraform --version | head -n1)"
echo "Ansible: $(ansible --version | head -n1)"
echo "Trivy: $(trivy --version | head -n1)"
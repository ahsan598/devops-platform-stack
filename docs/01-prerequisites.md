# 📋 System Prerequisites & Environment Setup

Before provisioning tools and infrastructure, verify that your host environment (**Native Linux or Windows WSL2**) meets the necessary resource and system thresholds.


### 1. System Hardware Requirements
| Resource | Minimum Required | Recommended for Full Stack |
| :--- | :--- | :--- |
| **RAM** | 8 GB | 16 GB (To run KIND + Jenkins + Sonar + Monitoring concurrently) |
| **CPU Cores** | 4 Cores (8 Threads) | 8 Cores |
| **Disk Space** | 25 GB Free (SSD) | 50 GB Free (NVMe SSD preferred) |

### 2. Windows WSL2 Setup (Optional — Windows Users Only)
If you are running on Windows via WSL2, create or update `%USERPROFILE%\.wslconfig` in Windows to allocate sufficient resources:
```ini
[wsl2]
memory=8GB          # Limits memory in WSL2 (Increase to 12GB/16GB if available)
processors=4        # Limits CPU cores in WSL2
swap=4GB            # Swap memory space
localhostForwarding=true
```
> Note for Native Linux Users: If you are running on native Ubuntu/Debian, skip Section 2 and proceed directly to system package updates.

### 3. Base Ubuntu/Linux Preparation
Run these baseline system checks and update package indices in your terminal (Works on **Native Ubuntu 24.04 & WSL2**):
```sh
# Update System Packages
sudo apt update && sudo apt upgrade -y

# Install Essential System Build Tools & Debugging Utilities
sudo apt install -y \
  build-essential ca-certificates software-properties-common \
  curl wget git tree vim unzip jq less \
  iproute2 net-tools dnsutils traceroute tcpdump htop strace lsof

# Verify Kernel and Ubuntu Version
uname -r
cat /etc/os-release
```

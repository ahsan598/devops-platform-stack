# 📋 System Prerequisites & Environment Setup

Before provisioning tools and infrastructure, verify that your host environment (**Native Linux or Windows WSL2**) meets the necessary resource and system thresholds.


### 1. System Hardware Requirements
| Resource | Minimum Required | Recommended for Full Stack |
| :--- | :--- | :--- |
| **RAM** | 12 GB | 16 GB (To run KIND + Jenkins + Sonar + Monitoring concurrently) |
| **CPU Cores** | 6 Cores (8 Threads) | 8 Cores |
| **Disk Space** | 25 GB Free (SSD) | 50 GB Free (NVMe SSD preferred) |

### 2. Windows WSL2 Setup (Optional — Windows Users Only)
If you are running on Windows via WSL2, create or update `%USERPROFILE%\.wslconfig` in Windows to allocate sufficient resources:
```ini
[wsl2]
memory=12GB  	    # Set max RAM (adjust as needed)
processors=6  	        # Set CPU cores
swap=2GB  	            # Optional: Swap space
localhostForwarding=true
```
> Note for Native Linux Users: If you are running on native Ubuntu/Debian, skip Section 2 and proceed directly to `cgroup v2` configuration.

### 3. Control group v2 (cgroup v2) Configuration
Kubernetes **v1.36+** (e.g., `v1.36.4`) requires **cgroup v2** for proper resource accounting and systemd init driver compatibility inside Kind node containers.

**a. Enable cgroup v2 in WSL2**
- Create or update your `%USERPROFILE%\.wslconfig` file on your Windows host (or `/etc/wsl.conf` inside Linux)
  ```ini
  [wsl2]
  kernelCommandLine = cgroup_no_v1=all
  ```
- After modifying the configuration, restart WSL2 from PowerShell/Terminal:
  ```sh
  wsl --shutdown
  ```
**b. Verify cgroup v2 in WSL2/Ubuntu**
Inside your WSL2 shell/Terminal, verify that cgroup v2 is active:
```sh
stat -fc %T /sys/fs/cgroup
# Output must be: cgroup2fs
```

### 4. Base Preparation
Update the system package index and upgrade installed packages:
```sh
# Update System Packages
sudo apt update && sudo apt upgrade -y

# Verify Kernel and Ubuntu Version
uname -r
cat /etc/os-release
```

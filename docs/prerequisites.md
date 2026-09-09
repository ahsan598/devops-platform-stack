# 📋 System Prerequisites & Environment Setup

Before provisioning tools and infrastructure, verify that your host environment (**Native Linux or Windows WSL2**) meets the necessary resource and system thresholds.

### 1. System Hardware Requirements
| Resource | Minimum Required | Recommended for Full Stack |
| :--- | :--- | :--- |
| **RAM** | 8 GB | 16 GB (To run KIND + Jenkins + Sonar + Monitoring concurrently) |
| **CPU Cores** | 4 Cores (8 Threads) | 8 Cores |
| **Disk Space** | 25 GB Free (SSD) | 50 GB Free (NVMe SSD preferred) |

### 2. Base Preparation
Update the system package index and upgrade installed packages:
```sh
# Update System Packages
sudo apt update && sudo apt upgrade -y

# Verify Kernel and Ubuntu Version
uname -r
cat /etc/os-release
```
![os-details](/assets/os-requirements.jpg)

### 3. WSL2 Setup (Optional — Windows Users Only)
If you are running on Windows via WSL2, create or update `%USERPROFILE%\.wslconfig` in Windows to allocate sufficient resources:
```ini
[wsl2]
memory=8GB  	    # Set max RAM (adjust as needed)
processors=4  	        # Set CPU cores
swap=4GB  	            # Optional: Swap space
localhostForwarding=true
```

### 4. Control group v2 (cgroup v2) Configuration
Kubernetes **v1.36+** (e.g., `v1.36.4`) requires **cgroup v2** for proper resource accounting, cgroup limits, and systemd init driver compatibility inside Kind node containers.

- **Native Linux / EC2 (Ubuntu 22.04 / 24.04 LTS):** `cgroup v2` is enabled by default out of the box. No kernel parameters or host changes are required.
- **Enable cgroup v2 in WSL2:** WSL2 custom kernels may still fall back to `cgroup v1`. You must explicitly force `cgroup v2`.

  a. Configure `%USERPROFILE%\.wslconfig` on Windows:
    ```ini
    [wsl2]
    kernelCommandLine = cgroup_no_v1=all
    ```
  b. Restart WSL2 from PowerShell / Command Prompt:
    ```sh
    wsl --shutdown
    ```
- **Verification (Both Native Linux & WSL2):** Run the following command inside your Linux terminal to confirm active `cgroup v2`:
  ```sh
  stat -fc %T /sys/fs/cgroup
  # Output must be: cgroup2fs
  ```
  ![cgroup](/assets/wsl-cgroupv2.jpg)

### 5. Host System Tuning (`inotify` File Watch Limits)
Observability tools like Fluent Bit, Prometheus, and Loki monitor a vast number of active log files and metrics streams. Increasing `inotify` limits prevents `too many open files` errors and log tailing exhaustion.
> [!NOTE]
> This host-level tuning is mandatory for both Native Linux/EC2 and WSL2 environments.

```sh
# 1. Increase inotify watches and instances limits permanently
echo "fs.inotify.max_user_watches=524288" | sudo tee -a /etc/sysctl.conf
echo "fs.inotify.max_user_instances=8192" | sudo tee -a /etc/sysctl.conf

# 2. Reload sysctl configuration and apply limits immediately
sudo sysctl -p
```

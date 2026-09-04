# ⚡Execution Quick-Start

Make all setup scripts executable and run them in order
```sh
# Grant execution permissions
chmod +x scripts/*.sh

# Execute setup sequence
./scripts/install-core-tools.sh
./scripts/install-runtimes.sh
./scripts/install-container-tools.sh
./scripts/install-devops-tools.sh
```

### 📋 Note
- Tool versions are explicitly pinned where applicable to ensure reproducible environments.
- **OS-Dependent Package Strings:** Certain package version strings depend directly on your Linux release/codename. For example, Docker Engine package pinning varies by OS version:
  - `DOCKER_VERSION="5:27.5.1-1~ubuntu.24.04~noble" (Ubuntu 24.04 Noble)`
  - `DOCKER_VERSION="5:27.5.1-1~ubuntu.22.04~jammy" (Ubuntu 22.04 Jammy)`
- After running `install-docker-k8s.sh`, refresh your group membership by running `newgrp docker` (or restart your terminal) to run Docker without `sudo`.

### 🔒 Optional: Lock Tool Versions (Prevent Auto-Upgrades)
To prevent package managers from accidentally upgrading production-critical binaries during routine `apt upgrade` runs:
```sh
# Hold Docker and Trivy versions
sudo apt-mark hold docker-ce docker-ce-cli containerd.io trivy

# Verify currently held packages
apt-mark showhold

# Release version hold when ready to upgrade
sudo apt-mark unhold docker-ce docker-ce-cli containerd.io trivy
```

# ⚡Execution Quick-Start

Make all setup scripts executable and run them in order
```sh
# Grant execution permissions
chmod +x scripts/install/*.sh

# Execute setup sequence
./scripts/install/01-core-tools.sh
./scripts/install/02-runtimes.sh
./scripts/install/03-devops-tools.sh
./scripts/install/04-container-tools.sh
```

### 📋 Note
- Tool versions are explicitly pinned where applicable to ensure reproducible environments.
- **OS-Dependent Package Strings:** Certain package version strings depend directly on your Linux release/codename. For example, Docker package pinning varies by OS version.
  - Ubuntu 24.04 Noble:
    ```sh
    DOCKER_VERSION="5:27.5.1-1~ubuntu.24.04~noble"
    ```
  - Ubuntu 22.04 Jammy:
    ```sh
    DOCKER_VERSION="5:27.5.1-1~ubuntu.22.04~jammy"
    ```
  - To find the Docker package version available for your specific OS refer [Official Docker Repository](https://download.docker.com/linux/ubuntu).
    ```sh
    # check currently installed and candidate versions for installation
    apt-cache policy docker-ce

    # list all available exact version strings for your Ubuntu release
    apt-cache madison docker-ce
    ```
  - Use the exact version string from `apt-cache madison` or shown under Candidate in `apt-cache policy` when pinning the package.

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

### Cleanup tools from system

Make all cleanup scripts executable and run them in order
```sh
# Grant execution permissions
chmod +x scripts/cleanup/*.sh

# Execute cleanup sequence
./scripts/cleanup/01-core-tools.sh
./scripts/cleanup/02-runtimes.sh
./scripts/cleanup/03-devops-tools.sh
./scripts/cleanup/04-container-tools.sh
```
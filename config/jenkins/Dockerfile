# Base image on Jenkins LTS tracking Java 21 (Debian 12 / Bookworm)
FROM jenkins/jenkins:lts-jdk21

# Elevate to root user to install additional tools
USER root

# --------------------------------------------------------------------------
# Explicitly set pinned tool versions matching Debian Bookworm
# --------------------------------------------------------------------------
ARG DOCKER_CLI_VERSION=5:27.5.1-1~debian.12~bookworm
ARG KUBECTL_VERSION=v1.34.3
ARG HELM_VERSION=v3.17.3
ARG TRIVY_VERSION=0.71.1

# --------------------------------------------------
# Install essential packages
# --------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl git unzip wget tar gzip gnupg \
    && rm -rf /var/lib/apt/lists/*

# --------------------------------------------------
# Install Docker CLI (Debian Bookworm)
# --------------------------------------------------
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian bookworm stable" \
        > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        docker-ce-cli=${DOCKER_CLI_VERSION} && \
    rm -rf /var/lib/apt/lists/*

# --------------------------------------------------
# Install kubectl
# --------------------------------------------------
RUN curl -fsSL \
    "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
    -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl

# --------------------------------------------------
# Install Helm
# --------------------------------------------------
RUN curl -fsSL \
    "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" \
    -o /tmp/helm.tar.gz && \
    tar -xzf /tmp/helm.tar.gz -C /tmp && \
    mv /tmp/linux-amd64/helm /usr/local/bin/helm && \
    chmod +x /usr/local/bin/helm && \
    rm -rf /tmp/helm.tar.gz /tmp/linux-amd64

# --------------------------------------------------
# Install Trivy (Security Scanner)
# --------------------------------------------------
RUN curl -fsSL \
    "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz" \
    -o /tmp/trivy.tar.gz && \
    tar -xzf /tmp/trivy.tar.gz -C /usr/local/bin trivy && \
    chmod +x /usr/local/bin/trivy && \
    rm /tmp/trivy.tar.gz

# --------------------------------------------------
# Verify installations
# --------------------------------------------------
RUN set -eux; \
    java --version; \
    git --version; \
    docker --version; \
    kubectl version --client; \
    helm version; \
    trivy --version

# Return to Jenkins user
USER jenkins

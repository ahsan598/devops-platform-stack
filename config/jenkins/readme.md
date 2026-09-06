# 🔄 CI/CD Infrastructure Stack
This repository spins up a production-ready CI/CD environment comprising Jenkins (Custom Agent), SonarQube (with PostgreSQL backend), and Nexus Repository Manager 3.

### 🚀 Stack Overview
| Service | Container Name | Port | Base Image / Version |
| :--- | :--- | :--- | :--- |
| **Jenkins** | `jenkins` | `8080`, `50000` | Custom Image (`devops-jenkins:1.0`) built on `jenkins/jenkins:lts-jdk21` |
| **SonarQube** | `sonarqube` | `9000` | `sonarqube:community` |
| **SonarQube DB** | `sonarqube_db` | Internal (`5432`) | `postgres:17-alpine` |
| **Nexus 3** | `nexus` | `8081` | `sonatype/nexus3:3.87.2` |


### 🏗️ Architectural & Design Decisions

**1. Why a Custom Jenkins Image (`devops-jenkins:1.0`)?**

The stock vanilla Jenkins image lacks essential build and DevOps tools out of the box. To prevent pipeline execution errors and avoid installing tools at runtime:
   - **Pre-baked CLI Tools:** Essential tools like **Docker CLI, Helm, Kubectl, and Trivy** are installed directly into the image layer.
   - **Exact Docker CLI Pinning:** To guarantee deterministic builds, the Docker CLI version is pinned to `5:27.5.1-1~debian.12~bookworm` fetched explicitly from the official [Debian Docker Repository](https://download.docker.com/linux/debian/) using Debian-12 (`bookworm`) package sources.

**2. Docker Out of Docker (DooD) Setup**

The Jenkins container is granted access to the host's Docker daemon to build container images inside pipelines:
  - **Socket Mounting:** The host socket `/var/run/docker.sock` is mounted directly into the container.
  - **Permission Alignment:** `group_add:` **[${DOCKER_GID}]** passes the host machine's Docker group ID to eliminate permission issues for the `jenkins` user.

**3. Kubernetes & Cluster Integration**
- **Multi-Network Binding:** Attached to the `kind` network to allow direct communication with a local KIND Kubernetes cluster.
- **Read-Only Kubeconfig:** The cluster config is mounted at `./jenkins-kubeconfig:/var/jenkins_home/.kube/config:ro` allowing automated deployment jobs to interact with Kubernetes securely.

**4. Dedicated Database for SonarQube**

SonarQube's default embedded **H2 database** is not intended for production usage:
  - A dedicated `postgres:17-alpine` service handles database persistence.
  - A strict `healthcheck` constraint is defined under `depends_on` to ensure SonarQube waits until PostgreSQL is fully ready to accept connections.

### 💾 Persistent Volumes
Persistent volumes prevent data loss when containers are stopped or recreated:
  - `jenkins_data`: Stores Jenkins configurations, build logs, and installed plugins.
  - `sonarqube_data`, `sonarqube_extensions`, `sonarqube_logs`: Keeps SonarQube plugins, dynamic data, and system logs safe.
  - `sonarqube_db_data`: Preserves PostgreSQL databases and project code analysis metrics.
  - `nexus_data`: Retains hosted artifacts, raw repositories, and private Docker registries.

### 🗺️ Recommended Stack Setup Order
1. Create External Networks (`docker network create cicd_network kind`)
2. Create Kind Cluster (`kind create cluster --name dev-cluster --config kind-config.yaml`)
3. Extract Host Docker GID & Patch Kubeconfig (`.env` & `jenkins-kubeconfig`)
4. Build Jenkins Image & Deploy Stack (`docker compose up -d --build`)
5. Verify Integrations (`kubectl get nodes` inside Jenkins)


### ⚡ Quick Start
1. Create required external Docker networks:
```sh
docker network create cicd_network
docker network create kind
```
2. Set the host Docker GID in your `.env` file:
```sh
echo "DOCKER_GID=$(getent group docker | cut -d: -f3)" > .env
```

### 🔗 Jenkins to Kind Kubernetes Integration
Jenkins runs outside the Kind cluster as a Docker container. To enable `kubectl` deployments from Jenkins pipelines to your local Kind cluster, follow these 3 critical steps:

**1. Isolated Kubeconfig Copy**

Do not mount your host's `~/.kube/config` directly. Create a dedicated copy for Jenkins: 
```sh
cp ~/.kube/config ./jenkins-kubeconfig
```
Mount this copy as read-only in `docker-compose.yml`:
```sh
volumes:
  - ./jenkins-kubeconfig:/var/jenkins_home/.kube/config:ro
```

**2. Update API Server Endpoint**

Inside the Jenkins container, `127.0.0.1` refers to the container itself.
Edit `./jenkins-kubeconfig` and change the cluster server address:
- Change from: `server: [https://127.0.0.1:<port:number>]`
- Change to: `server: https://<kind-control-plane-container-name>:6443`
  - (e.g., `https://dev-cluster-control-plane:6443`)
- Keep all original CA certificates and token data unchanged.

**3. Dual Network Attachment**

Jenkins must sit on both the `cicd_network` and `kind` Docker networks:
```sh
networks:
  - cicd_network
  - kind
```

4. Build the custom Jenkins image and launch all containers in the background:
  ```sh
  docker compose up -d --build
  ```

### 🛠️ Verification Commands
Validate Jenkins container access, Kubernetes connectivity, and Docker integration:
```sh
# 1. Access Jenkins container shell
docker exec -it jenkins bash

# 2. Verify Kubernetes API server reachability
curl -k https://dev-cluster-control-plane:6443/version

# 3. Verify kubectl context
kubectl config current-context

# 4. Verify Kubernetes node visibility
kubectl get nodes

# 5. Verify Docker container access
docker ps -a

# 6. Verify Docker images
docker images
```

### 🔐 Initial Credentials & Access Secrets
After containers are up and running, fetch your initial passwords using the commands below:

1. Jenkins
  - URL: http://localhost:8080
  - Default User: `admin`
  - Password Command: `docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword`

2. SonarQube
  - URL: http://localhost:9000
  - Default Credentials: `admin` / `admin`
  - (Note: You will be prompted to set a new password on your initial login.)

3. Nexus Repository 3
  - URL: http://localhost:8081
  - Default User: `admin`
  - Password Command: `docker exec -it nexus cat /nexus-data/admin.password`

### ⚠️ Troubleshooting Common Pitfalls
| Issue | Root Cause | Exact Fix |
| :--- | :--- | :--- |
| Permission denied on `/var/run/docker.sock` | Host Docker GID mismatch with container user group. | Run `echo "DOCKER_GID=$(stat -c '%g' /var/run/docker.sock)" > .env` and restart stack via `docker compose up -d` |
| Connection refused on `127.0.0.1:6443` | Kubeconfig pointing to host localhost instead of Kind container. | Update `./jenkins-kubeconfig` to point to `https://<kind-control-plane-container>:6443` |
| Could not resolve host | Jenkins is not on the same Docker network as Kind. | Ensure `kind` network is declared under `external: true` and attached to the `jenkins` service. |
| SSL Certificate Validation Errors | Self-signed certs used by Kind API server in curl tests. | Use `curl -k` for testing raw connectivity. `kubectl` will handle TLS automatically via the embedded CA data in `jenkins-kubeconfig` |


### 🛠️ Compose Lifecycle
| Action               | Command                        | Purpose                                        |
| -------------------- | ------------------------------ | ---------------------------------------------- |
| **Build Jenkins**    | `docker compose build jenkins` | Builds/rebuilds the Jenkins image              |
| **Start**            | `docker compose up -d`         | Creates and starts containers in detached mode |
| **Check Status**     | `docker compose ps`            | Shows running/stopped Compose containers       |
| **Stop**             | `docker compose stop`          | Stops containers without removing them         |
| **Start Again**      | `docker compose start`         | Starts previously stopped containers           |
| **Remove**           | `docker compose down`          | Stops and removes Compose containers           |
| **Remove + Volumes** | `docker compose down -v`       | Removes containers **and named volumes**       |

> [!NOTE]
> - Daily use: `stop` / `start` is enough when you just want to pause and resume the stack.
> - Use `down` when you want to remove the Compose containers. Named volumes are normally retained unless you explicitly use `-v`.

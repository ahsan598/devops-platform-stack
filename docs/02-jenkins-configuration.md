#  🚀 Jenkins Core Configuration & Essential Plugins Guide

A streamlined guide for configuring plugins, global tools, system settings, and credentials in Jenkins.

### 📦 1. Essential Plugins List
Jenkin's base installation does not include support for some critical DevOps tools. After completing the initial setup, install the following plugins first:

| Plugin Category | Plugin Name | Purpose |
| :--- | :--- | :--- |
| **Pipeline & UI** | `Pipeline` | Core Declarative & Scripted pipeline engine |
| **Container & K8s** | `Docker Pipeline`, `Kubernetes` | Ephemeral container agents & Docker build stages |
| **SCM & Cloud** | `GitHub Integration`, `Pipeline: AWS Steps` | Git webhooks & AWS credential/CLI operations |
| **Build & Config** | `Pipeline Maven Integration`, `Config File Provider` | Automated Maven builds & global `settings.xml` injection |
| **Security & Quality** | `Credentials Binding`, `SonarQube Scanner` | Secure secret injection & static code analysis / quality gates |


### 🔌 2. Installing Plugins
1. Navigate to **Manage Jenkins → Plugins** (or **Manage Plugins**).
2. Go to the **Available plugins** tab and search for the required plugins.
3. Select the target plugins using the checkboxes.
4. Click **Install without restart** (or **Download now and install after restart**).
5. Check "**Restart Jenkins when installation is complete**" if prompted to finalize.


### 🛠️ 3. Global Tool Configuration (Tools)
Configure default binary paths for runtimes and compilers (JDK, Git, Maven, Docker, Terraform).
1. Navigate to **Manage Jenkins → Tools** (formerly **Global Tool Configuration**).
2. Scroll to the desired tool section (**JDK, Git, Maven, or Docker**).
3. Click **Add [Tool Name]:**
   - **Name:** Set a standard reference name (e.g., `JDK-17`, `Maven-3.8`).
   - **Installation Source**: Choose Install automatically OR provide the explicit path under `JAVA_HOME /` Path to Git executable on the host agent.
4. Click **Save**.


### ⚙️ 4. System Configuration (Configure System)
Manage global environments, URLs, and server integrations.
1. Navigate to **Manage Jenkins → System** (formerly **Configure System**).
2. Update key operational settings:
   - **Jenkins URL:** Set the accessible external/internal IP or DNS (e.g., `http://localhost:8080/`).
   - **System Admin e-mail address:** Configure the sender address for alerts.
   - **Extended E-mail Notification:** Configure SMTP settings (Host, Port, SSL, Credentials) for pipeline notifications.
   - **SonarQube / Argo CD Servers:** Add server URLs and secret tokens for integration.
3. Click **Save**.


### 🔑 5. Adding Credentials
Store sensitive data (passwords, SSH keys, API tokens) securely using the Credentials Provider.
1. Navigate to **Manage Jenkins → Credentials → System → Global credentials (unrestricted)**.
2. Click **+ Add Credentials**.
3. Select the appropriate **Kind:**
   - **Username with password:** Docker Registry, Git HTTP login.
   - **SSH Username with private key:** Git SSH access, EC2 Deployment keys.
   - **Secret text:** SonarQube Tokens, GitHub Personal Access Tokens (PAT).
4. Fill in the details:
   - **ID:** Provide a clean identifier (e.g., `github-pat-token`, `dockerhub-creds`). This ID is used directly inside `Jenkinsfile`.
   - **Secret / Password:** Paste the secret value.
5. Click **Create / OK**.

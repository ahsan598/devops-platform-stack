#  🚀 Jenkins Configuration & Plugin Setup

A streamlined guide for Jenkins to install essential plugins, configure tools, set up external integrations (SonarQube, Nexus, Kubernetes, GitHub), and run declarative CI/CD pipelines.

### Step-1: Essential Plugins Installation
Jenkins' base installation lacks out-of-the-box support for many modern DevOps tools. Install these essential plugins first:

| Plugin Category | Plugin Name | Purpose |
| :--- | :--- | :--- |
| **Pipeline & UI** | `Pipeline Stage View` | Visual representation of pipeline stages and execution status |
| **Container & K8s** | `Docker Pipeline`, `Kubernetes` | Ephemeral container agents & Docker build stages |
| **SCM & Cloud** | `GitHub Integration`, `Pipeline: AWS Steps`, `AWS Credentials` | Git webhooks, AWS credentials management (IAM), and AWS CLI pipeline steps |
| **Build & Config** | `Pipeline Maven Integration`, `Config File Provider`, `Eclipse Temurin Installer` | Automated Maven builds, global `settings.xml` management & dynamic JDK (JDK 8/17) auto-installation |
| **Security & Quality** | `SonarQube Scanner`, `OWASP Dependency-Check` | Static code analysis, quality gates & dependency vulnerability scanning |


#### How to install:
1. Navigate to **Manage Jenkins → Plugins**.
2. Go to the **Available plugins** tab and search for the required plugins above, and select them.
3. Click **Install without restart** (or restart if prompted).


### Step-2: Global Tool Configuration 
Configure global binary paths for runtimes and compilers (JDK, Git, Maven, Docker, Security Scanners).
1. Navigate to **Manage Jenkins → Tools**.
2. Scroll to the desired tool section (**JDK, Git, Maven etc.**).
3. Click **Add [Tool Name]:**
   - **Name:** Set a standard reference name (e.g., `JDK-17`, `Maven-3.8`).
   - **Installation Source**: Choose Install automatically OR provide the explicit path under `JAVA_HOME /` Path to Git executable on the host agent.
4. Click **Save**.


### Step-3: System Configuration
Manage global environments, URLs, and server integrations.
1. Navigate to **Manage Jenkins → System**.
2. Update key operational settings:
   - **Jenkins URL:** Set the accessible external/internal IP or DNS (e.g., `http://localhost:8080/`).
   - **System Admin e-mail address:** Configure the sender address for alerts.
   - **Extended E-mail Notification:** Configure SMTP settings (Host, Port, SSL, Credentials) for pipeline notifications.
   - **SonarQube / Argo CD Servers:** Add server URLs and secret tokens for integration.
3. Click **Save**.


### Step-4: Managing Credentials securely
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
5. Click **Create**.


### Step 5: Declarative Pipeline Job Setup

Set up a Jenkins pipeline job that pulls your repository's Jenkinsfile to execute your automated workflow.

1. Go to **Jenkins Dashboard → New Item**.
2. Enter a job name (e.g., `app-ci-pipeline`), select **Pipeline**, and click **OK**.
3. Under the **Pipeline** section:
   - **Definition:** Choose **Pipeline script from SCM** (Recommended) or **Pipeline script**.
    - If using **Pipeline** script, paste your Jenkinsfile.
4. Click **Save**.

> [!TIP]
>  Refer to the official [Jenkins Pipeline Syntax Guide](https://www.jenkins.io/doc/book/pipeline/syntax/) when writing your pipeline scripts.


### Step 6: External Integrations Setup

#### 1. SonarQube Quality Gate Webhook
Configure SonarQube to send Quality Gate status updates back to Jenkins:
- In SonarQube, go to **Administration → Configuration → Webhooks**.
- Click **Create** and configure:
  - Name: `jenkins-webhook`
  - URL: `http://<your-jenkins-ip>:8080/sonarqube-webhook/`

#### 2. GitHub Webhook Setup
Trigger Jenkins builds automatically whenever code is pushed to your GitHub repository.

> [!NOTE]
> If Jenkins is running locally inside a docker containe, GitHub cannot reach `http://localhost:8080`.
> 
> Expose your local container port using a tool like [**ngrok**](https://ngrok.com/) (`ngrok http 8080`) to get a public URL (e.g., `https://xxxx.ngrok-free.app`).
>
>  **Install ngrok:** `sudo snap install -y ngrok` & verify `ngrok --version`.

**a. Configure Jenkins Job**
- Go to your  **Pipeline Job → Click Configure**.
- Under the **Build Triggers** section, check:
  - `GitHub hook trigger for GITScm polling`
- Click **Save**.

**b. Configure Webhook in GitHub**
- Open your repository on **GitHub → Settings → Webhooks**.
- Click **Add webhook**.
- Fill in the following details:
  - Payload URL: `http://<your_public_ip_or_ngrok_url>/github-webhook/`
  - **Content type:** Select `application/json`.
  - **Secret:** Leave blank (or enter a secret if configured in Jenkins).
  - Which events would you like to trigger **this webhook?** Select Just the **push events**.
- Click **Add webhook**.

#### 3. Kubernetes Application Dependencies

> [!IMPORTANT]
> Managing Database & App Dependencies in Kubernetes

Always structure your Kubernetes manifests in a separate `k8s/` folder inside your repository:
```txt
my-app-repo/
├── k8s/
│   ├── 01-namespace.yaml
│   ├── 02-configmap.yaml   (DB Host, Port, non-sensitive config)
│   ├── 03-secret.yaml      (DB Username/Password, API keys)
│   └── 04-deployment.yaml  (App deployment referencing ConfigMap & Secret)
└── README.md
```
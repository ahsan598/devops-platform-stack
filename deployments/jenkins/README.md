# 🔄 Jenkins Setup Guide

Essential pipeline configurations, tool integrations and github webhook setup.

### 1. Declarative Pipeline Job Setup
Configure a Jenkins pipeline using a repository `Jenkinsfile` to run your complete CI/CD workflow as code (checkout, build, test, deploy, and cleanup).
1. Go to **Jenkins Dashboard → New Item**.
2. Enter a job name (e.g., `app-ci-pipeline`), select **Pipeline**, and click **OK**.
3. Under the **Pipeline** section:
   - **Definition:** Choose **Pipeline script from SCM** (Recommended) or **Pipeline script**.
    - If using **Pipeline** script, paste your [Jenkinsfile](./jenkinsfile).
4. Click **Save**.


### 2. SonarQube Maven Integration
Choose one of the following options:

**Option A (Update `pom.xml`):**
- Add the plugin group to use the short `mvn sonar:sonar` command:
  ```xml
  <pluginGroups>
      <pluginGroup>org.sonarsource.scanner.maven</pluginGroup>
  </pluginGroups>
  ```

**Option B (Direct Execution):**
- Run the full plugin name directly in your pipeline or CLI without modifying `pom.xml`:
  ```sh
  sh 'mvn org.sonarsource.scanner.maven:sonar-maven-plugin:sonar'
  ```

### 3. SonarQube Quality Gate Webhook
Configure SonarQube to send Quality Gate status updates back to Jenkins:
- **Webhook Name:** `jenkins-webhook`
- **URL:** `http://jenkins:8080/sonarqube-webhook`

### 4. Nexus Repository Setup
**1. Configure Maven Credentials (`settings.xml`)**
- Add server credentials for repository deployment:
  ```xml
  <settings>
    <servers>
      <server>
        <id>maven-releases</id>
        <username>${env.NEXUS_USERNAME}</username>
        <password>${env.NEXUS_PASSWORD}</password>
      </server>
      <server>
        <id>maven-snapshots</id>
        <username>${env.NEXUS_USERNAME}</username>
        <password>${env.NEXUS_PASSWORD}</password>
      </server>
    </servers>
  </settings>
  ```

**2. Add Target Repositories (`pom.xml`)**
- Add the deployment destinations to your project's `pom.xml`:
  ```xml
  <distributionManagement>
    <repository>
      <id>maven-releases</id>
      <url>http://localhost:8081/repository/maven-releases/</url>
    </repository>
    <snapshotRepository>
      <id>maven-snapshots</id>
      <url>http://localhost:8081/repository/maven-snapshots/</url>
    </snapshotRepository>
  </distributionManagement>
  ```

> [!TIP]
> Appending `-SNAPSHOT` to your version tag (e.g., `<version>4.0.0-SNAPSHOT</version>`) routes builds to the snapshot repository for testing.

### 5. Kubernetes Setup & Database Prerequisites
If your project requires cluster secrets or namespaces, create them beforehand using `kubectl`.

**Note:** The example below uses a **PostgreSQL** setup for a sample application (`spring-petclinic`). Update the namespace, secret names, host, and credentials according to your specific project's requirements.
```sh
# 1. Create target namespace (replace 'webapps' with your namespace)
kubectl create ns webapps

# 2. Create database secret (update keys/values to match your project's DB)
kubectl create secret generic demo-db \
  --namespace=webapps \
  --from-literal=type=postgres \
  --from-literal=provider=postgresql \
  --from-literal=host=postgres.webapps.svc.cluster.local \
  --from-literal=port=5432 \
  --from-literal=database=petclinic \
  --from-literal=username=postgres \
  --from-literal=password=postgres
```

### 6. GitHub Webhook Setup
Follow these steps to trigger Jenkins builds automatically whenever code is pushed to GitHub.

> [!NOTE]
> Since Jenkins is running inside a Docker container on localhost, GitHub cannot reach `http://localhost:8080`.
> 
> Expose your local container port using a tool like [**ngrok**](https://ngrok.com/) (`ngrok http 8080`) to get a public URL (e.g., `https://xxxx.ngrok-free.app`).
>
>  **Install ngrok:** `sudo snap install -y ngrok` & verify `ngrok --version`.

**Step 1: Configure Jenkins Job**
- Go to your Jenkins Dashboard and open your **Pipeline Job**.
- Click **Configure**.
- Under the Build Triggers section, check:
  - `GitHub hook trigger for GITScm polling`
- Click **Save**.

**Step 2: Configure Webhook in GitHub**
- Open your repository on **GitHub → Go to Settings → Webhooks**.
- Click **Add webhook**.
- Fill in the following details:
  - Payload URL: `http://<YOUR_PUBLIC_IP_OR_NGROK_URL>/github-webhook/`
  - **Content type:** Select `application/json`.
  - **Secret:** Leave blank (or enter a secret if configured in Jenkins).
  - Which events would you like to trigger **this webhook?** Select Just the push event.
- Click **Add webhook**.
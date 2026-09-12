## 🔄 Jenkins Job Setup

### 1. Freestyle Job Setup

Create and configure a Jenkins Freestyle job to automate the build, test, and deployment process. This includes configuring source code management, build triggers, build steps, environment variables, and post-build actions.
1. Go to **Jenkins Dashboard → New Item**.
2. Enter Job Name (e.g., `legacy-maven-build`) and select **Freestyle project → Click OK**.
3. Under **General**, check **Discard old builds** and set **Max # of builds to keep to 3**.
4. Under **Source Code Management**, select Git:
   - **Repository URL:** Enter your repository Git URL.
   - **Branch Specifier:** Set your target branch (e.g., `*/main`).
5. Under **Build Steps**, click **Add build step → Execute shell**.
6. Enter the build script:
   ```sh
   #!/bin/bash
   set -euo pipefail

   # Clean build & package WAR file
   mvn clean package -DskipTests

   # Verify output artifact exists
   ls -la target/*.war
   ```
7. Click **Save**.


### 2. Declarative Pipeline Job Setup

Create and configure a Jenkins Declarative Pipeline job using a `Jenkinsfile` to define the complete CI/CD workflow as code. This includes stages for source code checkout, build, testing, deployment, and post-build activities.
1. Go to **Jenkins Dashboard → New Item**.
2. Enter Job Name (e.g., `app-ci-pipeline`) and select **Pipeline → Click OK**.
3. Scroll to the **Pipeline** section:
   - **Definition**: Select **Pipeline script from SCM** (Recommended) or **Pipeline script**.
   - If using **Pipeline script**, paste the `Jenkinsfile` logic below.
4. Click **Save**.


>[!TIP]
> **Local Artifact Cleanup:** After the Docker image is built and pushed successfully, the local image can be removed to free up disk space on the Jenkins agent: `docker rmi ${IMAGE_NAME}:${BUILD_NUMBER} || true `

---

## ☸️ Kubernetes Demo App

- Deploy the Nginx demo application to the dev namespace:
  ```sh
  # deploy nginx demo application
  kubectl apply -f kubernetes/deployment.yaml

  # Verify deployment, pods, and service 
  kubectl get deployment nginx-app -n dev
  kubectl get pods -n dev -l app=nginx-app
  kubectl get svc nginx-app -n dev
  ```
- Remove the Nginx demo application and its associated resources:
  ```sh
  # Delete the Nginx demo application
  kubectl delete -f kubernetes/deployment.yaml

  # Verify resources are removed
  kubectl get all -n dev -l app=nginx-app
  ```

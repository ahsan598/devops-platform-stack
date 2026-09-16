## 🔄 Jenkins Job Setup

### Declarative Pipeline Job Setup
Create and configure a Jenkins Declarative Pipeline job using a `Jenkinsfile` to define the complete CI/CD workflow as code. This includes stages for source code checkout, build, testing, deployment, and post-build activities.

1. Go to **Jenkins Dashboard → New Item**.
2. Enter Job Name (e.g., `app-ci-pipeline`) and select **Pipeline → Click OK**.
3. Scroll to the **Pipeline** section:
   - **Definition**: Select **Pipeline script from SCM** (Recommended) or **Pipeline script**.
   - If using **Pipeline script**, paste the `Jenkinsfile` logic below.
4. Click **Save**.


> [!NOTE]
> Jenkins runs in a container with access to the host Docker socket, so this command removes the image from the **host Docker daemon**:
>
> ```sh
> docker rmi ${IMAGE_NAME}:${BUILD_NUMBER} || true
> ```

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

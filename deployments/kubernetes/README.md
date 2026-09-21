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

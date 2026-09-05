
### 🧩 KIND Image Management
```sh
# List kind clusters and nodes
kind get clusters
kind get nodes --name <cluster-name>

# View images inside KIND node (containerd images)
docker exec -it <node-name> crictl images

# Load local Docker image into KIND cluster
kind load docker-image <image-name>:<tag> --name <cluster-name>

# (Optional but Recommended) Verify image inside KIND
docker exec -it <node-name> crictl images | grep <image-name>:<tag>

# Login into KIND node (shell)
docker exec -it <node-name> bash

# List or Remove images (inside KIND)
crictl images
crictl rmi <IMAGE_ID>

# Remove unused images inside KIND
crictl rmi --prune
```

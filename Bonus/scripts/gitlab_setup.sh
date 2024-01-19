
#!/bin/bash

# Step 1: Create GitLab namespace after installing k3d cluster
sudo kubectl create namespace gitlab

# Step 2: Install Helm (https://helm.sh/)
sudo snap install helm --classic

# Step 3: Check and add host entry for GitLab
HOST_ENTRY="127.0.0.1 gitlab.k3d.gitlab.com"
HOSTS_FILE="/etc/hosts"

if grep -q "$HOST_ENTRY" "$HOSTS_FILE"; then
    echo "Host entry already exists in $HOSTS_FILE"
else
    echo "Adding host entry to $HOSTS_FILE"
    echo "$HOST_ENTRY" | sudo tee -a "$HOSTS_FILE"
fi

# Step 4: Add GitLab Helm repository
sudo helm repo add gitlab https://charts.gitlab.io/
sudo helm repo update

# Step 5: Install GitLab using Helm
sudo helm upgrade --install gitlab gitlab/gitlab \
  -n gitlab \
  -f https://gitlab.com/gitlab-org/charts/gitlab/raw/master/examples/values-minikube-minimum.yaml \
  --set global.hosts.domain=k3d.gitlab.com \
  --set global.hosts.externalIP=0.0.0.0 \
  --set global.hosts.https=false \
  --timeout 600s

# Step 6: Wait for the webservice pod to be ready
sudo kubectl wait --for=condition=ready --timeout=1200s pod -l app=webservice -n gitlab

# Step 7: Display GitLab root password in color
echo -n -e "\033[32mGITLAB PASSWORD : \033[0m"
sudo kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath="{.data.password}" | base64 --decode
echo

# Step 8: Check if port forwarding is already running, and recreate if necessary
if [ -n "$(sudo lsof -i :80)" ]; then
    echo "Port forwarding already running, recreating..."
    sudo pkill -f "kubectl port-forward"
fi

# Set up port forwarding for accessing GitLab via ArgoCD
# ArgoCD can be accessed at localhost:80 or http://gitlab.k3d.gitlab.com
sudo kubectl port-forward svc/gitlab-webservice-default -n gitlab 80:8181 2>&1 >/dev/null &


#!/bin/bash

# Step 1: Create Kubernetes namespaces for ArgoCD and development
sudo kubectl create namespace argocd && sudo kubectl create namespace dev

# Step 2: Install ArgoCD (https://argo-cd.readthedocs.io/en/stable/)
sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Step 3: Check and add host entry for ArgoCD
ARGOCD_HOST_ENTRY="127.0.0.1 argocd.mydomain.com"
HOSTS_FILE="/etc/hosts"

if grep -q "$ARGOCD_HOST_ENTRY" "$HOSTS_FILE"; then
    echo "Host entry already exists in $HOSTS_FILE"
else
    echo "Adding host entry to $HOSTS_FILE"
    echo "$ARGOCD_HOST_ENTRY" | sudo tee -a "$HOSTS_FILE"
fi

# Step 4: Wait for all ArgoCD pods to be ready
sudo kubectl wait --for=condition=ready --timeout=600s pod --all -n argocd

# Step 5: Display ArgoCD admin password
echo -n "\033[32mARGOCD PASSWORD : "
sudo kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 --decode
echo

# Step 6: Check if port forwarding is already in progress
if sudo lsof -Pi :8085 -sTCP:LISTEN -t >/dev/null ; then
    echo "Port forwarding already active for ArgoCD. Removing existing port forwarding..."
    # Find and kill the existing port forwarding process
    sudo lsof -t -i:8085 -sTCP:LISTEN | xargs sudo kill -9
    echo "Existing port forwarding removed."
fi

# Set up port forwarding for accessing ArgoCD
# ArgoCD can be accessed at localhost:8085 or argocd.mydomain.com:8085
sudo kubectl port-forward svc/argocd-server -n argocd 8085:443 > /dev/null 2>&1 &
echo "Port forwarding activated for ArgoCD"

# Step 7: Apply deployment configuration
sudo kubectl apply -f ../config/deploy.yaml

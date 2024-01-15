#!/bin/bash

# install git
sudo apt install git

# after installing k3d, create a gitlab namespace
kubectl create namespace gitlab

# install helm - https://helm.sh/
sudo snap install helm --classic

# Check if port 8080 is in use
if sudo lsof -i :8080; then
    # Get the PID of the process using port 8080
    PID=$(sudo lsof -t -i :8080)

    # Kill the process
    echo "Terminating process with PID $PID using port 8080"
    sudo kill -9 $PID

    echo "Process terminated."
fi

# check and add host
HOST_ENTRY="127.0.0.1 gitlab.k3d.gitlab.com"
HOSTS_FILE="/etc/hosts"

if grep -q "$HOST_ENTRY" "$HOSTS_FILE"; then
    echo "Host entry already exists in $HOSTS_FILE"
else
    echo "Adding host entry to $HOSTS_FILE"
    echo "$HOST_ENTRY" | sudo tee -a "$HOSTS_FILE"
fi

sudo helm repo add gitlab https://charts.gitlab.io/
sudo helm repo update 
sudo helm upgrade --install gitlab gitlab/gitlab \
  -n gitlab \
  -f https://gitlab.com/gitlab-org/charts/gitlab/raw/master/examples/values-minikube-minimum.yaml \
  --set global.hosts.domain=k3d.gitlab.com \
  --set global.hosts.externalIP=0.0.0.0 \
  --set global.hosts.https=false \
  --set global.hosts.kubernetesAgent.apiServer="https://0.0.0.0:40495" \
  --timeout 600s

# wait for the GitLab webservice pod to be ready
sudo kubectl wait --for=condition=ready --timeout=1200s pod -l app=webservice -n gitlab

# password to GitLab (user: root)
echo -n "GITLAB PASSWORD: "
sudo kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath="{.data.password}" | base64 --decode
echo

# access GitLab using argocd localhost:80 or http://gitlab.k3d.gitlab.com
sudo kubectl port-forward svc/gitlab-webservice-default -n gitlab 80:8181 2>&1 >/dev/null &

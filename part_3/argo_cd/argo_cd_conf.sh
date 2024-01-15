#!/bin/bash

# Function to get the IP address of the server node
get_server_ip() {
    kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}'
}

# Get the IP address of the server node
SERVER_IP=$(get_server_ip)

# Check if IP address is available
if [ -z "$SERVER_IP" ]; then
    echo "[ERROR] Failed to retrieve the server node IP address."
    exit 1
fi

# Check if the namespace already exists and delete it
if kubectl get namespace argocd >/dev/null 2>&1; then
    echo "[INFO] Deleting existing argocd namespace..."
    kubectl delete namespace argocd
fi

echo "[INFO] Installing ArgoCD in the argocd namespace on server node (ip: $SERVER_IP)"

# Create namespace
kubectl create namespace argocd

# Install ArgoCD in the specified namespace
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml


# install argocd command 
sudo curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
sudo rm argocd-linux-amd64


wait_for_argocd_pods() {
    desired_ready_count=$(kubectl get pods -n argocd --no-headers=true | awk '/Running/ && /1\/1/ {++count} END {print count}')
    total_pods=$(kubectl get pods -n argocd --no-headers=true | wc -l)

    while [[ "$desired_ready_count" -ne "$total_pods" ]]; do
        echo "[INFO][ARGOCD] Waiting for all pods to be ready..."
        sleep 10

        desired_ready_count=$(kubectl get pods -n argocd --no-headers=true | awk '/Running/ && /1\/1/ {++count} END {print count}')
        total_pods=$(kubectl get pods -n argocd --no-headers=true | wc -l)
    done
}

wait_for_argocd_pods
# while [[ $(kubectl get pods -n argocd -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True True True True True True True" ]]; \
#  do echo "[INFO][ARGOCD] Waiting all pods to be ready..." && sleep 10; done

# port forwarding

# Check if port 8080 is already in use
if sudo netstat -tulpn | grep -q :8080; then
    echo "Port 8080 is already in use. Trying to kill the process..."
    
     # Find and kill the process using port 8080
    # sudo lsof -i :8080 -sTCP:LISTEN -t | xargs sudo kill -9
    # kill $(ps | grep -v 'grep' | grep 'kubectl port-forward svc/argocd-server' | cut -d ' ' -f1) 2>/dev/null
    # Find and kill the process using port 8080
    sudo pkill -f 'kubectl port-forward svc/argocd-server'

    
    # Wait for a short duration to allow the process to terminate
    sleep 2
    
    echo "Process killed."
fi


# start port forwarding
echo "Starting port forwarding..."
# Run port-forward in the background and hide the output
kubectl port-forward svc/argocd-server -n argocd 8080:443 &>/dev/null &
sleep 10
echo "Port forwarding started successfully. Below the detail of port forwarding:"
sudo netstat -tulpn | grep :8080

# Check if another port-forwarding process is already in progress
while sudo lsof -i :8080 -sTCP:LISTEN -t | grep -q 'kubectl'; do
    echo "Waiting for existing port-forwarding process to complete..."
    sleep 5
done

# Wait for port-forwarding to be ready
while ! curl -s http://localhost:8080 > /dev/null; do
    echo "Waiting for port-forwarding to be ready..."
    sleep 5
done

# Log in to ArgoCD using admin credentials
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo -e "ARGOCD_PASSWORD: \033[0;32m$ARGOCD_PASSWORD\033[0m"

sleep 2

# Login command
argocd login localhost:8080 --username admin --password "$ARGOCD_PASSWORD" --insecure

# Create ArgoCD application
# argocd app create will --repo 'https://github.com/bl000m/mpagani.git' --path 'app' --dest-namespace 'dev' --dest-server 'https://kubernetes.default.svc' --grpc-web
argocd app create will --project default --repo https://github.com/bl000m/mpagani.git --path app --dest-namespace dev --dest-server https://kubernetes.default.svc --sync-policy automated --sync-option Prune --upsert


# Handle scenarios where the application already exists
if [ $? -eq 20 ]; then
    echo "An error occurred when creating argo-cd app 'will'."
    echo "Probably because the argo-cd app 'will' already exists."
    read -p 'Do you want us to delete and recreate the app? (y/n): ' input
    if [ $input = 'y' ]; then
        echo "We will delete the app for you."
        yes | argocd app delete will --grpc-web &>/dev/null
        echo "Now we will relaunch argo-cd for you."
        kill $(jobs -p)
        exit 0
    fi
    exit 1
fi

# Display information about the created app before sync
argocd app get will --grpc-web

# Set up sync policies for the application
argocd app set will --sync-policy automated --grpc-web
argocd app set will --auto-prune --allow-empty --grpc-web

# Display information about the created app after sync and configuration
# echo "\033[0;36mView created app after sync and configuration\033[0m"
# sleep 1
# echo "making your app healthier..."
# for i in 1 2 3 4 5 6 7 8 9
# do
#     sleep 1
#     echo "and healthier..."
# done


while true; do
    output=$(argocd app get will --grpc-web)

    # Check if both service and deployment are healthy in the output
    if [[ $output == *"Service"*"Healthy"* && $output == *"Deployment"*"Healthy"* ]]; then
        echo "Yes Frank! Both service and deployment are healthy_"
        break 
    else
        echo "Waiting for the app to become healthier..."
        sleep 1
    fi
done

argocd app get will --grpc-web

#!/bin/bash

# Set the namespace
NAMESPACE="argocd"

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
if kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
    echo "[INFO] Deleting existing '$NAMESPACE' namespace..."
    kubectl delete namespace "$NAMESPACE"
fi

echo "[INFO] Installing ArgoCD in the '$NAMESPACE' namespace on server node (ip: $SERVER_IP)"

# Create namespace
kubectl create namespace "$NAMESPACE"

# Install ArgoCD in the specified namespace
kubectl apply -n "$NAMESPACE" -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

while [[ $(kubectl get pods -n "$NAMESPACE" -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True True True True True True True" ]]; \
 do echo "[INFO][ARGOCD] Waiting all pods to be ready..." && sleep 10; done

# Expose ArgoCD server using NodePort
kubectl patch svc argocd-server -n "$NAMESPACE" -p '{"spec": {"type": "NodePort"}}'

# Get NodePort value
NODE_PORT=$(kubectl get svc argocd-server -n "$NAMESPACE" -o jsonpath='{.spec.ports[0].nodePort}')

echo -n "[INFO] ArgoCD admin password: "
kubectl -n "$NAMESPACE" get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

echo "[INFO] Access ArgoCD at http://$SERVER_IP:$NODE_PORT"

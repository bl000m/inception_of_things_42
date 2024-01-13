#!/bin/bash

# Variables
CLUSTER_NAME="frank-cluster"
ARGOCD_NAMESPACE="argocd"
DEV_NAMESPACE="dev"

# Function to wait for cluster nodes to be ready
wait_for_nodes() {
    echo "Waiting for cluster nodes to be ready..."
    kubectl wait node --for=condition=Ready --all --timeout=300s
}

# Create K3d cluster
echo "Creating K3d cluster: $CLUSTER_NAME"
k3d cluster create $CLUSTER_NAME

# Set KUBECONFIG to use the created cluster
export KUBECONFIG="$(k3d kubeconfig write $CLUSTER_NAME)"

# Wait for cluster nodes to be ready
wait_for_nodes

# Create development namespace
echo "Creating development namespace: $DEV_NAMESPACE"
kubectl create namespace $DEV_NAMESPACE


echo "Hey Frank, your Cluster setup is completed!"

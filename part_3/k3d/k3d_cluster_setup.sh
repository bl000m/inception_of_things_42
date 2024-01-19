#!/bin/bash

# Check if the Frank cluster already exists
if k3d cluster get frank > /dev/null 2>&1; then
    echo "Frank cluster already exists. Skipping creation."
else
    # Create Frank cluster
    sudo k3d cluster create frank
    mkdir -p ~/.kube
    sudo k3d kubeconfig get frank > ~/.kube/config

    sleep 60s
    sudo kubectl -n kube-system delete pods --all --force
    sudo kubectl -n kube-system wait --for=condition=Ready --timeout=5m pods --all
    clear
    sudo kubectl get pods -A
    sleep 3s

    sudo kubectl create namespace dev
    sudo kubectl create namespace argocd
    clear
    sudo kubectl get namespaces
    sleep 3s

    echo "Hey Frank, your Cluster setup is completed!"
fi

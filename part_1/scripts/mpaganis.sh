#!/bin/bash

echo "[YES WE ARE DOING IT FRANK !] Installing k3s on server node. Ip: $1"

export INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --tls-san $(hostname) --node-ip $1  --bind-address=$1 --advertise-address=$1 "

# Install curl if not present
if ! command -v curl &> /dev/null; then
    echo "[INFO] Installing curl"
    apk add curl
fi

curl -sfL https://get.k3s.io | sh -

echo "[YES WE ARE DOING IT FRANK !] Waiting for k3s to be ready"

# Check if k3s server is ready before proceeding
until kubectl get nodes &> /dev/null; do
    sleep 2
done

echo "[YES WE ARE DOING IT FRANK !] Successfully installed k3s on server node"

echo "alias k='kubectl'" >> /etc/profile.d/00-aliases.sh
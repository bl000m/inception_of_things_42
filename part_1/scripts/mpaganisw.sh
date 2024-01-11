#!/bin/bash

NAME="mpaganiSW"
TOKEN_FILE="/vagrant/scripts/node-token"
INSTALL_K3S_EXEC="agent --server https://$1:6443 --token-file $TOKEN_FILE --node-ip=$2"

echo "[YES WE ARE DOING IT FRANK !] Installing k3s agent on worker node. IP: $1"
echo "[YES WE ARE DOING IT FRANK !] Token: $(cat $TOKEN_FILE)"
echo "[YES WE ARE DOING IT FRANK !] ARGUMENT PASSED TO INSTALL_K3S_EXEC: $INSTALL_K3S_EXEC"

# Install curl if not present
if ! command -v curl &> /dev/null; then
    echo "[INFO] Installing curl"
    apk add curl
fi

# Download and install k3s
curl -sfL https://get.k3s.io | sh -

echo "[YES WE ARE DOING IT FRANK !] Waiting for k3s to be ready"

# Check if k3s server is ready before proceeding
until kubectl get nodes &> /dev/null; do
    sleep 2
done

# Add kubectl alias
echo "alias k='kubectl'" >> /etc/profile.d/00-aliases.sh

echo "[YES WE ARE DOING IT FRANK !] Successfully installed k3s agent on worker node"


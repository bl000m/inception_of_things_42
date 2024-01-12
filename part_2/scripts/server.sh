#!/bin/bash

export NAME="mpaganiS"
export INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --tls-san $(hostname) --node-ip $1  --bind-address=$1 --advertise-address=$1 "

if ! command -v curl &> /dev/null; then
   apk add curl
fi

curl -sfL https://get.k3s.io |  sh -

# Wait for K3s to be ready
while ! rc-service k3s status &>/dev/null; do
  sleep 2
done

# Wait for the node-token file to be created
while [[ ! -f /var/lib/rancher/k3s/server/node-token ]]; do
 sleep 2
done

sudo cp /var/lib/rancher/k3s/server/node-token /vagrant/scripts/

echo "[WE DID IT FRANK !]  Successfully installed k3s on server node"

echo "alias frank='kubectl'" >> /etc/profile.d/00-aliases.sh
echo "alias franknodes='kubectl get nodes'" >> /etc/profile.d/00-aliases.sh
echo "alias frankpods='kubectl get pods'" >> /etc/profile.d/00-aliases.sh
echo "alias frankallpods='kubectl get pods --all-namespaces'" >> /etc/profile.d/00-aliases.sh

kubectl apply -f "/vagrant/manifests/manifest.yml"
sleep 2
kubectl apply -f "/vagrant/manifests/app1.yml"
sleep 2
kubectl apply -f "/vagrant/manifests/app2.yml"
sleep 2
kubectl apply -f "/vagrant/manifests/app3.yml"
sleep 2
kubectl apply -f "/vagrant/manifests/ingress.yml"



curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# remove all clusters if already there
clusters=$(k3d list -o name)

# Iterate through each cluster and delete it
for cluster in $clusters; do
    k3d delete $cluster
done

# create our Frank cluster
sudo k3d cluster create frank
mkdir ~/.kube &>/dev/null
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

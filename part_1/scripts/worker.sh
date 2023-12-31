#!/bin/bash

# Wait until the token file is available
while [ ! -f /vagrant/token.env ]; do
 echo -n "."
 sleep 1
done

# Set the environment variables for the K3s installation
# https://docs.k3s.io/installation/configuration#configuration-file
export K3S_URL="https://192.168.56.110:6443"
export K3S_TOKEN=$(cat /vagrant/token.env)

# Install kubectl
sudo apt-get update && sudo snap install kubectl --classic

# Install worker node
curl -sfL https://get.k3s.io | sh -

# Label the worker node as a worker
# kubectl label nodes $(hostname) node-role.kubernetes.io/worker=

# Create a virtual network interface named eth1
# Assign the IP address 192.168.56.110 with a subnet mask of /24 to eth1
# Activate the eth1 interface
sudo ip link add eth1 type dummy && sudo ip addr add 192.168.56.110/24 dev eth1 && sudo ip link set eth1 up

sudo rm /vagrant/token.env
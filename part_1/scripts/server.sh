#!/bin/bash

# Install master node
# https://docs.k3s.io/quick-start

INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --tls-san serverS --node-ip 192.168.56.110 --bind-address=192.168.56.110 --advertise-address=192.168.56.110 "

# Install kubectl
sudo apt-get update && sudo snap install kubectl --classic


curl -sfL https://get.k3s.io | sh -;

sudo cat /var/lib/rancher/k3s/server/token >> /vagrant/token.env

# Create a virtual network interface named eth1
# Assign the IP address 192.168.56.110 with a subnet mask of /24 to eth1
# Activate the eth1 interface
sudo ip link add eth1 type dummy && sudo ip addr add 192.168.56.110/24 dev eth1 && sudo ip link set eth1 up
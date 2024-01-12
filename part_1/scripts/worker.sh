#!/bin/bash

export NAME="mpaganiSW"

export TOKEN_FILE="/vagrant/scripts/node-token"
export NEW_TOKEN_FILE="/etc/rancher/k3s/node-token"

# Create the new token file and write the token from the old file to it
sudo mkdir -p /etc/rancher/k3s && sudo sh -c "echo $(cat $TOKEN_FILE) > $NEW_TOKEN_FILE"

export INSTALL_K3S_EXEC="agent --server https://$1:6443 --token-file $NEW_TOKEN_FILE --node-ip=$2"

if ! command -v curl &> /dev/null; then
  apk add curl
fi

curl -sfL https://get.k3s.io | sh -

echo "alias k='kubectl'" >> /etc/profile.d/00-aliases.sh

#!/bin/bash

# Get GitLab password
GITLAB_PASS=$(sudo kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath="{.data.password}" | base64 --decode)

# Create .netrc file with GitLab credentials
echo "machine gitlab.k3d.gitlab.com
login root
password ${GITLAB_PASS}" | sudo tee /root/.netrc > /dev/null

sudo chmod 600 /root/.netrc

# Clone repositories
sudo git clone http://gitlab.k3d.gitlab.com/root/mpagani.git gitlab_mpagani
sudo git clone https://github.com/bl000m/mpagani.git github_mpagani

# Move app directory from github_mpagani to gitlab_mpagani
sudo mv github_mpagani/app gitlab_mpagani/

# Remove github_mpagani repository
sudo rm -rf github_mpagani/

# Change directory to gitlab_mpagani
cd gitlab_mpagani

# Commit and push changes to GitLab
sudo git add *
sudo git commit -m "update"
sudo git push

# Move back to the parent directory
cd ..

# sudo kubectl apply -f ../config/deploy.yaml

# Display port forwarding warning
echo "PORT-FORWARD : sudo kubectl port-forward svc/svc-wil -n dev 8888:8080"

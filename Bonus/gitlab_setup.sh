# install helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | sudo bash
sudo helm version

export DOMAIN="gitlab.local"
export KUBECONFIG=~/.kube/config

# Check if entry already exists in /etc/hosts
if ! grep -q "0.0.0.0 gitlab.local" /etc/hosts; then
    # Add entry to /etc/hosts
    sudo bash -c 'echo "0.0.0.0 gitlab.local" >> /etc/hosts'
fi

sudo kubectl create namespace gitlab

helm repo add gitlab https://charts.gitlab.io/
helm repo update

helm install gitlab gitlab/gitlab -n gitlab \
    --set global.edition=ce \
    --set global.hosts.domain=$DOMAIN \
    --set global.hosts.https="false" \
    --set global.ingress.configureCertmanager="false" \
    --set certmanager-issuer.email=$EMAIL \
    --set gitlab-runner.install="false" 

sudo kubectl wait -n gitlab --for=condition=available deployment --all --timeout=5m

# Retrieve GitLab root password
GITLAB_PASSWORD=$(sudo kubectl get secret -n gitlab gitlab-gitlab-initial-root-password -o jsonpath='{.data.password}' | base64 -d)

echo -e "GITLAB_PASSWORD: \033[0;32m$GITLAB_PASSWORD\033[0m"

cat <<EOF | sudo kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: gitlab-svc
  namespace: gitlab
spec:
  type: LoadBalancer
  selector:
    app.kubernetes.io/name: gitlab-webservice-default
  ports:
  - port: 8085
    protocol: TCP
    targetPort: 8085
EOF

sudo kubectl port-forward --address 0.0.0.0 svc/gitlab-webservice-default -n gitlab 8086:8181 &

# Generate SSH key if not exists
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -C "mathiapagani@gmail.com" -f ~/.ssh/id_rsa
    chmod 600 ~/.ssh/id_rsa
fi

# Add SSH key to SSH agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

# Configure Git to use SSH
git config --global core.sshCommand "ssh -i ~/.ssh/id_rsa -F /dev/null"

# Wait for the port-forwarding process to complete before attempting to clone
wait

# Clone the GitLab repository using SSH with the correct port
git clone git@gitlab.local:8086:root/mpagani.git
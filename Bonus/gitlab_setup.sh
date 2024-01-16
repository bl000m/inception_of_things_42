# install helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | sudo bash
sudo helm version

export EMAIL="mathiapagani@gmail.com"
export DOMAIN="gitlab.local"
export KUBECONFIG=~/.kube/config

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

sudo kubectl port-forward --address 0.0.0.0 svc/gitlab-webservice-default -n gitlab 8085:8181 

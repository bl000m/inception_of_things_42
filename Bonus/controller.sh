# Update package information
sudo apt-get update

# Upgrade installed packages
sudo apt-get upgrade -y

# Install essential packages
sudo apt-get install -y \
    ufw \
    net-tools \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    apt-transport-https \
    vim \
    jq

# Configure and enable firewall
sudo ufw enable
sudo ufw default allow incoming
sudo ufw default allow outgoing

# Display current iptables rules
sudo iptables -L

bash ./k3d_cluster_setup.sh
bash ./gitlab_setup.sh
bash ./argo_cd_conf.sh
bash ./launching.sh
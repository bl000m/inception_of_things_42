# Kubernetes architecture
![image](https://github.com/bl000m/inception_of_things_42/assets/84441663/694be788-79fc-42c3-acce-2a0ffced91de)

## Cluster:
A cluster contains nodes (machines and environments physical or virtual)

## Master Node:
The master node has 4 processes installed:
- api server: cluster gateway (client - server) and act as gatekeeper for authentication
[ Request -> api server on master node (validates request) -> processes like schedule -> pods]
- scheduler (distributes pods)
- controller manager
- etcd (Key value store) cluster brain. Knows available resources, cluster status...

## Worker Node:
A worker node is managed by a server node

A worker node has 3 processes installed:
- container runtime (docker)
- scheduler (kubelet: node/container runtime interface)
- kube proxy

## Communication
Nodes communicate via Services (like a loadballancer that catches requests and redirects between pods).

## Pods:
A node contains pods that run

A pod can be one or several containers (App, DataBase)

All containers in a pod have the same IP and network port

<br><br>
---
<br><br>
# The project
## Part 1: K3s and Vagrant
- Set up 2 virtual machines using Vagrant, with specific resource constraints.
- Assign dedicated IPs to each machine.
- Configure SSH access without a password.
- Install K3s on both machines, with the first one in controller mode and the second one in agent mode.
## Part 2: K3s and Three Simple Applications
- Set up a virtual machine with the latest stable distribution and K3s in server mode.
- Deploy three web applications using K3s.
- Configure Ingress to route traffic based on the HOST parameter, displaying different apps.
- Include replicas for the second application.
## Part 3: K3d and Argo CD
- Install K3D on the virtual machine.
- Create two namespaces: one for Argo CD and another named 'dev'.
- Deploy an application in the 'dev' namespace, automatically deployed by Argo CD from a public GitHub repository.
- The application must have two versions, and changes in the GitHub repository should trigger updates.
## Bonus Part: Gitlab Integration
- Integrate Gitlab into the infrastructure created in Part 3.
- Install the latest version of Gitlab locally.
- Configure Gitlab to work with the Kubernetes cluster.
- Create a namespace named 'gitlab'.
- Ensure that all aspects of Part 3 work with the local Gitlab instance.
<br><br>
---
<br><br>
# Key Concepts in Kubernetes

- **Node**: In Kubernetes, a Node is essentially a worker machine in a cluster. It could be either a virtual or a physical machine, depending on the environment. Each node is managed by the master components and runs containerized applications. The node could be a part of a multi-node cluster where the master components are distributed across multiple nodes for high availability.

**=> NB: a node can contain multiple namespaces, each containing multiple pods**

- **Pod**: A Pod is the smallest and simplest unit in the Kubernetes object model. It represents a single instance of a running process in a cluster and can contain one or more containers. These containers within a pod share storage and network resources, and can communicate with each other using localhost. Pods can be scheduled on any node in the cluster, and they are ephemeral and can be terminated and replaced.

- **Namespace**: Namespace is a way to divide cluster resources between multiple users or teams. It provides a scope for names and can be used to group together objects that are logically associated. Namespaces are a fundamental aspect of Kubernetes and can be used to manage, partition, and isolate resources in a large cluster.
<br><br>
---  
<br><br>
# PART 1: Setting Up the Project

## Create a Virtual Machine
- save it in `/sgoinfre/goinfre/Perso/yourname` to avoid exceeding the size limit
- Allocate 4 cores.
- In **settings > system**, check the "Allow Nested VM" option.

## Within the Virtual Machine
- Install VirtualBox within the virtual machine => nested VirtualBox installation.
- Install Vagrant.

## To work on the project and test
- Clone the GitHub Repository
- Navigate to the `part_1` directory.
- be sure that scripts in `/scripts` dir have right permissions, otherwise `chmod +x` the two of them
- K3s requires swap to be disabled, as it can interfere with the functioning of containers. We need to disable swap on Ubuntu with the command `sudo swapoff -a` (to bring it on back again for testing: `sudo swapon --all`).
- Run the following command to start the VMs: `vagrant up`

## Test
- Once the VMs are created, you can test the connection with the following command (replace ip address):
  - `ping ip_address_server`
- You can access the VMs with the following command: 
  - `vagrant ssh vm_name`

## Cluster
- we have installed kubectl in both the scripts to list nodes and test cluster on server machine (mpaganiS). Now we need to list nodes to check everything is good: 

- `kubectl get nodes` (or the alias `frankpods`) => to list all nodes in the cluster

**Note**: The `/vagrant` directory within the VM is shared with the host and if you give a look to the scripts in the Vagrantfile we use the share dir to extract the token from the server node and retrieve it from the worker node.

## Useful Vagrant cmds
- `vagrant up`: Starts and provisions the Vagrant environment.
- `vagrant global-status`: Displays the status of all Vagrant environments on the machine.
- `vagrant destroy`: Stops and deletes the running Vagrant environment.
- `vagrant reload`: Restarts the Vagrant environment, applying any configuration changes.
- `vagrant ssh`: SSH into the running Vagrant machine.
- `vagrant halt`: Stops the Vagrant environment without destroying it.
- `vagrant suspend`: Suspends the Vagrant environment, saving its current state.
- `vagrant resume`: Resumes a previously suspended Vagrant environment.

## Useful Kubectl cmds
- `kubectl get nodes` -> to list the nodes in the cluster (alias `franknodes`)
- `kubectl get pods` -> to list the pods in the current namespace (alias `frankpods`)
- `kubectl get pods -A` (or `kubectl get pods --all-namespaces`) -> to list the pods in all the namespaces (alias: `frankallpods`)
- `kubectl get all` -> list all (pods, services, deployment, replicas)

**NB**: when executing `kubectl get pods -A` after having created the kubernetes cluster, we can see all the system pods created by default. 
**Why ? Here is the answer**:
- When you create a Kubernetes cluster, certain system components are automatically deployed to facilitate the operation of the cluster. These components are known as system pods. They are responsible for various functions such as DNS resolution (`coredns`), storage provisioning (`local-path-provisioner`), and monitoring (`metrics-server`) among others. These system pods are created in the `kube-system`` namespace by default.

- The `helm-install-traefik-crd-pndrc` and `helm-install-traefik-7xbqm` pods are part of `Helm`, a package manager for Kubernetes. Helm charts are packages of pre-configured Kubernetes resources. When you install a Helm chart, Helm uses a temporary job to create, update, or delete resources.

## Troubleshooting
- to check status cluster agent within the worker node: `systemctl status k3s-agent`
- to check k3s agent logs within the nodes: `cat /var/logs/k3s-agent.logs`
- to check if a node can reach another one (for example the worker and server): `ping server_ip`

<br><br>
---  
<br><br>
# Part 2: deploying 3 services in the cluster
 
## Manifest items:

- In this Kubernetes manifest we define 3 services (app1, app2, app3) of type BodePort
Each service exposes port 80 on the host and directs traffic to port 8080 on the selected pods with corresponding labels (app-1, app-2, and app-3).


- apiVersion: Specifies the API version of the Kubernetes resource. In our case, it's v1, which is the core/v1 API version.

- kind: Indicates the type of Kubernetes resource. Here, it's a Service, which represents a service that exposes applications within a cluster.

- metadata: Contains information about the resource, such as its name, labels, and annotations.

- NB: it's common to use the service name as a label for the selector, so not needed to specify the label in metadata
- spec: Describes the desired state of the service.
- selector: Specifies the labels that identify the set of pods targeted by the service. In our case, the service selects pods with the label app: app1 (or app2 or aoo_3).

- ports: Specifies the ports on which the service will listen for incoming traffic and how that traffic will be forwarded to the pods.

    - protocol: Specifies the protocol used for the service. We use TCP (good practice to specify it even if kubernetes by default use TCP). Other options include UDP.

    - port: The port on which the service will listen for incoming traffic. For us 80

    - targetPort: The port to which the traffic will be forwarded inside the pods. For us 8080.

- type: Specifies the type of service.  NodePort exposes the service on a port on each node in the cluster. Other options include ClusterIP (default), LoadBalancer, and ExternalName.

## Going deep into why having external (usually 80) and internal port (usually 8080)
- **Separation of Concerns**: The external-facing service (exposed on port 80) is responsible for interacting with external clients or users. It may handle tasks such as load balancing, SSL termination, and authentication. The internal port (e.g., 8080) is where the actual application or service logic is running. This separation allows you to modify or upgrade the internal implementation without affecting the external interface.

- **Containerization** and Orchestration: In containerized environments like Kubernetes, applications are often deployed in containers. Each container may expose its services on specific ports internally. By using a consistent internal port (e.g., 8080), it becomes easier to manage and orchestrate containerized applications.

- **Conventions and Consistency**: Standardizing the internal port across different services or applications simplifies configuration and management. It makes it easier to reason about the internal workings of applications and allows for consistent configurations across multiple services.

- **Avoiding Port Conflicts**: If you have multiple services running on the same host, each with its own internal port (e.g., 8080), it helps avoid port conflicts. The external service on port 80 can act as a gateway, forwarding traffic to the appropriate internal service based on the requested path or domain.

- **Security Considerations**: The internal port (8080) might be chosen based on the application's default port or security policies. It's a common practice to run applications inside containers with non-privileged users, and ports below 1024 are typically reserved for privileged processes. By defaulting to a higher port for the internal application, you avoid potential conflicts and security concerns.

## Ingress
- Important: Add entries in `/etc/hosts` within BOTH the server node (this is done by the server.sh script) and the host (this has to be done manually) for the hostnames specified in Ingress manifest, mapping them to the IP address of Kubernetes cluster node => mandatory the mapping btw the 2 /etc/hosts (host and server node) 

192.168.56.110 app1.com
192.168.56.110 app2.com
192.168.56.110 app3.com

## Testing
- `kubectl get all` to list all pods, services and replicas
- `curl -H "Host:app2.com" 192.168.56.110` to check that app2 (or 1 or 3) is well reacheble

## Debugging
- `kubectl logs -n kube-system traefik-f4564c4f4-msskz` Traefik Ingress Controller is in kubesystem namespace (check with `get pods -A` and replace the name) 
- `kubectl describe ingress ingress` => Check the status of your Ingress resource
- check services endpoint: `kubectl describe services app1 app2 app3`
- access the Ingress controller pods: `kubectl exec -it -n kube-system traefik-f4564c4f4-d7cfm -- sh`
<br><br>
---  
<br><br>

# Part 3

## Conf on the host (the nested VM) via script /kick_off
- install Docker : https://docs.docker.com/engine/install/ubuntu/ 
- install K3D: `wget -q -O - https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash`
- install kubectl:  `sudo snap install kubectl --classic`

# Argo CD setup
If NodePort Service:
- Exposing ArgoCD Server: We should expose the ArgoCD server using a service of type NodePort. This means that the ArgoCD server is made accessible on a specific port on all the nodes within the Kubernetes cluster.

- NodePort Service Type: A NodePort service type makes a service accessible externally by mapping a port on each node to the internal service port. For example, if the internal service port for ArgoCD is 443, and the NodePort assigned is 32000, then accessing any node's IP address on port 32000 will forward the request to the ArgoCD server.

- No Port Forwarding Within the Cluster: Because the ArgoCD server is exposed using NodePort, there is no need for additional port forwarding within the cluster. Any node within the cluster can reach the ArgoCD server using the assigned NodePort.

If Port forwarding: 
- Local Development: During local development,  interact with services running inside the Kubernetes cluster from their local machine. Port forwarding allowsto create a connection between local machine and a specific port on a pod within the cluster.

- Accessing Services Remotely: If the Kubernetes cluster is running on a cloud provider or on a remote server, and direct external access to a specific service is required, port forwarding can be used to create a secure connection.

## Testing
Execute the script in this order:
- `setting/install_dependencies.sh`
- `k3d/k3d_cluster_setup`
- `argo_cd_conf.sh`
=> the logs will tell us which password to use on localhost:8080 to access Argo CD as `admin``
Useful commands to check:
- `docker ps`
- `k3d node list`
- `k3d cluster get frank-cluster`
- `k3d cluster list`
- `kubectl cluster-info`
- `argocd app list dev`
- `kubectl get svc argocd-server -n argocd`
- `kubectl get namespaces`
What to test:
- list the pod running in dev namespace: `kubectl get pods -n dev`
- we should see the only pod running corresponding to the Wil app installed, copy its pod name
- use the pod name to execute the command detailing the pod: `kubectl describe pod <pod_name> -n dev`
- under Containers we should see something like:
```
  will:
    Container ID:   containerd://6fea2b6647200fe3f63c9f982c05254029cd1ecc2093ba5abb4801df96b15d46
    Image:          **wil42/playground:v1**
    Image ID:       docker.io/wil42/playground@sha256:0f8be6f0f51fa7129719392fcf464170c432b2bdb539b5b7fd2db9b42f7b7f91
    Port:           8888/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Mon, 15 Jan 2024 15:35:31 +0100
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-ppntn (ro)

```
in the Image we have **v1**
- update deployment.yaml in mpagani repo changing v1 to v2, commit and push
- it takes some minute for the system to delete the pod corresponding to v1 and replace it with the pod corresponding to v2
- to check it, port forward again: `kubectl port-forward svc/will-app-service -n dev 8888:8888` and then this command : `curl http://localhost:8888`
- this way we can access localhost:8888 on browser. When the switch of version has been done we should see `{"status":"ok", "message": "v2"}`
- iw we rerun `kubectl get pods -n dev` and `kubectl describe pod <pod_name> -n dev` right after we should see now see **v2** in the Image section

## troubleshooting
- `k3d cluster delete frank-cluster`
- `kubectl delete namespace dev`

# Bonus
- we create an independent instance of GitLab that runs within our cluster. 
This is separate from the GitLab service hosted at gitlab.com.

- The GitLab instance deployed in our cluster is a self-hosted version
- we have this way full control over the environment, configurations, and data. 

- our self-hosted instance  and the GitLab service at gitlab.com are distinct, and they don't share the same data or user accounts. Users and projects created in one instance won't be automatically accessible in the other.

## Steps involved in deploying GitLab into a Kubernetes cluster
- Installation of GitLab Helm Chart: Helm is a package manager for Kubernetes applications. we use the GitLab Helm chart to define and install the necessary components for GitLab. The Helm chart provides a set of predefined configurations and resources needed to run GitLab in a Kubernetes environment.
- These settings include the domain, external IP, whether to use HTTPS, and a timeout duration for the deployment.
- Port forwarding: set up port forwarding to allow access to GitLab. by forwarding traffic from the local machine's port 80 to the GitLab service in the Kubernetes cluster.

## For testing
- run in this order: 
 - /scripts/gitlab_setup.sh => it takes around 10 min
 - navigate to gitlab.k3d.gitlab.com. log in with user = root and psw = the one console logged in the shell (green)
 - create the project "mpagani", public. the name is important
 - run /scripts/repo_config.sh and verify that on gitlab the app dir with manifests has been copied from github repo
 - run /scripts/argo_cd_conf.sh and check on localhost port 8085 if app is created and healthy
 - update gitlab manifest image version and push. wait a few minutes and check  as in part 3

# Setting Up the Project for Part_1

## Create a Virtual Machine
- save it in /sgoinfre/goinfre/Perso/yourname to avoid exceeding the size limit
- Allocate 4 cores.
- In the settings/system, check the "Allow Nested VM" option.

## Within the Virtual Machine
- Install VirtualBox within the virtual machine. This is a nested VirtualBox installation.
- Install Vagrant.
- Install kubectl.

## To work on the project and test
- Clone the GitHub Repository
- Navigate to the Part_1 directory.
- be sure that scripts in /scrips dir have right permissions, otherwise `chmod +x` the two of them
- K3s requires swap to be disabled, as it can interfere with the functioning of containers. We need to disable swap on Ubuntu with the command `sudo swapoff -a` (to bring it on back again for testing: `sudo swapon --all`).
- Run the following command to start the VMs: `vagrant up`

## TEST 
- Once the VMs are created, you can test the connection with the following command (replace ip address):
  - `ping ip_address_server`
- You can access the VMs with the following command: 
  - `vagrant ssh vm_name`

## CLUSTER
- we have installed kubectl in both the scripts to list nodes and test cluster on server machine (mpaganiS). Now we need to list nodes to check everything is good: 

- `kubectl get nodes` => to list all nodes in the cluster


Note: The `/vagrant` directory within the VM is shared with the host and if you give a look to the scripts in the Vagrantfile we use the share dir to extract the token from the server node and retrieve it from the worker node.

## useful Vagrant cmds
- vagrant up: Starts and provisions the Vagrant environment.
- vagrant global-status: Displays the status of all Vagrant environments on the machine.
- vagrant destroy: Stops and deletes the running Vagrant environment.
- vagrant reload: Restarts the Vagrant environment, applying any configuration changes.
- vagrant ssh: SSH into the running Vagrant machine.
- vagrant halt: Stops the Vagrant environment without destroying it.
- vagrant suspend: Suspends the Vagrant environment, saving its current state.
- vagrant resume: Resumes a previously suspended Vagrant environment.

## Troubleshooting
- to check status cluster agent within the worker node: `systemctl status k3s-agent`

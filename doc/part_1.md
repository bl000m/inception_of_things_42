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
- Run the following command to start the VMs: `vagrant up`

## Once the VMs are created, you can test the connection with the following command (replace ip address):
`ping ip_address_server`
You can access the VMs with the following command: 
`vagrant ssh vm_name`

Note: The `/vagrant` directory within the VM is shared with the host and if you give a look to the scripts in the Vagrantfile we use the share dir to extract the token from the server node and retrieve it from the worker node.

# on Mac (M1 chip)
## Install Homebrew (if you haven't already)
- `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"``
## Install Rosetta 2 (to run Intel-based packages on M1 Mac)
- `softwareupdate --install-rosetta`
## Install QEMU (QEMU is a generic and open-source machine emulator and virtualizer.QEMU is used by Vagrant to run Docker containers as virtual machines)
- `brew install qemu`
## Install Vagrant
- `brew tap hashicorp/tap
brew install hashicorp/tap/hashicorp-vagrant`

## Vagrantfile


## Launch VMs:
- run docker desktop daemon
- Run the following command to start the VMs: `vagrant up`
- Access the VMs using SSH:
```
vagrant ssh Server
vagrant ssh ServerWorker
``````

# Part 1: K3s and Vagrant
- Set up 2 virtual machines using Vagrant, with specific resource constraints.
- Assign dedicated IPs to each machine.
- Configure SSH access without a password.
- Install K3s on both machines, with the first one in controller mode and the second one in agent mode.
# Part 2: K3s and Three Simple Applications
- Set up a virtual machine with the latest stable distribution and K3s in server mode.
- Deploy three web applications using K3s.
- Configure Ingress to route traffic based on the HOST parameter, displaying different apps.
- Include replicas for the second application.
# Part 3: K3d and Argo CD
- Install K3D on the virtual machine.
- Create two namespaces: one for Argo CD and another named 'dev'.
- Deploy an application in the 'dev' namespace, automatically deployed by Argo CD from a public GitHub repository.
- The application must have two versions, and changes in the GitHub repository should trigger updates.
# Bonus Part: Gitlab Integration
- Integrate Gitlab into the infrastructure created in Part 3.
- Install the latest version of Gitlab locally.
- Configure Gitlab to work with the Kubernetes cluster.
- Create a namespace named 'gitlab'.
- Ensure that all aspects of Part 3 work with the local Gitlab instance.

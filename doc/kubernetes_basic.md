# Key Concepts in Kubernetes

- Node: In Kubernetes, a Node is essentially a worker machine in a cluster. It could be either a virtual or a physical machine, depending on the environment. Each node is managed by the master components and runs containerized applications. The node could be a part of a multi-node cluster where the master components are distributed across multiple nodes for high availability.

NB: a node can contain multiple namespaces, each containing multiple pods

- Pod: A Pod is the smallest and simplest unit in the Kubernetes object model. It represents a single instance of a running process in a cluster and can contain one or more containers. These containers within a pod share storage and network resources, and can communicate with each other using localhost. Pods can be scheduled on any node in the cluster, and they are ephemeral and can be terminated and replaced.

- Namespace: Namespace is a way to divide cluster resources between multiple users or teams. It provides a scope for names and can be used to group together objects that are logically associated. Namespaces are a fundamental aspect of Kubernetes and can be used to manage, partition, and isolate resources in a large cluster.
# Part 2
 
## Manifest items:

- apiVersion: Specifies the API version of the Kubernetes resource. In our case, it's v1, which is the core/v1 API version.

- kind: Indicates the type of Kubernetes resource. Here, it's a Service, which represents a service that exposes applications within a cluster.

- metadata: Contains information about the resource, such as its name, labels, and annotations.

- NB: it's common to use the service name as a label for the selector, so not needed to specify the label in metadata
- spec: Describes the desired state of the service.
- selector: Specifies the labels that identify the set of pods targeted by the service. In our case, the service selects pods with the label app: app_1 (or app_2 or aoo_3).

- ports: Specifies the ports on which the service will listen for incoming traffic and how that traffic will be forwarded to the pods.

    - protocol: Specifies the protocol used for the service. We use TCP (good practice to specify it even if kubernetes by default use TCP). Other options include UDP.

    - port: The port on which the service will listen for incoming traffic. For us 80

    - targetPort: The port to which the traffic will be forwarded inside the pods. For us 8080.

- type: Specifies the type of service.  NodePort exposes the service on a port on each node in the cluster. Other options include ClusterIP (default), LoadBalancer, and ExternalName.

# Part 2
 
## Manifest items:

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
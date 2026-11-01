# Azure Kubernetes Identity and RBAC Architecture

## Architecture Diagram

```mermaid
flowchart TB
    TF["Terraform Configuration"]
    AZ["Azure Resource Manager"]
    ENTRA["Microsoft Entra ID"]
    USER["Personal User Account"]
    SP["Application and Service Principal"]
    LOGIN["kubelogin + kubectl"]
    AKS["Azure Kubernetes Service"]
    API["Kubernetes API Server"]
    NS["lab Namespace"]
    POD["NGINX Deployment and Pod"]
    SVC["ClusterIP Service"]
    KUBELET["AKS Kubelet Managed Identity"]
    ACR["Private Azure Container Registry"]

    TF -->|"Provision infrastructure and RBAC"| AZ
    AZ --> AKS
    AZ --> ACR
    AZ --> SP

    USER -->|"Authenticate"| ENTRA
    SP -->|"Authenticate"| ENTRA
    ENTRA -->|"Issue tokens"| LOGIN
    LOGIN -->|"Authenticated API requests"| API

    AKS --> API
    API -->|"Azure RBAC authorizes actions"| NS
    NS --> POD
    NS --> SVC
    SVC -->|"Routes internal traffic"| POD

    AKS --> KUBELET
    KUBELET -->|"AcrPull permission"| ACR
    ACR -->|"Private container image"| POD
```

## Authentication and Authorization

Microsoft Entra ID authenticates the personal user account and the application service principal. The kubelogin tool supports obtaining an Entra token for Kubernetes access.

Azure RBAC determines whether an authenticated identity can perform actions against the AKS Kubernetes API.

The deployment service principal receives:
- Azure Kubernetes Service Cluster User Role at AKS cluster scope.
- Azure Kubernetes Service RBAC Reader at cluster scope.
- Azure Kubernetes Service RBAC Writer scoped to the lab namespace.

The AKS kubelet managed identity receives AcrPull at the Azure Container Registry scope. This allows nodes to retrieve private container images without using registry administrator credentials.

## Least Privilege

The service principal does not receive Owner or Cluster Admin permissions. Write permissions are restricted to the lab namespace.

The kubelet identity has registry pull permission, not registry push or administrator access.

## Validation Status

Terraform initialization and validation succeeded locally.

The Kubernetes manifests passed offline YAML syntax checks.

Azure deployment, token-based authentication, image pulling, and RBAC authorization have not been tested because no Azure subscription is currently accessible.
# Architecture and trust flows

```mermaid
flowchart TB
  U[Personal Entra user] -->|Interactive authentication| A[Azure control plane]
  SP[Entra application and service principal] -->|Entra token + AKS user role| API[AKS Kubernetes API]
  A -->|Azure RBAC management| AKS[AKS cluster]
  API -->|AKS Azure RBAC reader / namespace writer| APP[lab namespace: Deployment + Service + Pod]
  K[AKS kubelet managed identity] -->|AcrPull scoped to registry| ACR[Private Azure Container Registry]
  ACR -->|Container image| APP
  TF[Terraform] -->|Provision resources and role assignments| A
```

**Authentication vs authorization:** Entra proves identity; Azure RBAC determines what that identity can do. The service principal operates against the Kubernetes API, whereas the kubelet managed identity pulls images from ACR. These are separate principals with least-privilege assignments.

**RBAC design:** The service principal receives AKS Cluster User for kubeconfig retrieval, AKS RBAC Reader at cluster scope, and AKS RBAC Writer at the `lab` namespace scope. The kubelet identity receives `AcrPull` at the registry scope. No blanket Owner or Cluster Admin grants are defined.

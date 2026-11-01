# UVU IT 3200 — Terraform AKS, ACR & Identity Lab

**Status: Local starter project only. No Azure resources have been deployed or verified.**

This independent repository contains Terraform definitions for an Azure Resource Group, AKS cluster, private ACR, Entra application and service principal, and Azure RBAC assignments. It also includes a namespace, Deployment, Service, architecture diagram, and documentation templates.

## Requirements
- Azure subscription with AKS/ACR quotas and permissions to register Entra applications and assign RBAC roles
- Terraform, Azure CLI, kubectl, kubelogin, and an image build/import workflow
- Budget approval: AKS node VMs, disks, networking, and ACR may incur charges

## Local validation (no Azure subscription required)
```cmd
cd terraform
terraform init -backend=false
terraform fmt -check
terraform validate
```
`terraform validate` may still depend on provider downloads, but does not create cloud resources. Do not claim successful validation until run locally.

## Deploy only after subscription access is approved
1. Sign in with `az login`; verify `az account show` and subscription permissions.
2. Copy `terraform.tfvars.example` to `terraform.tfvars`; set subscription ID and a globally unique ACR suffix. Never commit `terraform.tfvars`.
3. In `terraform/`, run `terraform init`, `terraform plan`, review costs/resources, then `terraform apply`.
4. Record outputs with `terraform output`. Do not commit state files.
5. Check role assignments and verify that the AKS cluster is reachable.
6. Use an appropriately authorized personal/bootstrap identity to create namespace `lab` (`kubectl apply -f kubernetes/namespace.yaml`). The service principal is not given cluster-admin permissions.
7. Import a test image to ACR (for example `az acr import --name <acr_name> --source docker.io/library/nginx:stable --image nginx:stable`) if registry policies permit.
8. Replace `REPLACE_ACR_LOGIN_SERVER` in `kubernetes/deployment.yaml` with your output `acr_login_server`, then apply Deployment and Service.
9. Verify pods, events, image pulls, and `kubectl port-forward -n lab svc/nginx-demo 8080:80`.
10. Test the service principal with `az login --service-principal` and `kubelogin convert-kubeconfig -l spn` using secure environment variables. A service principal credential must be created separately by an authorized operator. **Do not store it in this repo or expose it in screenshots.** Compare access with personal account; record actual outcomes.
11. Capture evidence and report findings; `terraform plan -destroy`, review carefully, then `terraform destroy`. Check for leftover costs, permissions, and credentials.

**Important:** RBAC role propagation and AKS configuration may need adjustment for your tenant/subscription. The ACR role here assumes standard RBAC mode (`AcrPull`); ABAC-enabled registries require a different role model. Role assignments and namespace setup must be verified in the live environment.

## Files
- `terraform/`: IaC configuration, variables, outputs, and role assignments
- `kubernetes/`: namespace, Deployment, and Service manifests
- `docs/architecture.md`: architecture diagram and trust flows
- `docs/technical-report.md`: required report outline and evidence placeholders
- `docs/troubleshooting.md`: three scenario investigations
- `docs/ai-assistance.md`: AI assistance disclosure and validation log
- `evidence/`: add real screenshots only after deployment

## Security
No Azure credentials, state files, private keys, or kubeconfig files belong in Git. The service principal is intentionally created without a password in Terraform to avoid generating a secret in Terraform state. Authentication testing requires a separately secured credential or an approved alternative.

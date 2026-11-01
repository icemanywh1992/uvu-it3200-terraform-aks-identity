# Technical Report — UVU IT 3200 AKS, ACR & Identity

> **Draft/template.** Do not present any unexecuted step as completed. Fill in only after authorized deployment and testing.

## Executive Summary
Purpose: provision AKS and private ACR using Terraform, test separate Entra identities and least-privilege RBAC, deploy a private-registry image, and investigate failures. **Deployment status: not yet attempted.**

## Architecture Overview
See `architecture.md`. Include resource names, location, trust boundaries, and separate API authentication and kubelet image-pull flows.

## Terraform Infrastructure
Document provider versions, `terraform init/fmt/validate/plan/apply` outcomes, actual resource IDs, and subscription limitations. Attach real plan/apply evidence.

## Identity and Access Management
Document Entra app and SP, personal identity, AKS managed identity, and kubelet identity. Explain why roles are scoped to AKS, namespace, and ACR.

## AKS and ACR Integration
Record registry login server, image name/tag, `AcrPull` assignment, and observed image-pull result.

## Service Principal Authentication Testing
Record Azure login, kubeconfig retrieval, kubelogin method, `kubectl` results, and exact errors (redact secrets).

## Personal Account Troubleshooting Comparison
| Test | Service principal | Personal account |
|---|---|---|
| Azure login | Not tested | Not tested |
| Retrieve AKS credentials | Not tested | Not tested |
| List namespaces | Not tested | Not tested |
| Read lab pods | Not tested | Not tested |
| Deploy workload | Not tested | Not tested |

## Kubernetes Application Deployment
Record namespace, image source, Deployment/Service status, pod status, `kubectl describe` events, and port-forward response.

## Permission and Security Analysis
Explain Cluster User, AKS RBAC Reader/Writer, kubelet AcrPull, and why Owner/Cluster Admin are unnecessary. Note standard RBAC vs ACR ABAC caveat.

## Troubleshooting Findings
See `troubleshooting.md`. Replace hypotheses with observed findings when available.

## Conclusion and Lessons Learned
Summarize what was actually verified, unresolved limitations, and cleanup status.

## Final Reflection — Scale
For 100 clusters, 500 apps, and multiple teams: use reusable Terraform modules, GitOps/CI-CD pipelines, workload identities, per-environment role scopes, private registries, policy-as-code, audit logging, and automated least-privilege reviews. Separate development, testing, and production permissions.

## Evidence checklist
- [ ] Terraform apply output
- [ ] AKS and ACR in portal
- [ ] Registry image and kubelet AcrPull
- [ ] Service principal and roles
- [ ] SP kubectl results
- [ ] Personal identity comparison
- [ ] Running Deployment, Pods, and app access
- [ ] Troubleshooting evidence
- [ ] Terraform destroy verification

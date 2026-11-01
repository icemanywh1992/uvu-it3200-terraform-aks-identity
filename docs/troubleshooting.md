# Troubleshooting investigations (hypotheses; not observed failures)

## Scenario A: SP authenticates, kubectl Forbidden
- Causes: missing AKS RBAC role, wrong scope, role propagation delay, wrong identity or kubeconfig context.
- Commands: `az account show`, `az role assignment list --assignee <object-id> --all -o table`, `kubectl config current-context`, `kubectl auth can-i get pods -n lab`, `kubectl get pods -n lab`.
- Evidence: Entra sign-in succeeds but Kubernetes API responds Forbidden; role/scope listing lacks expected grant.
- Fix: assign the least-privilege reader/writer role at correct scope via Terraform; wait for propagation and retest.
- Prevention: test permission matrices in CI, audit role assignments, avoid blanket admin.

## Scenario B: ImagePullBackOff
- Causes: image/tag typo, missing kubelet AcrPull, wrong principal, registry networking or DNS restrictions.
- Commands: `kubectl describe pod <pod> -n lab`, `kubectl get events -n lab`, `az acr repository list --name <acr> -o table`, `az role assignment list --assignee <kubelet-object-id> --scope <acr-id> -o table`.
- Evidence: events distinguish 401/403 from image-not-found or network timeout.
- Fix: correct image path, grant registry pull to kubelet identity, or resolve networking as supported.
- Prevention: validate image tags and permissions before rollout, monitor pod events.

## Scenario D: Proposal to give all service principals Cluster Admin
- Causes: overbroad workaround for missing namespace-scoped permissions.
- Commands: `az role assignment list --scope <aks-id> -o table`, `kubectl auth can-i --list -n lab`.
- Evidence: privileges exceed deployment requirements and span unrelated namespaces.
- Fix: use AKS Cluster User, scoped Reader, and namespace Writer for deployment identity.
- Prevention: least-privilege role templates, approvals, periodic access review, separation of duties.

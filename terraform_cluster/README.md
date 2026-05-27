# Platform Engineering — Terraform (AKS foundation)

Phase 1 of the Internal Developer Platform: a reusable Terraform module that
provisions a **mid-size AKS cluster** sized to host ~10 microservices (e.g. a
simple e-commerce app) plus the platform components that will follow
(Argo CD, Kargo, Dapr, kube-prometheus-stack).

## Layout

```
Platform_Engineering/terraform/
├── modules/
│   └── aks/                 # Reusable AKS module
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── versions.tf
└── envs/
    └── dev/                 # Dev environment consuming the module
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        ├── versions.tf
        └── terraform.tfvars.example
```

## What gets created

| Resource | Purpose |
|---|---|
| Resource Group | Container for all dev resources |
| VNet + Subnet | `10.40.0.0/16` with a `/22` AKS subnet |
| AKS cluster | Azure CNI **Overlay** + Calico network policy |
| System node pool | 2 × `Standard_D2s_v5`, tainted (CriticalAddonsOnly) |
| User node pool `apps` | `Standard_D4s_v5`, autoscale **3–6 nodes** (12–24 vCPU, 48–96 GB) |
| Log Analytics workspace | Container Insights, 30-day retention |
| Add-ons | OIDC issuer, Workload Identity, KeyVault CSI, Azure Policy, OMS |

### Capacity check for 10 microservices
- Per microservice replica + Dapr sidecar ≈ 350m CPU / 384Mi RAM
- 10 services × 2 replicas ≈ **7 vCPU / 7.5 GB**
- Argo CD + Kargo + kube-prometheus-stack ≈ **4 vCPU / 8 GB**
- 3-node baseline (`D4s_v5`) = 12 vCPU / 48 GB → ample headroom; scales to 6.

## Prerequisites

- Terraform **≥ 1.6**
- Azure CLI logged in: `az login` and `az account set --subscription <id>`
- Permissions: `Contributor` + `User Access Administrator` on the subscription

## Deploy

```powershell
cd Platform_Engineering\terraform\envs\dev
Copy-Item terraform.tfvars.example terraform.tfvars
terraform init
terraform plan -out tfplan
terraform apply tfplan
terraform output -raw get_credentials_cmd | Invoke-Expression
kubectl get nodes
```

## Next phases (not in this module)

1. **Bootstrap** — install Argo CD via Helm; commit a root `Application` (App-of-Apps).
2. **Platform components** — Argo CD-managed Helm releases:
   - `dapr/dapr` (control plane + sidecar injector)
   - `prometheus-community/kube-prometheus-stack`
   - `akuity/kargo`
3. **Developer experience** — a Backstage/Port template or `Application` CRD
   so devs only commit a values file with their image tag; Kargo promotes
   between `dev → staging → prod`.

## Cost note (rough, East US, list price)

| Item | ~Monthly |
|---|---|
| 2 × D2s_v5 system | ~$140 |
| 3 × D4s_v5 user (baseline) | ~$420 |
| Log Analytics (low ingest) | ~$15 |
| Load Balancer Standard | ~$20 |
| **Total baseline** | **~$600/mo** |

Stop the cluster when idle: `az aks stop -g rg-idp-dev -n aks-idp-dev`.

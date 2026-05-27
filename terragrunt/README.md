# Terragrunt — Multi-Cloud IDP Service Templates

Terragrunt wraps the cloud-specific Terraform modules in
[`../terraform_cluster/modules`](../terraform_cluster) and exposes a uniform
`kubernetes-cluster` service that you can stamp out per cloud and per
environment.

## Layout

```
terragrunt/
├── root.hcl                              # backend + provider generator
├── _envcommon/
│   └── kubernetes-cluster.hcl            # cloud-agnostic defaults
└── live/
    ├── azure/dev/
    │   ├── env.hcl                       # cloud=azure, env=dev, region=eastus
    │   └── kubernetes-cluster/terragrunt.hcl   → aks module
    ├── aws/dev/
    │   ├── env.hcl
    │   └── kubernetes-cluster/terragrunt.hcl   → eks module (stub)
    └── gcp/dev/
        ├── env.hcl
        └── kubernetes-cluster/terragrunt.hcl   → gke module (stub)
```

## How the abstraction works

1. **`env.hcl`** declares `cloud`, `env`, `region`, `name` for a directory.
2. **`root.hcl`** reads `env.hcl` and:
   - Picks the **backend** (`azurerm` / `s3` / `gcs`).
   - Generates the right **provider block**.
   - Injects common **inputs/tags**.
3. **`_envcommon/kubernetes-cluster.hcl`** supplies cluster sizing defaults
   (system pool, autoscale range, max pods) and maps a *logical* VM size to
   each cloud (`Standard_D4s_v5` / `m6i.xlarge` / `e2-standard-4`).
4. **Leaf `terragrunt.hcl`** points `terraform.source` at the cloud-specific
   module and supplies cloud-specific inputs only (e.g. `resource_group_name`,
   `vpc_cidr`, `project_id`).

Every cluster module exposes the **same variable interface**:

| Common variable | Azure (AKS) | AWS (EKS) | GCP (GKE) |
|---|---|---|---|
| `name`, `location`, `tags`, `kubernetes_version` | ✓ | ✓ | ✓ |
| `system_node_vm_size`, `system_node_count` | ✓ | ✓ | ✓ |
| `user_node_vm_size`, `user_node_min/max_count`, `user_node_max_pods` | ✓ | ✓ | ✓ |
| `authorized_ip_ranges` | ✓ | ✓ | ✓ |
| Cloud-specific | `resource_group_name`, `vnet_*`, `*_rbac` | `vpc_cidr`, `*_subnet_cidrs`, `availability_zones`, `enable_irsa` | `project_id`, `network_cidr`, `enable_workload_identity` |

Cluster modules also expose the **same outputs** (`cluster_name`,
`cluster_id`, `oidc_issuer_url`) so downstream Terragrunt components
(Argo CD, Kargo, Dapr, kube-prometheus-stack) can `dependency` on a cluster
without caring which cloud it sits in.

## Prerequisites

- Terragrunt **≥ 0.55**
- Terraform **≥ 1.6**
- A pre-created state backend for the cloud you're targeting:
  - Azure: storage account + container (see `root.hcl` for names)
  - AWS: S3 bucket + DynamoDB lock table
  - GCP: GCS bucket
- Authenticated CLI for the target cloud (`az login`, `aws sso login`,
  `gcloud auth application-default login`).

## Deploy Azure dev

```powershell
cd Platform_Engineering\terragrunt\live\azure\dev\kubernetes-cluster
terragrunt init
terragrunt plan
terragrunt apply
```

## Add a new environment (e.g. `azure/staging`)

```powershell
Copy-Item -Recurse live\azure\dev live\azure\staging
# Edit live\azure\staging\env.hcl  → env = "staging", name = "idp-staging"
# Override anything in live\azure\staging\kubernetes-cluster\terragrunt.hcl
terragrunt run-all apply --terragrunt-working-dir live\azure\staging
```

## Add another cloud

The `eks` and `gke` modules are scaffolded with the matching variable surface
but no resources yet. Implement `main.tf` for either — recommended wrappers:

- **EKS:** `terraform-aws-modules/eks/aws` (v20+)
- **GKE:** `terraform-google-modules/kubernetes-engine/google//modules/private-cluster`

Then `terragrunt apply` from `live/aws/dev/kubernetes-cluster` (or `gcp`)
works without any change to root/envcommon configuration.

## Why Terragrunt (vs `envs/dev` Terraform root)

- **DRY**: backend + provider configured once in `root.hcl`.
- **Per-component state**: each service (`kubernetes-cluster`,
  `platform-bootstrap`, `acr`, …) gets its own state file → faster plans,
  smaller blast radius.
- **`dependency` blocks**: future `argo-cd/terragrunt.hcl` can read outputs
  from `kubernetes-cluster` to wire kubeconfig automatically.
- **`run-all`**: deploy/destroy an entire environment in one command.

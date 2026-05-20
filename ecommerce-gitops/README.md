# ecommerce-gitops

Argo CD source of truth. Argo watches this repo (or folder) and reconciles the
cluster to match. Kargo promotes images between environments by updating the
`image.tag` field in `envs/<env>/<service>/values.yaml`.

## Layout

```
ecommerce-gitops/
├── apps/                    ← Argo CD Application manifests (the "App-of-Apps")
│   ├── root.yaml            ← one Application that points at apps/<env>/
│   └── dev/                 ← one Application per service for env=dev
│       ├── catalog.yaml
│       ├── cart.yaml
│       ├── orders.yaml
│       └── frontend.yaml
└── envs/
    └── dev/
        ├── catalog/values.yaml
        ├── cart/values.yaml
        ├── orders/values.yaml
        └── frontend/values.yaml
```

## How it works

1. **Bootstrap**: `kubectl apply -f apps/root.yaml`
   This creates a single Argo CD `Application` watching `apps/dev/`.
2. **Sync wave**: Argo CD discovers `apps/dev/*.yaml` and creates one
   `Application` per microservice. Each points at the corresponding chart in
   `ecommerce-charts/<service>` and pulls values from
   `envs/dev/<service>/values.yaml` in this repo.
3. **Image promotion** (later, via Kargo): a new image build updates
   `envs/dev/<service>/values.yaml` → Argo syncs → Kargo promotes the same
   commit to `envs/staging`, then `envs/prod`.

## Adapt before first apply

The `Application` manifests assume a **single repo** containing both
`ecommerce-charts/` and `ecommerce-gitops/` (current layout). When you split
into separate Git repos, update each Application's `spec.source.repoURL` and
`spec.sources` accordingly.

Update these placeholders before applying:
- `REPO_URL` — set to your Git remote (e.g. `https://github.com/your-org/Platform_Engineering.git`)
- `image.repository` in `envs/dev/*/values.yaml` — set to your ACR login server (e.g. `acridpdev.azurecr.io/<service>`)

# ecommerce-charts

Helm charts for the e-commerce microservices.

```
ecommerce-charts/
├── common/            ← library chart (Deployment, Service, HPA, ServiceMonitor, Ingress, Dapr)
├── catalog/
├── cart/
├── orders/
└── frontend/
```

Each service chart is a thin wrapper: `Chart.yaml` depends on `common`,
`values.yaml` sets image/port/env, and `templates/all.yaml` renders the
library chart's `common.all` template.

## Build a chart locally

```powershell
cd ecommerce-charts\catalog
helm dependency build
helm template . --set image.repository=acridpdev.azurecr.io/catalog
```

## Lint everything

```powershell
Get-ChildItem ecommerce-charts -Directory | Where-Object { $_.Name -ne 'common' } | ForEach-Object {
  helm dependency build $_.FullName
  helm lint $_.FullName
}
```

## Per-service knobs (override in gitops env overlays)

| Value | Purpose |
|---|---|
| `image.repository`, `image.tag` | Container image (Kargo writes `image.tag` per env) |
| `replicaCount`, `autoscaling.*` | Static replicas or HPA |
| `resources.requests/limits` | CPU/memory |
| `env`, `envFrom` | Plain env vars / configmap-secret refs |
| `dapr.enabled` | Inject Dapr sidecar |
| `metrics.enabled` | Emit a `ServiceMonitor` for kube-prometheus-stack |
| `ingress.enabled` | Expose externally (frontend only) |

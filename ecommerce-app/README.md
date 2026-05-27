# Sample E-Commerce App

Polyglot-friendly microservices designed for the IDP. Each service is its own
container; Helm charts and Argo CD `Application` manifests will follow.

## Services

| Service | Port | Role |
|---|---|---|
| `frontend` | 8080 | HTML UI; calls catalog/cart/orders |
| `catalog` | 8001 | Product catalog (in-memory) |
| `cart` | 8002 | Per-user cart (in-memory) |
| `orders` | 8003 | Order placement; calls catalog for price |

All written in Python + FastAPI for brevity. Each service exposes:
- `GET /healthz` — liveness/readiness for Kubernetes probes
- `GET /metrics` — Prometheus metrics (kube-prometheus-stack ready)

## Run locally

```powershell
cd Platform_Engineering\ecommerce-app
docker compose build
docker compose up
# Open http://localhost:8080
```

## Build & push individual images

```powershell
docker build -t ecommerce/catalog:0.1.0 services/catalog
docker build -t ecommerce/cart:0.1.0    services/cart
docker build -t ecommerce/orders:0.1.0  services/orders
docker build -t ecommerce/frontend:0.1.0 services/frontend
```

## Layout

```
ecommerce-app/
├── docker-compose.yml
├── README.md
└── services/
    ├── frontend/   (main.py, templates/, Dockerfile, requirements.txt)
    ├── catalog/
    ├── cart/
    └── orders/
```

## Next steps (planned)

1. **Helm chart** per service under `charts/` (shared library chart for common
   templates: Deployment, Service, ServiceMonitor, Dapr annotations).
2. **Argo CD `Application` (App-of-Apps)** that points at this repo and
   syncs all services into the `ecommerce` namespace on the AKS cluster.
3. **Kargo `Stage`** definitions so a new image tag in `dev` is promoted to
   `staging` → `prod` automatically.
4. **Dapr** components for state store (cart) and pub/sub (order events).

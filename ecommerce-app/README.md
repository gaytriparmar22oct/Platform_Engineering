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
├── observability/
│   ├── jaeger.yaml                    (Jaeger all-in-one for ecommerce-dev)
│   └── grafana-jaeger-datasource.yaml (registers Jaeger in Grafana)
└── services/
    ├── frontend/   (main.py, templates/, Dockerfile, requirements.txt)
    ├── catalog/
    ├── cart/
    └── orders/
```

## Observability — distributed tracing (Jaeger)

All four services are instrumented with **OpenTelemetry** (auto-instrumentation
for FastAPI + httpx). Trace context propagates between services over HTTP, so a
single request (e.g. checkout) produces one end-to-end trace spanning
`frontend → cart / orders → catalog`.

Tracing activates only when `OTEL_EXPORTER_OTLP_ENDPOINT` is set (wired via the
Helm charts in Kubernetes), so local `docker compose up` without a Jaeger
backend keeps working unchanged.

**Components (running on docker-desktop):**

| Component | Namespace | Purpose |
|---|---|---|
| Jaeger all-in-one | `ecommerce-dev` | OTLP collector + in-memory storage + query UI |
| Grafana | `monitoring` | Dashboards; Jaeger added as a data source |
| Prometheus | `monitoring` | Scrapes `/metrics` from each service |

**Deploy Jaeger:**

```powershell
kubectl --context docker-desktop apply -f observability/jaeger.yaml
kubectl --context docker-desktop apply -f observability/grafana-jaeger-datasource.yaml
```

**Access the UIs from your machine (port-forward):**

```powershell
# Jaeger UI  -> http://localhost:16686
kubectl --context docker-desktop -n ecommerce-dev port-forward svc/jaeger-query 16686:16686

# Grafana    -> http://localhost:3000  (user: admin)
kubectl --context docker-desktop -n monitoring port-forward svc/prometheus-stack-grafana 3000:80
```

In Jaeger: pick a service (e.g. `frontend`) → **Find Traces**.
In Grafana: **Explore** → select the **Jaeger** data source → search traces.

> The Jaeger backend uses in-memory storage — traces are lost on pod restart.
> Fine for local/dev; use the Jaeger Operator + Elasticsearch/Cassandra for prod.

## Next steps (planned)

1. **Helm chart** per service under `charts/` (shared library chart for common
   templates: Deployment, Service, ServiceMonitor, Dapr annotations).
2. **Argo CD `Application` (App-of-Apps)** that points at this repo and
   syncs all services into the `ecommerce` namespace on the AKS cluster.
3. **Kargo `Stage`** definitions so a new image tag in `dev` is promoted to
   `staging` → `prod` automatically.
4. **Dapr** components for state store (cart) and pub/sub (order events).

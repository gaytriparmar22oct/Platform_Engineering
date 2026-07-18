from fastapi import FastAPI, HTTPException
from prometheus_client import Counter, make_asgi_app
import os

app = FastAPI(title="catalog")
app.mount("/metrics", make_asgi_app())

# --- OpenTelemetry distributed tracing ---
# Active only when OTEL_EXPORTER_OTLP_ENDPOINT is set (e.g. in Kubernetes), so
# local `docker compose up` without a Jaeger backend keeps working unchanged.
if os.environ.get("OTEL_EXPORTER_OTLP_ENDPOINT"):
    from opentelemetry import trace
    from opentelemetry.sdk.resources import Resource
    from opentelemetry.sdk.trace import TracerProvider
    from opentelemetry.sdk.trace.export import BatchSpanProcessor
    from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
    from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor

    _resource = Resource.create({"service.name": os.environ.get("OTEL_SERVICE_NAME", app.title)})
    _provider = TracerProvider(resource=_resource)
    _provider.add_span_processor(BatchSpanProcessor(OTLPSpanExporter()))
    trace.set_tracer_provider(_provider)
    FastAPIInstrumentor.instrument_app(app)

REQUESTS = Counter("catalog_requests_total", "Total catalog requests", ["endpoint"])

PRODUCTS = {
    "p1": {"id": "p1", "name": "Wireless Mouse",    "price": 19.99, "stock": 50},
    "p2": {"id": "p2", "name": "Mechanical Keyboard","price": 89.99, "stock": 30},
    "p3": {"id": "p3", "name": "USB-C Hub",          "price": 34.50, "stock": 100},
    "p4": {"id": "p4", "name": "4K Monitor",         "price": 329.00,"stock": 12},
    "p5": {"id": "p5", "name": "Webcam HD",          "price": 49.00, "stock": 75},
}


@app.get("/healthz")
def healthz():
    return {"status": "ok"}


@app.get("/products")
def list_products():
    REQUESTS.labels(endpoint="list").inc()
    return list(PRODUCTS.values())


@app.get("/products/{pid}")
def get_product(pid: str):
    REQUESTS.labels(endpoint="get").inc()
    if pid not in PRODUCTS:
        raise HTTPException(404, "product not found")
    return PRODUCTS[pid]


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=int(os.environ.get("PORT", "8001")))

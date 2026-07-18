from fastapi import FastAPI
from pydantic import BaseModel
from prometheus_client import Counter, make_asgi_app
from collections import defaultdict
import os

app = FastAPI(title="cart")
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

REQUESTS = Counter("cart_requests_total", "Total cart requests", ["endpoint"])

# user_id -> { product_id: qty }
CARTS: dict[str, dict[str, int]] = defaultdict(dict)


class AddItem(BaseModel):
    product_id: str
    qty: int = 1


@app.get("/healthz")
def healthz():
    return {"status": "ok"}


@app.get("/carts/{user_id}")
def get_cart(user_id: str):
    REQUESTS.labels(endpoint="get").inc()
    return {"user_id": user_id, "items": CARTS.get(user_id, {})}


@app.post("/carts/{user_id}/items")
def add_item(user_id: str, item: AddItem):
    REQUESTS.labels(endpoint="add").inc()
    cart = CARTS[user_id]
    cart[item.product_id] = cart.get(item.product_id, 0) + item.qty
    return {"user_id": user_id, "items": cart}


@app.delete("/carts/{user_id}")
def clear(user_id: str):
    REQUESTS.labels(endpoint="clear").inc()
    CARTS.pop(user_id, None)
    return {"user_id": user_id, "items": {}}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=int(os.environ.get("PORT", "8002")))

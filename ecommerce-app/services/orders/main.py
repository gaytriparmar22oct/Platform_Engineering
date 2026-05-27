from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from prometheus_client import Counter, make_asgi_app
import httpx
import os
import uuid
from datetime import datetime, timezone

app = FastAPI(title="orders")
app.mount("/metrics", make_asgi_app())

REQUESTS = Counter("orders_requests_total", "Total orders requests", ["endpoint"])
PLACED = Counter("orders_placed_total", "Orders placed")

CATALOG_URL = os.environ.get("CATALOG_URL", "http://catalog:8001")

ORDERS: dict[str, dict] = {}


class OrderItem(BaseModel):
    product_id: str
    qty: int


class PlaceOrder(BaseModel):
    user_id: str
    items: list[OrderItem]


@app.get("/healthz")
def healthz():
    return {"status": "ok"}


@app.post("/orders")
def place_order(order: PlaceOrder):
    REQUESTS.labels(endpoint="place").inc()
    total = 0.0
    line_items = []
    with httpx.Client(timeout=5.0) as client:
        for item in order.items:
            r = client.get(f"{CATALOG_URL}/products/{item.product_id}")
            if r.status_code != 200:
                raise HTTPException(400, f"unknown product {item.product_id}")
            p = r.json()
            line_total = p["price"] * item.qty
            total += line_total
            line_items.append({"product_id": p["id"], "name": p["name"], "qty": item.qty, "line_total": round(line_total, 2)})

    order_id = uuid.uuid4().hex[:10]
    record = {
        "order_id": order_id,
        "user_id": order.user_id,
        "items": line_items,
        "total": round(total, 2),
        "placed_at": datetime.now(timezone.utc).isoformat(),
        "status": "PLACED",
    }
    ORDERS[order_id] = record
    PLACED.inc()
    return record


@app.get("/orders/{order_id}")
def get_order(order_id: str):
    REQUESTS.labels(endpoint="get").inc()
    if order_id not in ORDERS:
        raise HTTPException(404, "order not found")
    return ORDERS[order_id]


@app.get("/orders")
def list_orders(user_id: str | None = None):
    REQUESTS.labels(endpoint="list").inc()
    if user_id:
        return [o for o in ORDERS.values() if o["user_id"] == user_id]
    return list(ORDERS.values())


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=int(os.environ.get("PORT", "8003")))

from fastapi import FastAPI, Request, Form
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.templating import Jinja2Templates
from prometheus_client import Counter, make_asgi_app
import httpx
import os

app = FastAPI(title="frontend")
app.mount("/metrics", make_asgi_app())
templates = Jinja2Templates(directory="templates")

REQUESTS = Counter("frontend_requests_total", "Total frontend requests", ["endpoint"])

CATALOG_URL = os.environ.get("CATALOG_URL", "http://catalog:8001")
CART_URL    = os.environ.get("CART_URL",    "http://cart:8002")
ORDERS_URL  = os.environ.get("ORDERS_URL",  "http://orders:8003")

USER_ID = "demo-user"  # single demo user for simplicity


@app.get("/healthz")
def healthz():
    return {"status": "ok"}


@app.get("/", response_class=HTMLResponse)
def index(request: Request):
    REQUESTS.labels(endpoint="index").inc()
    with httpx.Client(timeout=5.0) as c:
        products = c.get(f"{CATALOG_URL}/products").json()
        cart = c.get(f"{CART_URL}/carts/{USER_ID}").json()
        orders = c.get(f"{ORDERS_URL}/orders", params={"user_id": USER_ID}).json()
    return templates.TemplateResponse(
        "index.html",
        {"request": request, "products": products, "cart": cart["items"], "orders": orders, "user": USER_ID},
    )


@app.post("/add")
def add_to_cart(product_id: str = Form(...)):
    REQUESTS.labels(endpoint="add").inc()
    with httpx.Client(timeout=5.0) as c:
        c.post(f"{CART_URL}/carts/{USER_ID}/items", json={"product_id": product_id, "qty": 1})
    return RedirectResponse("/", status_code=303)


@app.post("/checkout")
def checkout():
    REQUESTS.labels(endpoint="checkout").inc()
    with httpx.Client(timeout=5.0) as c:
        cart = c.get(f"{CART_URL}/carts/{USER_ID}").json()
        items = [{"product_id": pid, "qty": qty} for pid, qty in cart["items"].items()]
        if items:
            c.post(f"{ORDERS_URL}/orders", json={"user_id": USER_ID, "items": items})
            c.delete(f"{CART_URL}/carts/{USER_ID}")
    return RedirectResponse("/", status_code=303)


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=int(os.environ.get("PORT", "8080")))

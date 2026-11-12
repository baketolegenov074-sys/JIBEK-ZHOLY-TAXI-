"""Development API for JIBEK ZHOLY. Not production-hardened yet."""
from __future__ import annotations

import os
import sqlite3
import threading
import uuid
from contextlib import contextmanager
from datetime import datetime, timezone
from pathlib import Path
from typing import Literal

from fastapi import FastAPI, Header, HTTPException, Query
from pydantic import BaseModel, Field, field_validator

BASE_DIR = Path(__file__).resolve().parents[1]
DB_PATH = Path(os.getenv("JIBEK_DB_PATH", BASE_DIR / "jibek.sqlite3"))
_LOCK = threading.RLock()

Service = Literal["cityTaxi", "intercity", "parcel", "towTruck", "mobileTire"]
Status = Literal["searching", "accepted", "driverArriving", "inProgress", "completed", "cancelled"]
ALLOWED_TRANSITIONS = {
    "accepted": {"driverArriving", "cancelled"},
    "driverArriving": {"inProgress", "cancelled"},
    "inProgress": {"completed", "cancelled"},
    "completed": set(),
    "cancelled": set(),
}

class Point(BaseModel):
    latitude: float = Field(ge=-90, le=90)
    longitude: float = Field(ge=-180, le=180)
    address: str | None = Field(default=None, max_length=300)

class OrderCreate(BaseModel):
    service: Service
    pickup: Point
    destination: Point
    vehicleClass: str | None = Field(default=None, max_length=40)
    note: str | None = Field(default=None, max_length=500)

    @field_validator("vehicleClass")
    @classmethod
    def require_vehicle_for_city_taxi(cls, value, info):
        if info.data.get("service") == "cityTaxi" and not (value or "").strip():
            raise ValueError("Для городского такси выберите класс автомобиля")
        return value

    def validate_points_differ(self):
        if (self.pickup.latitude, self.pickup.longitude) == (
            self.destination.latitude, self.destination.longitude
        ):
            raise ValueError("Точки отправления и назначения совпадают")

class OrderOut(BaseModel):
    id: str
    service: Service
    pickup: Point
    destination: Point
    vehicleClass: str | None
    note: str | None
    passengerId: str
    driverId: str | None
    status: Status
    createdAt: str

class StatusUpdate(BaseModel):
    status: Status

app = FastAPI(title="JIBEK ZHOLY API", version="0.1.0")
DB_PATH.parent.mkdir(parents=True, exist_ok=True)

@contextmanager
def connection():
    conn = sqlite3.connect(DB_PATH, timeout=10, isolation_level=None)
    conn.row_factory = sqlite3.Row
    try:
        yield conn
    finally:
        conn.close()

def init_db():
    with _LOCK, connection() as db:
        db.execute("""
        CREATE TABLE IF NOT EXISTS orders (
          id TEXT PRIMARY KEY,
          service TEXT NOT NULL,
          pickup_lat REAL NOT NULL, pickup_lon REAL NOT NULL, pickup_address TEXT,
          destination_lat REAL NOT NULL, destination_lon REAL NOT NULL, destination_address TEXT,
          vehicle_class TEXT, note TEXT, passenger_id TEXT NOT NULL,
          driver_id TEXT, status TEXT NOT NULL, created_at TEXT NOT NULL
        )
        """)
        db.execute("CREATE INDEX IF NOT EXISTS idx_orders_status_service ON orders(status, service)")

init_db()

def dev_identity(x_dev_user_id: str | None) -> str:
    # Temporary identity shim for local integration tests only.
    # Replace with verified JWT authentication before any public deployment.
    if not x_dev_user_id or not x_dev_user_id.strip() or len(x_dev_user_id) > 100:
        raise HTTPException(401, "Требуется авторизация")
    return x_dev_user_id.strip()

def row_to_order(row: sqlite3.Row) -> dict:
    return {
        "id": row["id"], "service": row["service"],
        "pickup": {"latitude": row["pickup_lat"], "longitude": row["pickup_lon"], "address": row["pickup_address"]},
        "destination": {"latitude": row["destination_lat"], "longitude": row["destination_lon"], "address": row["destination_address"]},
        "vehicleClass": row["vehicle_class"], "note": row["note"],
        "passengerId": row["passenger_id"], "driverId": row["driver_id"],
        "status": row["status"], "createdAt": row["created_at"],
    }

@app.get("/health")
def health():
    return {"status": "ok", "service": "jibek-zhholy-api"}

@app.post("/v1/orders", response_model=OrderOut, status_code=201)
def create_order(body: OrderCreate, x_dev_user_id: str | None = Header(default=None)):
    passenger_id = dev_identity(x_dev_user_id)
    try:
        body.validate_points_differ()
    except ValueError as exc:
        raise HTTPException(422, str(exc)) from exc
    order_id = str(uuid.uuid4())
    created = datetime.now(timezone.utc).isoformat()
    with _LOCK, connection() as db:
        db.execute(
            """INSERT INTO orders VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)""",
            (order_id, body.service, body.pickup.latitude, body.pickup.longitude,
             body.pickup.address, body.destination.latitude, body.destination.longitude,
             body.destination.address, body.vehicleClass, body.note, passenger_id,
             None, "searching", created),
        )
        row = db.execute("SELECT * FROM orders WHERE id=?", (order_id,)).fetchone()
    return row_to_order(row)

@app.get("/v1/driver/orders/available", response_model=list[OrderOut])
def available_orders(
    services: list[Service] = Query(...),
    x_dev_user_id: str | None = Header(default=None),
):
    dev_identity(x_dev_user_id)
    if not services:
        return []
    marks = ",".join("?" for _ in services)
    with connection() as db:
        rows = db.execute(
            f"SELECT * FROM orders WHERE status='searching' AND service IN ({marks}) ORDER BY created_at",
            tuple(services),
        ).fetchall()
    return [row_to_order(row) for row in rows]

@app.post("/v1/orders/{order_id}/accept", response_model=OrderOut)
def accept_order(order_id: str, x_dev_user_id: str | None = Header(default=None)):
    driver_id = dev_identity(x_dev_user_id)
    with _LOCK, connection() as db:
        db.execute("BEGIN IMMEDIATE")
        row = db.execute("SELECT * FROM orders WHERE id=?", (order_id,)).fetchone()
        if row is None:
            db.rollback()
            raise HTTPException(404, "Заявка не найдена")
        if row["status"] != "searching":
            db.rollback()
            raise HTTPException(409, "Заявка уже принята или закрыта")
        db.execute(
            "UPDATE orders SET driver_id=?, status='accepted' WHERE id=? AND status='searching'",
            (driver_id, order_id),
        )
        updated = db.execute("SELECT * FROM orders WHERE id=?", (order_id,)).fetchone()
        db.commit()
    return row_to_order(updated)

@app.patch("/v1/orders/{order_id}/status", response_model=OrderOut)
def update_status(order_id: str, body: StatusUpdate, x_dev_user_id: str | None = Header(default=None)):
    actor = dev_identity(x_dev_user_id)
    with _LOCK, connection() as db:
        db.execute("BEGIN IMMEDIATE")
        row = db.execute("SELECT * FROM orders WHERE id=?", (order_id,)).fetchone()
        if row is None:
            db.rollback()
            raise HTTPException(404, "Заявка не найдена")
        if row["driver_id"] != actor and row["passenger_id"] != actor:
            db.rollback()
            raise HTTPException(403, "Нет доступа к этой заявке")
        if body.status not in ALLOWED_TRANSITIONS.get(row["status"], set()):
            db.rollback()
            raise HTTPException(409, "Недопустимый переход статуса")
        db.execute("UPDATE orders SET status=? WHERE id=?", (body.status, order_id))
        updated = db.execute("SELECT * FROM orders WHERE id=?", (order_id,)).fetchone()
        db.commit()
    return row_to_order(updated)

@app.get("/v1/orders/{order_id}", response_model=OrderOut)
def get_order(order_id: str, x_dev_user_id: str | None = Header(default=None)):
    actor = dev_identity(x_dev_user_id)
    with connection() as db:
        row = db.execute("SELECT * FROM orders WHERE id=?", (order_id,)).fetchone()
    if row is None:
        raise HTTPException(404, "Заявка не найдена")
    if actor not in (row["passenger_id"], row["driver_id"]):
        raise HTTPException(403, "Нет доступа к этой заявке")
    return row_to_order(row)

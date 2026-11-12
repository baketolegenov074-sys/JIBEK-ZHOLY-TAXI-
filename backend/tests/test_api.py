import pytest
from fastapi.testclient import TestClient
from app.main import app

@pytest.fixture
def client(tmp_path, monkeypatch):
    # Re-importing module would be needed to change DB_PATH after import;
    # use the isolated in-memory temp file via direct module patch and init.
    import app.main as api
    monkeypatch.setattr(api, "DB_PATH", tmp_path / "test.sqlite3")
    api.init_db()
    return TestClient(app)

HEAD_P = {"X-Dev-User-Id": "passenger-1"}
HEAD_D = {"X-Dev-User-Id": "driver-1"}
ORDER = {
    "service": "cityTaxi",
    "pickup": {"latitude": 42.3154, "longitude": 69.5869, "address": "Шымкент"},
    "destination": {"latitude": 42.32, "longitude": 69.60, "address": "Центр"},
    "vehicleClass": "Эконом"
}

def test_create_order_and_driver_accepts_once(client):
    created = client.post("/v1/orders", json=ORDER, headers=HEAD_P)
    assert created.status_code == 201
    order_id = created.json()["id"]
    available = client.get(
        "/v1/driver/orders/available?services=cityTaxi", headers=HEAD_D
    )
    assert len(available.json()) == 1
    accepted = client.post(f"/v1/orders/{order_id}/accept", headers=HEAD_D)
    assert accepted.status_code == 200
    assert accepted.json()["driverId"] == "driver-1"
    assert accepted.json()["status"] == "accepted"
    second = client.post(f"/v1/orders/{order_id}/accept", headers={"X-Dev-User-Id": "driver-2"})
    assert second.status_code == 409

def test_rejects_same_points(client):
    bad = {**ORDER, "destination": ORDER["pickup"]}
    response = client.post("/v1/orders", json=bad, headers=HEAD_P)
    assert response.status_code == 422

def test_rejects_missing_city_vehicle_class(client):
    bad = {key: value for key, value in ORDER.items() if key != "vehicleClass"}
    response = client.post("/v1/orders", json=bad, headers=HEAD_P)
    assert response.status_code == 422

def test_status_transition_and_access_control(client):
    order_id = client.post("/v1/orders", json=ORDER, headers=HEAD_P).json()["id"]
    client.post(f"/v1/orders/{order_id}/accept", headers=HEAD_D)
    forbidden = client.patch(
        f"/v1/orders/{order_id}/status",
        json={"status": "completed"},
        headers=HEAD_P,
    )
    assert forbidden.status_code == 409
    arriving = client.patch(
        f"/v1/orders/{order_id}/status",
        json={"status": "driverArriving"},
        headers=HEAD_D,
    )
    assert arriving.status_code == 200


def test_passenger_can_cancel_but_cannot_advance_driver_status(client):
    order_id = client.post("/v1/orders", json=ORDER, headers=HEAD_P).json()["id"]
    client.post(f"/v1/orders/{order_id}/accept", headers=HEAD_D)
    denied = client.patch(
        f"/v1/orders/{order_id}/status",
        json={"status": "driverArriving"},
        headers=HEAD_P,
    )
    assert denied.status_code == 409
    cancelled = client.patch(
        f"/v1/orders/{order_id}/status",
        json={"status": "cancelled"},
        headers=HEAD_P,
    )
    assert cancelled.status_code == 200
    assert cancelled.json()["status"] == "cancelled"


def test_unrelated_user_cannot_read_order(client):
    order_id = client.post("/v1/orders", json=ORDER, headers=HEAD_P).json()["id"]
    response = client.get(
        f"/v1/orders/{order_id}",
        headers={"X-Dev-User-Id": "someone-else"},
    )
    assert response.status_code == 403


def test_driver_cannot_accept_own_order_or_see_it_in_available_feed(client):
    own_order = client.post("/v1/orders", json=ORDER, headers=HEAD_D).json()["id"]
    available = client.get(
        "/v1/driver/orders/available?services=cityTaxi", headers=HEAD_D
    )
    assert available.status_code == 200
    assert all(order["id"] != own_order for order in available.json())
    response = client.post(f"/v1/orders/{own_order}/accept", headers=HEAD_D)
    assert response.status_code == 403

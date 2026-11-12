# JIBEK ZHOLY API — development scaffold

This is an initial API implementation for local development and integration
testing. It is **not ready for public deployment**.

## Run locally

```bash
cd backend
python -m venv .venv
# Windows: .venv\\Scripts\\activate
# macOS/Linux: source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

Health check: `GET http://127.0.0.1:8000/health`  
Interactive API docs: `http://127.0.0.1:8000/docs`

For this prototype, requests use the temporary `X-Dev-User-Id` header.
This header is **not authentication**. Before internet deployment it must be
replaced with verified JWT/OIDC tokens, role checks and driver verification.
Also required before production: PostgreSQL, migrations, rate limits, audit
logs, secrets management, HTTPS, privacy/retention policy and monitoring.

The SQLite database is created automatically at `backend/jibek.sqlite3`;
override with `JIBEK_DB_PATH`.

## Current endpoints

- `POST /v1/orders` — passenger creates an order.
- `GET /v1/driver/orders/available?services=cityTaxi&services=parcel` — driver searches compatible open orders.
- `POST /v1/orders/{id}/accept` — atomic accept; only one driver can win.
- `PATCH /v1/orders/{id}/status` — role-aware status transition: passengers can cancel before the trip starts; assigned drivers advance trip statuses.
- `GET /v1/orders/{id}` — passenger or assigned driver reads the order.
- `GET /v1/driver/orders/active` — restore the driver's active order after reopening the app.

A driver cannot accept another order while an accepted, arriving or in-progress order is active.

The current `X-Dev-User-Id` identity is still a development shim; it does not establish passenger/driver roles or verify a driver's eligibility. Do not expose these endpoints to the public internet. No real
SMS login, payments, push notifications, live GPS or production dispatch exists.

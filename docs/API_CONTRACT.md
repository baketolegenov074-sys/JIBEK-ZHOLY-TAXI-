# ЖІБЕК ЖОЛЫ — API contract (draft)

This document defines the first backend boundary shared by the passenger and
driver Flutter applications. It is a contract, not a claim that a server is
already deployed.

## Base URL and transport

- HTTPS only outside local development.
- JSON request and response bodies, UTF-8.
- All timestamps are ISO-8601 UTC.
- Authenticated endpoints use `Authorization: Bearer <access_token>`.
- The server is authoritative for identity, order status, matching and prices.
- Never trust passenger/driver IDs supplied in a request body; derive identity
  from the verified access token.

## Core enums

Service types: `cityTaxi`, `intercity`, `parcel`, `towTruck`,
`mobileTire`.

Order statuses: `draft`, `searching`, `accepted`, `driverArriving`,
`inProgress`, `completed`, `cancelled`.

## Order payload

```json
{
  "id": "client-generated-uuid",
  "service": "cityTaxi",
  "pickup": {
    "latitude": 42.3154,
    "longitude": 69.5869,
    "address": "Шымкент, ..."
  },
  "destination": {
    "latitude": 42.32,
    "longitude": 69.60,
    "address": "Шымкент, ..."
  },
  "createdAt": "2026-11-12T10:00:00Z",
  "vehicleClass": "Эконом",
  "note": null,
  "status": "draft"
}
```

The backend assigns the passenger identity and validates coordinates,
service-specific required fields, service area and permitted status changes.

## Endpoints

| Method | Path | Purpose |
|---|---|---|
| POST | `/v1/orders` | Passenger creates an order |
| GET | `/v1/driver/orders/available` | Driver fetches compatible open orders |
| POST | `/v1/orders/{orderId}/accept` | Driver atomically accepts an order |
| PATCH | `/v1/orders/{orderId}/status` | Update an allowed order status |
| POST | `/v1/driver/location` | Publish an explicitly shared driver location |
| GET | `/v1/orders/{orderId}` | Fetch order details and current status |

## Required server rules

1. Order acceptance must be atomic: only one driver can win.
2. Drivers see only orders compatible with their verified service permissions.
3. A driver cannot accept a cancelled, completed or already accepted order.
4. Status transitions are validated server-side and audited.
5. Location sharing starts only after the driver explicitly goes online and
   stops immediately when they go offline.
6. Prices and estimates are calculated by the server; route-preview distance
   from a public demo router is not a fare quote.
7. Rate-limit geocoding and order creation; validate all input.
8. Keep personal data minimal and provide retention/deletion rules.

## Status

The shared Dart models and repository interface are implemented in
`packages/jibek_shared`. No production API, authentication provider, database,
payment integration, dispatch engine or live driver tracking is deployed yet.
A hosting/authentication choice and server credentials are still required
before live order exchange can be enabled.

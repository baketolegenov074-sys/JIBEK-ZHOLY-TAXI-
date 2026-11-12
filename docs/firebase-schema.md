# JIBEK ZHOLY — Firebase data structure (Step 1)

This is the agreed database blueprint. It does not create a Firebase project,
upload credentials, or enable production access by itself.

## Cloud Firestore

### `users/{uid}`
- `role`: `client | driver | owner`
- `name`: string
- `phone`: string
- `createdAt`: server timestamp

### `drivers/{uid}`
- `approvalStatus`: `pending | approved | rejected`
- `balanceKzt`: integer (KZT tiyn or whole KZT must be standardized before launch; do not mix)
- `commissionPercent`: number
- `carModel`: string
- `carNumber`: string
- `services`: array of enabled service codes
- `createdAt`: server timestamp
- `updatedAt`: server timestamp

### `orders/{orderId}`
- `clientId`: uid
- `driverId`: uid or null
- `service`: `cityTaxi | intercity | parcel | towTruck | mobileTire`
- `pickup`: map with `lat`, `lng`, `address`
- `destination`: map with `lat`, `lng`, `address` (nullable for services that do not require a destination)
- `distanceMeters`: integer
- `priceKzt`: integer
- `status`: `searching | accepted | arrived | inProgress | completed | cancelled`
- `createdAt`, `updatedAt`: server timestamps

### `tariffs/{tariffId}`
- `service`: service code
- `name`: string
- `basePriceKzt`: integer
- `pricePerKmKzt`: integer
- `minimumPriceKzt`: integer
- `isActive`: boolean
- `updatedAt`: server timestamp

### `transactions/{transactionId}`
- `driverId`: uid
- `orderId`: order id
- `type`: `commission | deposit | adjustment`
- `amountKzt`: signed integer
- `createdAt`: server timestamp

### `settings/platform`
- `currency`: `KZT`
- `defaultCommissionPercent`: number
- `updatedAt`: server timestamp

## Firebase Realtime Database

### `/liveDrivers/{uid}`
- `isOnline`: boolean
- `latitude`: number
- `longitude`: number
- `heading`: number or null
- `activeOrderId`: string or null
- `updatedAt`: server timestamp

Use Realtime Database for live driver coordinates/presence; use Firestore for
profiles, orders, tariffs and financial ledger.

## Security and money handling

- Require Firebase Authentication for every app.
- A driver may submit their own registration details, but cannot approve
  themselves or change their balance/commission.
- Only owner-authorized server code may approve drivers or edit tariffs.
- Clients and drivers must not directly write order prices, completed status,
  balances, or commission transactions.
- Calculate fare and commission on trusted server code (Cloud Functions or
  authenticated backend); use an immutable transaction ledger.
- Realtime driver location writes must be authenticated and limited to the
  driver's own uid; production rules must also enforce approved-driver status
  using trusted claims/server mediation. Never trust an `approved` flag sent
  by the mobile client.
- The initial app workflow intentionally does not deploy Firebase rules or
  create credentials. Those require a Firebase project and a security review.

## Currency decision before production

Store money as integer KZT (or integer tiyn consistently). The current
prototype schema uses integer KZT fields; confirm the unit before enabling
payments or commission deductions.

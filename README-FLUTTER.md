# ЖІБЕК ЖОЛЫ — Flutter migration

The original Kotlin Android project remains in `passenger/` and `driver/` as a backup.

## Flutter workspace

- `apps/passenger` — passenger Android app
- `apps/driver` — driver Android app
- `packages/jibek_shared` — shared Material 3 theme and UI components

## Run locally

Install Flutter SDK 3.6+ and Android SDK, then:

```bash
cd apps/passenger
flutter pub get
flutter run
```

For the driver app:

```bash
cd apps/driver
flutter pub get
flutter run
```

## Current status

This is the initial Flutter foundation and visual navigation scaffold. Service tiles and driver online state are local UI only. Real phone authentication, backend, dispatch, maps, live GPS, payments, document verification, and notifications are not yet connected.

## Planned modules

1. Authentication and user profiles
2. Passenger service request flows
3. Driver onboarding and service availability
4. Backend API, database, and order dispatch
5. Maps, geocoding, and location tracking
6. Payments, notifications, safety, and admin tools

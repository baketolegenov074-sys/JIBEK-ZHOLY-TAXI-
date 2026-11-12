# ЖІБЕК ЖОЛЫ — Flutter development

Flutter migration is developed on `flutter-migration`. The original Kotlin modules remain in the repository as backup until Flutter validation is complete.

## Applications

- `apps/passenger`: OpenStreetMap map, address lookup, route preview and vehicle class selection.
- `apps/driver`: map, user-initiated location lookup, local availability switch and service preferences.
- `packages/jibek_shared`: shared theme and reusable UI.

## Current status

| Capability | State |
|---|---|
| OpenStreetMap tiles | Integrated in both screens |
| Foreground device location | Permission-gated, user initiated |
| Address search | Passenger app uses Nominatim for Kazakhstan-wide pickup and destination search |
| Road route preview | Passenger app uses OSRM demo endpoint |
| Passenger order creation and manual status refresh | API integration scaffolded; requires configured backend and test identity |
| Passenger service selection | City taxi, intercity, parcel, tow truck and mobile tire request types; notes field for service details |
| Passenger order recovery after app restart | Saves order ID locally and restores current server status when API access is configured |
| Passenger cancellation before trip start | API and passenger UI implemented; requires configured backend |
| Driver online/offline status and selected services | Saved through the development API; no heartbeat/expiry yet |
| Driver accounts and verification | Not connected |
| Live driver location sharing | Not connected |
| Pricing, payments and receipts | Not connected |
| Parcel, tow and mobile tire workflows | Driver service filters exist; dedicated order forms and workflows remain to be built |

The driver online switch publishes the driver's online/offline state and selected services to the development API. This is not yet a production dispatch heartbeat; stale-session expiry remains to be implemented. Route preview is not a fare quote and does not create a trip. Nominatim and the OSRM demo endpoint are public services without a production SLA; production launch needs an appropriate service plan and usage-policy compliance.

Location is requested only after the user taps the location control. No background tracking is enabled.

## Quality checks

`.github/workflows/flutter-quality.yml` runs `flutter analyze` for both Flutter apps on this branch. It does not build APKs or publish releases.

## Next milestones

1. Generate and validate complete Flutter Android platform projects for both apps.
2. Add backend API, authentication and passenger/driver roles.
3. Complete order lifecycle tests, driver offers, accept/decline and trip updates across both apps.
4. Add consent-based live driver location while on duty, with clear foreground disclosure.
5. Add pricing, payment integration, receipts and operational monitoring.
6. Add end-to-end tests and signed release APKs after explicit release approval.

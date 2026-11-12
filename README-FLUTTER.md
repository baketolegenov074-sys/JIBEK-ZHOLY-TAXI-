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
| Address search | Passenger app uses Nominatim |
| Road route preview | Passenger app uses OSRM demo endpoint |
| Passenger-to-driver dispatch | Not connected |
| Driver accounts and verification | Not connected |
| Live driver location sharing | Not connected |
| Pricing, payments and receipts | Not connected |
| Parcel, tow and mobile tire workflows | Service selection UI only |

The driver online switch is local UI state only; it does not publish availability to a server. Route preview is not a fare quote and does not create a trip. Nominatim and the OSRM demo endpoint are public services without a production SLA; production launch needs an appropriate service plan and usage-policy compliance.

Location is requested only after the user taps the location control. No background tracking is enabled.

## Quality checks

`.github/workflows/flutter-quality.yml` runs `flutter analyze` for both Flutter apps on this branch. It does not build APKs or publish releases.

## Next milestones

1. Generate and validate complete Flutter Android platform projects for both apps.
2. Add backend API, authentication and passenger/driver roles.
3. Implement order lifecycle, driver offers, accept/decline, cancellation and trip updates.
4. Add consent-based live driver location while on duty, with clear foreground disclosure.
5. Add pricing, payment integration, receipts and operational monitoring.
6. Add end-to-end tests and signed release APKs after explicit release approval.

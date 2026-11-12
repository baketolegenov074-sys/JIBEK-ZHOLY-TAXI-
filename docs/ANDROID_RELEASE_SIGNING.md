# Android release signing and update policy

All three Android apps use permanent release signing. The keystore must never be committed to this repository.

## Required GitHub Actions repository secrets

Create these four secrets under **Settings → Secrets and variables → Actions → Repository secrets**:

- `ANDROID_KEYSTORE_BASE64` — the complete Base64 text from the provided `ANDROID_KEYSTORE_BASE64.txt` file.
- `ANDROID_KEYSTORE_PASSWORD` — keystore password from the private secrets file.
- `ANDROID_KEY_ALIAS` — `jibekzholy_release`.
- `ANDROID_KEY_PASSWORD` — key password from the private secrets file.

The workflow intentionally stops with a clear error if any secret is missing. Do not generate a replacement key after the first production build. Keep an offline backup of the JKS file and passwords in a secure location.

## Stable application IDs

These IDs are the permanent identities of the new app line. Do not change them in future releases:

- Passenger: `kz.jibekzholy.client2`
- Driver: `kz.jibekzholy.driverapp2`
- Owner/admin: `kz.jibekzholy.owneradmin2`

## Versioning

The workflow uses the GitHub Actions run number as Android versionCode, so each successful later build has a higher versionCode. Keep the same application IDs and signing key for every update.

## Important

The new app line is intentionally separate from previously installed APKs signed with temporary keys. Install the new line once. Later APKs from this workflow are designed to update over it without uninstalling or losing app data.

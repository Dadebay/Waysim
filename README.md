# Waysim

Travel eSIM app for iOS and Android. Customers pick a destination, buy a data plan, install the eSIM on their phone and top it up later, all from one app.

## What the app does

- **Browse and search** destinations and data plans, with prices in the customer's currency.
- **Buy a plan** and pay from the in-app balance. The balance is topped up with PayPal or crypto.
- **Install the eSIM**: one tap on iPhones that support it, otherwise by scanning a QR code. The app checks whether the device supports eSIM before checkout.
- **My eSIMs**: usage, validity and top-up of an existing eSIM.
- **Account**: sign in with an e-mail code, or keep using the app as a guest. Order history, referral link, notification settings, account deletion.
- **Support chat** and legal pages.
- **Push notifications** for eSIM and order updates.
- **Languages**: English, Russian, Spanish, French, Chinese.

## How it works

The app talks only to the Waysim backend. The backend handles orders, payments and the eSIM supplier, so the app never contacts a supplier directly and holds no supplier keys.

Sign-in gives the app an access token and a refresh token, kept in the system keychain (Keychain on iOS, Keystore on Android). An expired access token is renewed automatically and the failed request is repeated. If renewing fails, the session is cleared and the sign-in screen is shown.

## Project structure

```
lib/
  app/        app shell, routing, startup gates (connection, forced update)
  core/       network, storage, theme, localization, shared widgets, services
  features/   one folder per feature: auth, catalog, purchase, esim, wallet,
              profile, referral, support, notification, legal, config, home
  l10n/       translation files (arb) and generated localizations
  mock/       in-memory backend for development and tests
test/         unit and widget tests
integration_test/
```

Each feature is split into `data` (API and storage), `domain` (entities and repository interfaces) and `presentation` (cubits and screens).

Main tools: Flutter, BLoC/Cubit for state, `go_router` for navigation, `dio` for networking, `get_it` for dependency injection, Firebase (push, crash reports, App Check).

## Running

Requirements: Flutter 3.47 or newer (Dart 3.12).

```bash
flutter pub get
flutter run
```

Build settings are passed with `--dart-define`:

| Name | Meaning |
| --- | --- |
| `FLAVOR` | `dev` (default), `staging` or `prod` |
| `API_BASE_URL` | Backend root. Release builds accept `https://` only |
| `USE_MOCK_API` | `true` runs against the in-memory backend. Ignored in release builds |
| `FIREBASE` | `false` starts the app without Firebase |

Run the app without a backend:

```bash
flutter run --dart-define=USE_MOCK_API=true
```

## Tests

```bash
flutter analyze
flutter test
```

## Release

Android signing reads `android/key.properties`. Without it, the release build is unsigned. iOS builds go through Xcode or `flutter build ipa` with `FLAVOR=prod`.

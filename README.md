# Waysim

Waysim is a Flutter app for discovering and buying travel eSIM data plans on iOS and Android. Travellers can browse country and regional plans, top up an in-app balance, purchase an eSIM, and view its installation details and data usage.

> **API integration:** The app uses the Waysim mobile API by default. See the [integration checklist](docs/api/mobile-integration.md) for connected endpoints and verification boundaries.

## What is in the app?

- Searchable country and regional eSIM catalog with recent searches and package details.
- eSIM compatibility guidance, purchase flow, and an eSIM library with QR code, activation details, usage, and top-up screens.
- Passwordless email-code sign-in, profile, order history, referral, settings, legal pages, and support UI.
- Balance top-ups using the payment methods, coins, networks, and limits returned by the API (currently cryptocurrency).
- English, Chinese, Russian, Spanish, and French; light and dark themes.
- Optional Firebase integration for push notifications, analytics, and crash reporting.

The mobile app calls the Waysim API. The eSIM supplier API and its credentials belong on the backend and are never called directly from the app.

## Run locally

Install a Flutter SDK compatible with the Dart constraint in [`pubspec.yaml`](pubspec.yaml) (currently Dart `^3.11.4`), then run:

```bash
flutter pub get
flutter gen-l10n
flutter run --dart-define=USE_MOCK_API=false
```

The default API address is `https://api.waysim.co`. Set `--dart-define=API_BASE_URL=...` to use another backend. Device registration, email verification, account sessions, catalog, orders, eSIMs, wallet, referrals, legal content, settings, and support use the documented mobile endpoints.

For isolated UI development, `--dart-define=USE_MOCK_API=true` selects local fixtures. Remove that flag or set it to `false` when testing the real API. To open the component gallery, add `--dart-define=INITIAL_ROUTE=/gallery`.


## Project structure

```text
lib/
├── app/          # App shell, routing, session and theme/locale state
├── core/         # Shared services, networking, storage, theme and widgets
├── features/     # Auth, catalog, purchase, eSIM, wallet, profile, support…
├── l10n/         # ARB translations and generated localization classes
└── mock/         # In-memory backend for demos and tests
assets/           # Branding, flags and Gilroy fonts
docs/             # Product, design, architecture, API and roadmap notes
test/             # Unit, widget and mock-flow tests
```

The app uses BLoC/Cubit for state, `go_router` for navigation, `get_it` for dependency injection, `dio` for networking, and `hydrated_bloc` for persisted preferences. See the [architecture notes](docs/04-architecture.md) for details.

## Checks

```bash
flutter analyze
flutter test
dart run tool/roadmap_status.dart
```

The [integration checklist](docs/api/mobile-integration.md) records the current mobile API wiring; the [roadmap](docs/06-roadmap.md) contains the earlier implementation plan. Start at the [documentation index](docs/README.md) for the product specification, design system, platform notes, and Firebase setup.

## Before production

Unit and widget tests exercise API contracts with intercepted HTTP responses. Real email delivery, payment-provider callbacks, supplier provisioning, push delivery, and installation on a physical eSIM-capable phone require end-to-end verification against the intended backend. Keep payment and supplier credentials on the backend.

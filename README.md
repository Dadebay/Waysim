# Waysim

Waysim is a Flutter app for discovering and buying travel eSIM data plans on iOS and Android. Travellers can browse country and regional plans, top up an in-app balance, purchase an eSIM, and view its installation details and data usage.

> **Project status:** The mobile experience currently runs against an in-memory mock backend. Authentication, purchases, balance top-ups, and payment confirmations in demo mode are simulated; they do not create real accounts, charge money, or issue real eSIMs. The production API integration is still pending.

## What is in the app?

- Searchable country and regional eSIM catalog with recent searches and package details.
- eSIM compatibility guidance, purchase flow, and an eSIM library with QR code, activation details, usage, and top-up screens.
- Passwordless email-code sign-in, profile, order history, referral, settings, legal pages, and support UI.
- Balance top-up flows for PayPal and cryptocurrency, simulated by the mock backend.
- English, Chinese, Russian, Spanish, and French; light and dark themes.
- Optional Firebase integration for push notifications, analytics, and crash reporting.

The mobile app is designed to call the Waysim API. The eSIM supplier API and its credentials belong on the backend and are never called directly from the app.

## Run locally

Install a Flutter SDK compatible with the Dart constraint in [`pubspec.yaml`](pubspec.yaml) (currently Dart `^3.11.4`), then run:

```bash
flutter pub get
flutter gen-l10n
flutter run --dart-define=USE_MOCK_API=true
```

The mock backend is enabled by default for non-production flavors, but passing `USE_MOCK_API=true` makes demo runs explicit. To open the component gallery, add `--dart-define=INITIAL_ROUTE=/gallery` to the `flutter run` command.

### Demo account and flows

| Action | Demo behavior |
| --- | --- |
| Sign in | Use any email address and any six-digit code except `000000`. No email is sent. |
| Existing customer | `anna@example.com` has sample eSIMs, orders, and referral history. |
| New customer | Any other email address starts with an empty account. |
| Starting balance | `$24.50` for every demo account. |
| Failed purchase | The Thailand 3 GB plan (`TH_3_30`) simulates a supplier failure and refund. |
| Balance top-up | PayPal and crypto payments progress through simulated states. No real payment is made. |

To build a **demo** Android APK locally with mock data, use `flutter build apk --dart-define=FLAVOR=prod --dart-define=USE_MOCK_API=true`. This builds a demo, not a production-ready payment or eSIM service. Without `USE_MOCK_API=true`, the production flavor cannot start until real API repositories are implemented.

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

The [roadmap](docs/06-roadmap.md) tracks implemented work and remaining integration tasks. Start at the [documentation index](docs/README.md) for the product specification, design system, platform notes, and Firebase setup.

## Before production

The real Waysim backend and eSIM supplier integration, live payment processing, store configuration, and device testing still need to be completed and verified. Keep payment and supplier credentials on the backend. Review the [open questions](docs/07-open-questions.md) and [roadmap](docs/06-roadmap.md) before using this app with real customers.

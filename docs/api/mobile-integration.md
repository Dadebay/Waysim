# Mobile API integration

The app uses `https://api.waysim.co` by default, configurable with `API_BASE_URL`. Local fixtures require an explicit `USE_MOCK_API=true`. No admin or supplier credentials are included in the mobile client.

Sources: [mobile contract](client-api.md), [Postman collection](waysim-client-api.postman_collection.json), supplied on 16 October 2026. Existing screens, typography, themes, cards and navigation layouts are retained. Server content replaces fixtures.

## Endpoint coverage

| Area | Endpoints | Application use |
| --- | --- | --- |
| Startup | `POST /v1/devices`, `PUT /v1/devices/me`, `GET /v1/meta` | Persisted install UUID, shared registration, device bearer token, app/language headers, maintenance/version gate. |
| Authentication | `POST /v1/auth/otp/request`, `/otp/verify`, `/refresh`, `/logout` | Consent, invitation validation, server resend interval, secure token storage and rotation, guest fallback. |
| Account | `GET/PATCH /v1/me`, `GET /v1/me/devices`, `POST /v1/me/delete` | Restored profile, name/language/notification settings, device list, account deletion. Existing deletion-code confirmation reauthenticates through the standard OTP endpoint before deletion. |
| Catalog | `GET /v1/catalog/home`, `/search`, `/locations/:code`, `/packages/:id` | Localized destinations, server banners, debounced remote search with local fallback, package details and per-day plan totals. |
| Purchases | `POST /v1/orders`, `GET /v1/orders`, `/orders/:id` | Idempotency header, asynchronous allocation polling, order history and refund handling. Retries in the same purchase flow keep their key/order ID. |
| eSIM | `GET /v1/esims`, `/esims/:id`, `POST /esims/:id/refresh` | Current/archive lists, real installation/QR credentials, usage and supplier refresh. Installation state is never fabricated by a tap. |
| eSIM top-ups | `GET/POST /v1/esims/:id/topups` | Available extensions, server restrictions and order completion tracking. |
| Balance | `GET /v1/wallet` | Authoritative balance, amount limits and resumable pending payment. |
| Payments | `GET /v1/payments/methods`, `/payments/crypto/currencies`, `POST /v1/payments`, `GET /v1/payments`, `/payments/:id` | Enabled methods, dynamic coin/network selector and minimums, exact decimal amount, memo/tag and QR value, idempotent creation, status polling every 10 seconds while foregrounded. Review/failed states never imply credit. |
| Referrals | `GET /v1/referral`, `/referral/invitations`, `/referral/codes/:code` | Server reward, rules, enabled flag, paginated masked invitations and code validation. |
| Legal | `GET /v1/legal`, `/legal/:doc` | Published document list and localized Markdown including tables/links, in existing legal screens. |
| Support | `GET /v1/support/thread`, `/support/messages`, `POST /support/messages`, `/support/read` | Signed-in support conversation, existing messages, saved user messages, staff replies, read receipts; polling every 5 seconds while foregrounded. |
| Push | `PUT /v1/devices/me/push-token`, `POST /v1/notifications/opened` | FCM token registration, tap tracking, documented deep links and Android channels. |

The repository interfaces also expose `DELETE /v1/me/devices/:id`, `DELETE /v1/devices/me/push-token`, and `GET /v1/wallet/ledger`. The existing design has no device-removal control, separate push deregistration control, or ledger screen, so no new controls/screens were added. Server logout already detaches the device/push association.

Health probes and `/v1/dev/*` helpers are operational/development endpoints, not customer app actions; the app does not call them.

## Integration behavior

- Local fixtures and live catalog caches are separate. Guest device identity survives account sign-out; user tokens are cleared when the API rejects the session.
- `token_expired` refreshes once; a rotated access token is reused by concurrent failed requests. Network failures during refresh keep the session. An expired guest device token triggers registration again.
- Purchases send `packageId` and optional per-day `days`; money-moving calls use `Idempotency-Key` headers. Success requires a completed order with an eSIM ID. Closing a purchase screen stops polling without cancelling the server order; its eventual result is available in Orders/My eSIM and push notifications.
- Money uses integer USD cents; crypto payment quantities remain the exact decimal strings from the provider. A successful top-up displays actual `creditedCents` when supplied.
- All cursor pages are read for the existing lists. Repeated cursors fail rather than looping indefinitely. Search ignores responses superseded by newer input.
- Payment/session/installation secrets are redacted from HTTP body logs.
- Locale changes reload server-localized catalog/config and update device/account preferences. Notification settings use the profile values and roll back with an error toast if saving fails.
- New legal documents and server payment options can change visible content; the existing visual components remain in use.

## Verification

```sh
flutter analyze
flutter test
```

Contract tests in `test/api/client_api_test.dart` exercise intercepted HTTP responses, including device registration, OTP payloads, per-day prices, idempotency, order polling/refunds, crypto minimums/exact amounts, cursor pages, eSIM installation data, legal/referral content and support reply ordering.

Read-only live checks returned HTTP 200 for `/v1/meta`, `/v1/legal`, and `/v1/legal/terms`. No real OTP, payment, purchase, support message, account deletion, or device revocation was submitted during implementation. Live email delivery, payment-provider callbacks, supplier provisioning, device push delivery and actual eSIM installation still require testing with the intended backend/account/device. No APK was built.

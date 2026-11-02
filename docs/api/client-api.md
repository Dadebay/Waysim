# Waysim client API (mobile)

Contract between the Flutter app and the backend. Every change to an endpoint is reflected here and in the changelog below; `pnpm docs:check` fails the build when the reference section and the served OpenAPI diverge.

## 0. Changelog

- **2026-10-23** — contacts: `GET /v1/meta` → `contacts { website, email, telegram, instagram }`, each `{ label, url }` or null (managed in the admin page «Контакты»). Show them on the support/about screen: `label` as the text, open `url` (`https://…`, `mailto:…`, `https://t.me/…`, `https://www.instagram.com/…/`); hide a null one. `supportEmail` stays (= `contacts.email.label`).
- **2026-10-23** — banners per language: the admin uploads a picture for each app language (the texts are drawn on it), and `GET /v1/catalog/home` → `banners[].imageUrl`/`width`/`height` are those of the `Accept-Language` picture (English when that language has none). Same shape as before — just send `Accept-Language` (already required) and refetch home after the user changes the app language.
- **2026-10-22** — `GET /v1/payments/:id` also accepts the payment number (`publicNo`, e.g. `58008`); the `payment_credited` push now carries the payment **uuid** in `data.paymentId` (it carried the number, which `GET /v1/payments/:id` could not open). The push is sent for automatic credits and for credits an admin makes on a payment under review.
- **2026-10-22** — invite links work: `referral.link` (`https://waysim.co/r/<code>`) opens a localized invite page on the site (code, copy button, store buttons) instead of a 404, and is ready to open the app directly as an iOS Universal Link / Android App Link (`/r/*`, `/*/r/*`) once the app IDs are configured on the site. New deep link `waysim://invite/<code>`. What the app must do: §3 **Invite links**.
- **2026-10-22** — coin and network pickers: `GET /v1/payments/crypto/currencies` also returns `coins[]` — the same pairs grouped by coin (`{ coin, name, logoUrl, networks: [...] }`) for the «Монета» → «Сеть» dropdowns; each network (and each `currencies[]` item) gained `feeOnTop`. `currencies[]` is unchanged. Changing the network on the payment screen means a new `POST /v1/payments` with the other `payCurrency`.
- **2026-10-21** — crypto fees on stablecoins: USDT/USDC top-ups are no longer fixed-rate. The backend adds the processing and network fee on top of the amount, so a $3.00 top-up in USDT BEP-20 is `payAmount: "3.04"` and the processor's ~$9 fixed-rate minimum is gone (USDT BEP-20 / TON / Polygon from $1; USDT TRC-20 still ≈ $12 because of Tron fees). `CryptoPayment` gained `feeCents` and `totalCents` (both `null` for fixed-rate coins such as BTC, whose fee stays inside `payAmount`). `wallet.limits.minCents` is now `100` ($1), so a top-up can cover exactly what a purchase is missing. For stablecoins `expiresAt` is the 20-minute quote.
- **2026-10-20** — signing out ends a session at once: after `DELETE /v1/me/devices/:id` (or `POST /v1/auth/logout`, a new sign-in on that device, a ban or account deletion) every request with that session's access token gets **`401 session_revoked`** — before it would keep working until it expired. `POST /v1/auth/refresh` with such a refresh token also returns `session_revoked` (it no longer counts as reuse, so the user's other devices are not affected). The signed-out device gets a `signed_out` push (Android channel `account`). Handle it: drop `accessToken`/`refreshToken`, keep using the device token as a guest, show the sign-in screen with «You were signed out on this device». Docs fix: `Device` has `current` and `hasPushToken` (not `isCurrent`/`pushEnabled`).
- **2026-10-12** — documents: the seven Waysim documents (`terms`, `refund`, `acceptable_use`, `privacy`, `pre_purchase`, `esim_guide`, `in_app_texts`) replace the six old slots (`general` and `cookies` are gone), texts in English and Russian only (zh/es/fr get English with `fallback: true`), pages at `https://waysim.co/<slug>` (`/terms`, `/refund`, `/fair-use`, `/privacy`, `/pre-purchase`, `/esim-guide`, `/in-app-texts`); `meta.legal` keys changed accordingly. Bodies use GFM tables.
- **2026-10-10** — crypto top-ups through NOWPayments, the only payment method for now: `GET /v1/payments/crypto/currencies` (coin picker with per-coin minimums), `POST /v1/payments { provider: "crypto", payCurrency }` returns `Payment.crypto` (address, exact amount with fees, memo, QR value, status) instead of a `checkoutUrl`; `expiresAt` is the processor's quote deadline (5–10 min). New payment status `review_late`; `wallet.pendingPayment` gained `provider` and `status` and includes `confirming` payments. The `mock` provider, its test checkout page and the dev balance credit are gone — every top-up is a real NOWPayments payment.
- **2026-10-09** — home banners are managed in the admin: `GET /v1/catalog/home` → `banners[]` is now `{ id, imageUrl, width, height, link }` — a ready-made picture (texts are baked into it) plus what a tap opens (§5 **Banner**); `kind`, `title`, `text`, `ctaLabel`, `style` are gone. New deep link `waysim://how-it-works`.
- **2026-10-09** — legal documents: `GET /v1/legal`, `GET /v1/legal/:doc` (Markdown, 5 languages, written in the admin); `GET /v1/meta` now carries six `legal` links plus `legalDocuments`.
- **2026-10-08** — initial contract: devices, OTP auth, profile, catalog (5 languages), orders, eSIMs + top-ups, wallet, payments (mock provider), referral, support chat, push.

## 1. Environments

|           | Base URL                       | Notes                                                                                                                                                                                        |
| --------- | ------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Local dev | `http://localhost:3000`        | `cd backend && docker compose up -d && pnpm dev`; simulated supplier orders over the real eSIM Access catalog, fixed OTP `123456`, real NOWPayments payments (send real coins to finish one) |
| Swagger   | `/docs` (`/docs/openapi.json`) | interactive reference of exactly these endpoints                                                                                                                                             |
| Postman   | `docs/postman/`                | `waysim-client-api.postman_collection.json` + `waysim-local.postman_environment.json`: every endpoint in app order, tokens/ids captured automatically; regenerated by `pnpm postman:export`  |
| Mailpit   | `http://localhost:8025`        | OTP e-mails in dev                                                                                                                                                                           |

Content is served in five languages: `en` (default and fallback), `zh`, `ru`, `es`, `fr`.

## 2. Conventions

### Headers

| Header            | When                                                               | Value                                                                                                             |
| ----------------- | ------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------- |
| `Authorization`   | all authenticated calls                                            | `Bearer <deviceToken>` (guest) or `Bearer <accessToken>` (user)                                                   |
| `X-Device-Id`     | optional, recommended                                              | the `device.id` from `POST /v1/devices`; must match the token's device, otherwise `401`                           |
| `Accept-Language` | all calls                                                          | `ru`, `en-US`, `zh-Hans`, … → picks one of the 5 content languages (fallback: device locale → user locale → `en`) |
| `X-App-Version`   | all calls                                                          | e.g. `1.0.0 (12)`; a version below `meta.minAppVersion` gets `426 app_update_required` (enforced later)           |
| `Idempotency-Key` | money-moving `POST`s (`/orders`, `/esims/:id/topups`, `/payments`) | client-generated UUID per attempt, 8–128 chars; a retry with the same key replays the first result                |
| `X-Request-Id`    | optional                                                           | echoed back; also present on every response for support tickets                                                   |

### Authentication levels

1. **Guest (device token)** — obtained from `POST /v1/devices`. Lives 30 days; call `POST /v1/devices` again at every app start (idempotent by `installId`) to refresh it and to learn whether the device is still signed in.
2. **User (access token)** — returned by `POST /v1/auth/otp/verify`. Lives `accessExpiresIn` seconds (server setting, 15 min – 1 h; don't hard-code it). Refresh it with `POST /v1/auth/refresh` using the opaque `refreshToken` (30 days, rotated on every use; reusing an old refresh token revokes the whole session and returns `401 token_reused` → sign in again). Run one refresh at a time: two parallel refreshes with the same token look like reuse.

Store `deviceToken`, `accessToken`, `refreshToken` in secure storage. On `401` with code `token_expired` → refresh and retry once. On `401 session_revoked` (signed out from another device, logged out, banned or deleted) or any other `401` → drop the user tokens and go to the sign-in screen; the device token stays valid for the catalog. For `session_revoked` tell the user why («You were signed out on this device»).

### Money, dates, bytes, pagination

- Money is integer **USD cents** (`priceCents: 349`); a ready-to-display string is always next to it (`priceFormatted: "$3.49"`).
- Dates are ISO-8601 UTC strings. Data volumes are bytes (`1073741824` = 1 GB, GB = 1024³); `null` total means unlimited.
- Lists are cursor-paginated: `{ "items": [...], "nextCursor": "..." | null }` → pass `?cursor=` to continue.
- Public ids: user id / invite code `A001248` (letter + 6 digits), order number `10234`, payment number `58012`.

### Errors

Every error is `{ "code": "...", "message": "...", "details"?: {...}, "requestId": "..." }`:

| HTTP | code                                                                                                                                                               | meaning                                                 |
| ---- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------- |
| 400  | `otp_invalid`, `otp_expired`, `otp_cooldown`                                                                                                                       | OTP problems (`details.retryAfterSeconds` for cooldown) |
| 401  | `unauthorized`, `token_expired`, `token_reused`, `session_revoked`                                                                                                 | sign-in required / refresh / reuse / signed out         |
| 402  | `insufficient_balance`                                                                                                                                             | `details.needCents` = how much is missing               |
| 403  | `forbidden`, `user_banned`, `guest_not_allowed`, `account_disabled`                                                                                                |                                                         |
| 404  | `not_found`                                                                                                                                                        |                                                         |
| 409  | `conflict`, `in_progress`, `package_unavailable`, `esim_not_topupable`, `topup_limit_reached`, `topup_unavailable`, `topup_failed`                                 |                                                         |
| 422  | `validation` (`details.fields[]`), `idempotency_mismatch`, `invite_code_invalid`, `payment_amount_out_of_range` (`details.minCents/maxCents`, per coin for crypto) |                                                         |
| 426  | `app_update_required`                                                                                                                                              |                                                         |
| 429  | `rate_limited`, `otp_too_many_attempts`                                                                                                                            |                                                         |
| 503  | `maintenance`, `supplier_unavailable`, `payment_provider_unavailable`                                                                                              | retry later                                             |
| 500  | `internal`                                                                                                                                                         | report `requestId`                                      |

Rate limits (per IP/token): OTP request 10 per 10 min, OTP verify 20 per 10 min, support messages 20 per 10 min, global 300 requests per minute.

## 3. Lifecycles

### App start

1. `POST /v1/devices` with the install id (generate once, keep forever) → `deviceToken` and, if this device is still attached to a user, `user`.
2. `GET /v1/meta` → maintenance flag, minimum version, legal links, support e-mail.
3. `GET /v1/catalog/home` (device token is enough).

### Sign in / sign up (one flow)

1. `POST /v1/auth/otp/request` `{ email, adultConsent: true, inviteCode? }` → `resendAfterSeconds`, `ttlSeconds`. The code is e-mailed in the device language. Validate an invite code beforehand with `GET /v1/referral/codes/:code`.
2. `POST /v1/auth/otp/verify` `{ email, code }` → `user`, `tokens`, `isNewUser`. New users get a public id (`A001249`) which is also their invite code. The device is attached to the user and its push token starts receiving the user's notifications.
3. Later: `POST /v1/auth/refresh`; `POST /v1/auth/logout` (returns a fresh guest device token).
4. Signed out elsewhere: when the user signs this device out from another phone (`DELETE /v1/me/devices/:id`), the next request here gets `401 session_revoked` and a `signed_out` push arrives — drop the user tokens and continue as a guest.

### Buying an eSIM

1. `GET /v1/catalog/locations/TR` → packages; `GET /v1/catalog/packages/:id` → details.
2. `POST /v1/orders` `{ packageId, days? }` with `Idempotency-Key` → **202** `{ order: { status: "pending" }, pollAfterMs: 2000 }`. The price is debited from the balance immediately.
3. Poll `GET /v1/orders/:id` every `pollAfterMs` (or wait for the `order_done` push). `status` becomes `done` (→ `esimId`) or `failed_refunded` (money is back, `failedReason` explains).
4. `GET /v1/esims/:id` → `install` block: `lpaString` for a QR code, `smdpAddress` + `activationCode` for manual entry, `appleUniversalLink` for iOS 17.4+ one tap. Show `warnings` and `installBefore`.
5. Package days start at the first connection abroad (`activationRule: "first_connection"`); status moves `not_installed → installed → active → used_up | expired` from supplier webhooks. `POST /v1/esims/:id/refresh` forces a sync (once per 10 min).

### Top-up

`GET /v1/esims/:id/topups` → options (same `PackageCard` shape) or `reason` why none (`status`, `limit`, `not_supported`). `POST /v1/esims/:id/topups { packageId: <slug> }` with `Idempotency-Key` → **201** when applied synchronously, **202** `{ order.status: "processing" }` in the rare ambiguous case (poll `GET /v1/orders/:id`). Up to 9 top-ups per eSIM; `topup_failed` means the balance was refunded.

### Balance top-up (crypto, NOWPayments)

Crypto is the only top-up method for now (`GET /v1/wallet` → `methods: [{ provider: "crypto", kind: "crypto" }]`). The app draws the payment screen itself — there is no page to open:

1. **Amount** — the `$10 / $20 / $50 / $100 / other` sheet, limited by `wallet.limits` (`$1–$500`). Coming from a purchase that failed with `402 insufficient_balance`, prefill `details.needCents` (raised to the coin's `minCents` if needed) and return to the purchase once the payment is `credited`.
2. **Coin and network** — `GET /v1/payments/crypto/currencies` → `coins[]` for the two dropdowns: «Монета» lists `coins[].coin` (USDT, BTC, …), «Сеть» lists that coin's `networks[].network` (TRC-20, BEP-20, TON, …). Each network is `{ code, coin, network, name, logoUrl, extraIdRequired, minCents, feeOnTop }` and its `code` is the `payCurrency` to send. Preselect the first coin and its first network (the admin's order). The flat `currencies[]` has the same items for a single "USDT · TRC-20" list. A coin whose `minCents` is above the chosen amount is disabled with "от $X" (the processor's minimum, never below `wallet.limits.minCents`; it moves with network fees: USDT TRC-20 ≈ $12, other stablecoins $1, BTC and other volatile coins ≈ $9). Put the cheap stablecoin networks (BEP-20, TON, Polygon) first for small amounts. Changing the coin or network after the payment was created means a new invoice: `POST /v1/payments` with the new `payCurrency` and a new `Idempotency-Key`, then show the new address and amount (the old one simply expires unpaid).
3. **Create** — `POST /v1/payments { amountCents, provider: "crypto", payCurrency: code }` with `Idempotency-Key` → `Payment` with `crypto`:
   - `payAmount` — the exact amount to send, as a decimal string (keep it a string, never round). It is a bit more than the USD amount: **the customer pays the processing and network fees**, the balance receives exactly `amountCents`.
   - `feeCents` / `totalCents` — stablecoins only: the fee added on top and `amountCents + feeCents` (what `payAmount` is worth). Show it: "$3.00 + $0.04 fee = $3.04". `null` for other coins — their fee is built into the frozen rate.
   - `payAddress` + QR of `qrValue`, `network`, `coin`; copy buttons for address and amount.
   - `payExtraId` — memo / destination tag (XRP, XLM, TON-style coins): when not null show it prominently, the deposit is not found without it.
   - `rateUsd` — fixed-rate coins: "Курс зафиксирован: 1 BTC = $80 000 (комиссия включена)". For stablecoins it is ≈ 1, show the fee line instead.
   - `expiresAt` — countdown: 5–10 minutes for fixed-rate coins (the rate is frozen until then), 20 minutes for stablecoins. Warn: "Отправьте ровно N в сети X одной транзакцией".
4. **Wait** — poll `GET /v1/payments/:id` every 5–10 s while the screen is open (the backend refreshes from NOWPayments itself, IPNs are not required). Steps: `pending` "Ожидаем оплату" → `confirming` "Платёж найден, подтверждается" (`crypto.txid`, `crypto.paidAmount`; NOWPayments reports no confirmation count, so show no "N из M") → `credited` "Зачислено" (+ `payment_credited` push, back to the purchase). The user may close the screen; `GET /v1/wallet` → `pendingPayment` lets you resume it.
5. **Endings** — `expired`: the quote ran out with no money seen → offer "Создать новый счёт". `review_underpaid`, `review_overpaid`, `review_late` (money came after `expiresAt`): "Платёж на проверке — поддержка зачислит вручную", the balance is credited by an admin. `cancelled`: the processor failed.

Errors: `payment_amount_out_of_range` (422, `details.minCents` of that coin — show "Минимум для этой монеты $X"), `validation` with `fields: ["payCurrency"]` (coin no longer offered — reload the list), `payment_provider_unavailable` (503, retry later).

### Referral

`GET /v1/referral` → the user's code, share link, rules text and stats. The inviter is paid (`$3` by default) **after the invited friend's first balance top-up**, not at registration. `GET /v1/referral/invitations` lists friends with masked e-mails and status.

### Invite links

Share `referral.link` = `https://waysim.co/r/<code>` (the code is the inviter's public id, `A001248`). The same invite arrives in the app in three ways — handle all of them the same:

| how                                         | URL the app receives                                                     |
| ------------------------------------------- | ------------------------------------------------------------------------ |
| link tapped, app installed (Universal/App Link) | `https://waysim.co/r/<code>` (or `https://waysim.co/<locale>/r/<code>`) |
| «Open in the Waysim app» on the invite page | `waysim://invite/<code>`                                                 |
| Android, installed from the invite page     | Play Install Referrer: `invite_code=<code>` (read once on first launch) |

On an invite: uppercase the code, check it with `GET /v1/referral/codes/:code`, keep it until sign-up and send it as `inviteCode` in `POST /v1/auth/otp/request` (prefill the invite field). Codes count for **new** accounts only — when the user is already signed in, just open the app (optionally say so). iOS has no install referrer: after installing from the App Store the user types the code (the page offers a copy button).

App setup: iOS — Associated Domains `applinks:waysim.co`, URL scheme `waysim`; Android — `<intent-filter android:autoVerify="true">` for `https://waysim.co` with `pathPrefix="/r/"` and `pathPattern="/.*/r/.*"`, plus the `waysim` scheme with host `invite`. The site serves `/.well-known/apple-app-site-association` and `/.well-known/assetlinks.json` from its env: send the Apple **Team ID + bundle id** and the Android **package name + SHA-256 fingerprints** of the signing keys (Play Console → App integrity → App signing, plus the upload/debug keys for test builds). Until then the link opens the invite page in the browser.

### Support chat (no sockets)

`GET /v1/support/thread` when opening the chat (creates the thread; last 50 messages). While the screen is open poll `GET /v1/support/messages?after=<lastId>` every 5 s (`pollIntervalMs`). Send with `POST /v1/support/messages`; mark staff replies read with `POST /v1/support/read`. Replies also arrive as a `support_reply` push; `GET /v1/me` → `support.unread` shows the badge.

### Push notifications (FCM)

Register the token with `PUT /v1/devices/me/push-token` (and delete it on sign-out of push). Every message carries `data` (all strings):

| field        | values                                                                                                                                                                                                                                          |
| ------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `type`       | `order_done`, `order_failed`, `topup_done`, `topup_failed`, `esim_status`, `esim_usage_low`, `esim_expiring_soon`, `support_reply`, `referral_bonus`, `payment_credited`, `wallet_adjusted`, `reward`, `broadcast`, `signed_out`                |
| `deepLink`   | `waysim://home`, `waysim://how-it-works`, `waysim://esims`, `waysim://esims/<id>`, `waysim://orders/<id>`, `waysim://wallet`, `waysim://referral`, `waysim://support`, `waysim://country/TR`, `waysim://region/eu-42`, `waysim://packages/<id>` |
| `deliveryId` | report taps with `POST /v1/notifications/opened`                                                                                                                                                                                                |
| optional     | `esimId`, `orderId`, `paymentId`, `threadId`, `broadcastId`, `status`                                                                                                                                                                           |

Android channels: `orders`, `esim`, `support`, `wallet`, `marketing`, `account` (`signed_out`: this device was signed out from another one — drop the user tokens). Titles/bodies are localized to the device language.

### Account deletion

`POST /v1/me/delete { confirm: true }` anonymises the account, forfeits the balance and signs out all devices (not-installed eSIMs are cancelled, installed ones keep working until they expire).

## 4. Endpoint reference

### GET /v1/meta

Public. `{ minAppVersion, maintenance, supportedLocales: ["en","zh","ru","es","fr"], defaultLocale, contacts, supportEmail, legal: { terms, refund, acceptable_use, privacy, pre_purchase, esim_guide, in_app_texts }, legalDocuments: [{ key, slug, title, url }], serverTime }`. `legal` holds the public page URLs (`https://waysim.co/terms`, `…/refund`, `…/fair-use`, `…/privacy`, `…/pre-purchase`, `…/esim-guide`, `…/in-app-texts`); the in-app Settings → Legal section shows Terms of Service · Refund & Replacement Policy · Acceptable Use & Fair Use Policy · Privacy Policy; `legalDocuments` lists only the documents the admin has written, with titles in the request language (`?locale=` → `Accept-Language` → `en`) — show those in «Подробнее» and open `url` in the browser, or render the Markdown from `GET /v1/legal/:doc` in-app.

`contacts` = `{ website, email, telegram, instagram }`, each **ContactLink** `{ label, url }` or `null` when the admin left it empty (website and e-mail are always set):

```json
"contacts": {
  "website": { "label": "waysim.co", "url": "https://waysim.co" },
  "email": { "label": "support@waysim.co", "url": "mailto:support@waysim.co" },
  "telegram": { "label": "@waysim_support", "url": "https://t.me/waysim_support" },
  "instagram": null
}
```

Show `label`, open `url` (Telegram/Instagram links open the installed app). `supportEmail` is the same address as `contacts.email.label`, kept for older builds. `meta` is read at every app start, so a change in the admin shows up on the next start.

### GET /v1/legal

Public. The Waysim documents that have content, in the request language (`?locale=` → `Accept-Language` → `en`; texts exist in `en` and `ru`, every other language — or an empty Russian text — falls back to English with `fallback: true`). `{ locale, documents: [{ key, slug, title, updatedAt, locale, fallback }] }`. Keys → slugs in display order: `terms` → `terms`, `refund` → `refund`, `acceptable_use` → `fair-use`, `privacy` → `privacy`, `pre_purchase` → `pre-purchase`, `esim_guide` → `esim-guide`, `in_app_texts` → `in-app-texts`.

### GET /v1/legal/:doc

Public. `:doc` is a key or a slug. `{ key, slug, locale, fallback, title, body, updatedAt, availableLocales }` — `body` is Markdown (GFM: headings, lists, links, tables; no raw HTML). Texts exist in English and Russian; any other language gets English with `fallback: true`. Render tables (privacy, refund, FAQ and in-app texts have them) and bold lead-ins. `404 not_found` for unknown documents or one without English text. The old slug `acceptable-use` still resolves. The same texts are served as pages at `https://waysim.co/<locale>/<slug>` (`https://waysim.co/<slug>` redirects by language; the URLs in `meta.legal`).

### GET /v1/health

Public. Liveness + dependency status (`{ status: "ok", info: { database, redis, rabbitmq, memory_heap } }`).

### GET /v1/health/live

Public. `{ status: "ok" }` when the process is up.

### POST /v1/devices

Public. Registers or refreshes the install (idempotent by `installId`).

```json
{
  "installId": "uuid-kept-forever",
  "platform": "ios",
  "model": "iPhone 15",
  "osVersion": "18.0",
  "appVersion": "1.0.0 (12)",
  "locale": "ru-RU",
  "timezone": "Asia/Ashgabat",
  "isEmulator": false,
  "isRooted": false
}
```

→ `{ "device": Device, "deviceToken": "<jwt 30d>", "user": Me | null }`.

### PUT /v1/devices/me

Device. Updates `locale`, `appVersion`, `osVersion`, `model`, `timezone` → `Device`.

### PUT /v1/devices/me/push-token

Device. `{ "token": "<fcm token>" }` → `204`. The same token is removed from any other device.

### DELETE /v1/devices/me/push-token

Device. → `204`.

### POST /v1/auth/otp/request

Device. `{ "email": "anna@example.com", "adultConsent": true, "inviteCode": "A001248"? }` → `{ "resendAfterSeconds": 60, "ttlSeconds": 600 }`. Errors: `otp_cooldown` (429/400 with `retryAfterSeconds`), `invite_code_invalid` (422), `rate_limited`.

### POST /v1/auth/otp/verify

Device. `{ "email": "...", "code": "123456" }` → `{ "user": Me, "tokens": { "accessToken", "refreshToken", "accessExpiresIn": 3600 }, "isNewUser": true }`. Errors: `otp_invalid`, `otp_expired`, `otp_too_many_attempts`, `user_banned`.

### POST /v1/auth/refresh

Public. `{ "refreshToken": "..." }` → `{ "accessToken", "refreshToken", "accessExpiresIn" }` (new pair; the old refresh token is dead). `401 token_reused` → an already-rotated token was presented, the session is revoked; `401 session_revoked` → the session was signed out (another device, logout, ban). Either way: sign in again.

### POST /v1/auth/logout

User. `{ "refreshToken"? }` → `{ "deviceToken": "<fresh guest token>" }`; detaches the device and drops its push token from the user.

### GET /v1/me

User. → `Me`.

### PATCH /v1/me

User. `{ "name"?, "locale"?: "ru", "notifications"?: { "esim": true, "marketing": false, "support": true } }` → `Me`.

### GET /v1/me/devices

User. → `Device[]` of all signed-in devices (`current: true` marks this one).

### DELETE /v1/me/devices/:id

User. Signs out another device → `204` (`409 conflict` for this device — use logout). Its access token is refused from the next request on (`401 session_revoked`), its refresh token is dead, it gets a `signed_out` push and stays registered as a guest device.

### POST /v1/me/delete

User. `{ "confirm": true }` → `204`. Irreversible.

### GET /v1/catalog/home

Device. Home screen — banners uploaded in the admin, then localized destinations (countries alphabetically, regions by size):

```json
{
  "banners": [
    {
      "id": "01a1…",
      "imageUrl": "https://api.waysim.co/uploads/banners/01a1….png",
      "width": 1600,
      "height": 900,
      "link": "waysim://how-it-works"
    },
    {
      "id": "01a2…",
      "imageUrl": "https://api.waysim.co/uploads/banners/01a2….webp",
      "width": 1600,
      "height": 900,
      "link": "https://waysim.co/promo"
    }
  ],
  "local": [
    {
      "code": "TR",
      "name": "Турция",
      "fromCents": 99,
      "fromFormatted": "$0.99",
      "packagesCount": 30
    }
  ],
  "regional": [
    {
      "code": "eu-42",
      "name": "Европа",
      "countriesCount": 41,
      "fromCents": 249,
      "fromFormatted": "$2.49",
      "packagesCount": 12
    }
  ]
}
```

Banners: a swipeable carousel in display order (auto-advance every 5 s, pause on touch); hide the block when the array is empty. Each banner is one finished picture in the request language (`Accept-Language`; English when the admin uploaded none for it — PNG/JPEG/WebP, all texts already drawn into it, no overlay needed; refetch after the user switches the app language). The Home card is fixed at 16:9 and uses `BoxFit.cover`; upload 16:9 pictures to keep all text visible. `width` and `height` describe the source image but do not control the card size. `link` is what a tap opens: `waysim://…` → navigate in the app (same values as push deep links), `https://…` → open in the browser, `null` → not tappable. A banner leading to the referral screen is omitted while the referral program is disabled. Destinations are cached 60 s per language; banners are live.

### GET /v1/catalog/search

Device. `?q=tur` → `{ "countries": HomeLocation[], "regions": HomeLocation[] }`; matches every language, the supplier's English name and ISO codes, diacritics-insensitive.

### GET /v1/catalog/locations/:code

Device. `TR` or `eu-42` → `{ "location": { code, kind, name, countriesCount, countries: [{code,name}] }, "limited": PackageCard[], "unlimited": PackageCard[], "perDay": { "minDays": 1, "maxDays": 30 } }`.

### GET /v1/catalog/packages/:id

Device. By id or slug (`TR_1_7`) → `PackageDetail`.

### POST /v1/orders

User + `Idempotency-Key`. `{ "packageId": "<id|slug>", "days"?: 7 }` (`days` required for per-day plans, 1–30) → **202** `{ "order": Order, "pollAfterMs": 2000 }`; replay of the same key → **200**. Errors: `insufficient_balance` (402, `details.needCents`), `package_unavailable` (409), `validation`.

### GET /v1/orders

User. `?cursor&limit&kind=all|purchase|topup|grant` → `Page<Order>` newest first.

### GET /v1/orders/:id

User. → `Order`.

### GET /v1/esims

User. `?tab=current|archive&cursor` → `Page<EsimCard>`; `current` = not installed / installed / active / suspended.

### GET /v1/esims/:id

User. → `EsimDetail` (card + `install`, `device`, `topup`, `warnings`, `orders`).

### POST /v1/esims/:id/refresh

User. Pulls status and usage from the supplier → `EsimDetail` (`refreshThrottled: true` when called within 10 minutes of the previous refresh; never fails because of the supplier).

### GET /v1/esims/:id/topups

User. → `{ "options": PackageCard[], "reason": null | "status" | "limit" | "not_supported" }`.

### POST /v1/esims/:id/topups

User + `Idempotency-Key`. `{ "packageId": "TR_3_15" }` → **201** `{ order: Order(status: done), pollAfterMs }` or **202** when pending. Errors: `topup_unavailable` (409, `details.reason`), `topup_failed` (409, refunded), `insufficient_balance`.

### GET /v1/wallet

User. `{ balanceCents, balanceFormatted, limits: { minCents: 100, maxCents: 50000 }, methods: [ { provider, kind, title, enabled } ], pendingPayment: { id, provider, status, amountCents, amountFormatted, checkoutUrl, expiresAt } | null }` — `pendingPayment` is the latest `pending` top-up still before `expiresAt`, or a `confirming` one; open it with `GET /v1/payments/:id`.

### GET /v1/wallet/ledger

User. `?cursor&limit` → `Page<LedgerEntry>` (`kind`: purchase, topup, referral_bonus, refund, adjustment, reward, grant; `amountFormatted` is signed).

### GET /v1/payments/methods

User. → `PaymentMethod[]` (same as `wallet.methods`).

### GET /v1/payments/crypto/currencies

User. → `{ currencies: [CryptoCoin], coins: [{ coin, name, logoUrl, networks: [CryptoCoin] }], feePaidByUser: true }` where `CryptoCoin` = `{ code, coin, network, name, logoUrl, extraIdRequired, minCents, feeOnTop }` — coin + network pairs chosen in the admin and enabled at NOWPayments, in display order; `coins` groups them by coin for the coin → network pickers. `feeOnTop`: the fee is added on top of the amount (`crypto.feeCents`, stablecoins), otherwise it is inside the frozen rate. `minCents` is the smallest top-up for that coin — the processor's minimum, never below `wallet.limits.minCents` (null if unknown). `503 payment_provider_unavailable` when NOWPayments cannot be reached.

```json
{
  "currencies": [
    {
      "code": "usdtbsc",
      "coin": "USDT",
      "network": "BEP-20",
      "name": "Tether USD (BSC)",
      "logoUrl": "https://nowpayments.io/images/coins/usdtbsc.svg",
      "extraIdRequired": false,
      "minCents": 100,
      "feeOnTop": true
    },
    {
      "code": "usdttrc20",
      "coin": "USDT",
      "network": "TRC-20",
      "name": "Tether USD (Tron)",
      "logoUrl": "https://nowpayments.io/images/coins/usdttrc20.svg",
      "extraIdRequired": false,
      "minCents": 1194,
      "feeOnTop": true
    },
    {
      "code": "btc",
      "coin": "BTC",
      "network": "Bitcoin",
      "name": "Bitcoin",
      "logoUrl": "https://nowpayments.io/images/coins/btc.svg",
      "extraIdRequired": false,
      "minCents": 940,
      "feeOnTop": false
    }
  ],
  "coins": [
    {
      "coin": "USDT",
      "name": "Tether USD",
      "logoUrl": "https://nowpayments.io/images/coins/usdtbsc.svg",
      "networks": [
        {
          "code": "usdtbsc",
          "coin": "USDT",
          "network": "BEP-20",
          "name": "Tether USD (BSC)",
          "logoUrl": "https://nowpayments.io/images/coins/usdtbsc.svg",
          "extraIdRequired": false,
          "minCents": 100,
          "feeOnTop": true
        },
        {
          "code": "usdttrc20",
          "coin": "USDT",
          "network": "TRC-20",
          "name": "Tether USD (Tron)",
          "logoUrl": "https://nowpayments.io/images/coins/usdttrc20.svg",
          "extraIdRequired": false,
          "minCents": 1194,
          "feeOnTop": true
        }
      ]
    },
    {
      "coin": "BTC",
      "name": "Bitcoin",
      "logoUrl": "https://nowpayments.io/images/coins/btc.svg",
      "networks": [
        {
          "code": "btc",
          "coin": "BTC",
          "network": "Bitcoin",
          "name": "Bitcoin",
          "logoUrl": "https://nowpayments.io/images/coins/btc.svg",
          "extraIdRequired": false,
          "minCents": 940,
          "feeOnTop": false
        }
      ]
    }
  ],
  "feePaidByUser": true
}
```

### POST /v1/payments

User + `Idempotency-Key`. `{ "amountCents": 300, "provider": "crypto", "payCurrency": "usdtbsc" }` → **201** `Payment` (a replay with the same key → **200**). `provider` defaults to the first method (`crypto`); `payCurrency` is required for crypto. Errors: `payment_amount_out_of_range` (422, `details.minCents` — global limits or the coin's minimum), `validation` (`fields: ["payCurrency"]`), `payment_provider_unavailable` (503).

```json
{
  "id": "01a125bb-c253-7672-be0a-bd2fcb9113e1",
  "publicNo": 58012,
  "provider": "crypto",
  "status": "pending",
  "amountCents": 300,
  "amountFormatted": "$3.00",
  "creditedCents": null,
  "checkoutUrl": null,
  "returnUrl": "waysim://payment/01a125bb-c253-7672-be0a-bd2fcb9113e1",
  "crypto": {
    "payCurrency": "usdtbsc",
    "coin": "USDT",
    "network": "BEP-20",
    "payAddress": "0x5a566596a88488C168C031E9c25D0A79d69Ce989",
    "payExtraId": null,
    "payAmount": "3.04",
    "paidAmount": null,
    "rateUsd": "1",
    "qrValue": "0x5a566596a88488C168C031E9c25D0A79d69Ce989",
    "providerStatus": "waiting",
    "txid": null,
    "explorerUrl": null,
    "feePaidByUser": true,
    "feeCents": 4,
    "totalCents": 304
  },
  "expiresAt": "2026-10-10T12:04:40.494Z",
  "creditedAt": null,
  "createdAt": "2026-10-10T11:44:40.120Z"
}
```

### GET /v1/payments

User. `?cursor` → `Page<Payment>`.

### GET /v1/payments/:id

User. `:id` = uuid or payment number (`publicNo`) → `Payment` (`status`: pending, confirming, credited, review_underpaid, review_overpaid, review_late, expired, cancelled, refunded, disputed; `checkoutUrl` is `null` once finished). For an open crypto payment the backend pulls NOWPayments first (at most every 10 s), so poll this while the payment screen is visible. The order history can open this endpoint using its payment number to show requested and received amounts, network, fees, and review status.

### GET /v1/referral

User. → `{ code, link, enabled, bonusCents, bonusFormatted, accrual: "after_first_topup" | "after_first_purchase", rulesText, stats: { invited, pending, credited, earnedCents, earnedFormatted } }`.

### GET /v1/referral/invitations

User. `?cursor` → `Page<{ id, email (masked), status: pending|credited|rejected, bonusCents, registeredAt, creditedAt }>`.

### GET /v1/referral/codes/:code

Device. → `{ "valid": true, "code": "A001248" }` — validate before requesting the OTP.

### GET /v1/support/thread

User. → `{ id, status: open|closed, unread, lastMessageAt, messages: SupportMessage[] (last 50, oldest first), supportEmail, pollIntervalMs: 5000 }`.

### GET /v1/support/messages

User. `?after=<messageId>&limit=50` → `{ items: SupportMessage[], nextAfter, unread, status }` — only messages newer than `after` (ids are time-ordered).

### POST /v1/support/messages

User. `{ "text": "…" }` (1–2000 chars, 20 per 10 min) → **201** `SupportMessage`. A closed thread reopens.

### POST /v1/support/read

User. `{ "upToMessageId"?: "…" }` → `{ "unread": 0 }`.

### POST /v1/notifications/opened

Device. `{ "deliveryId"?: "…", "broadcastId"?: "…" }` → `{ "ok": true }` — call when a push is tapped.

## 5. Data types

**Me** `{ id: "A001248", email, name, status: active|guest|banned, balanceCents, balanceFormatted, locale, notifications: { esim, marketing, support }, support: { unread }, referral: { code, link }, createdAt }`

**Device** `{ id, platform, model, osVersion, appVersion, locale, lastSeenAt, current, hasPushToken }`

**HomeLocation** `{ code, name, fromCents, fromFormatted, packagesCount, countriesCount? }`

**Banner** `{ id, imageUrl, width, height, link: string | null }` — one ready-made picture in the request language; `link` is a `waysim://` deep link, an `https://` URL or null.

**PackageCard** `{ id, slug, name, dataGb | null, dataBytes | null, unlimited, perDay, days | null, priceCents, priceFormatted, direction: { kind: country|region, code, name }, coverageCount, topUpAllowed }` — for per-day plans the price is per day.

**PackageDetail** = PackageCard + `{ details (localized text), coverage: [{ code, name }], network, speed, hotspot, activationRule: first_connection|install, installWithinDays, requiresIdentity, topUpAllowed, perDayOptions: { minDays, maxDays } | null }`

**Order** `{ id, publicNo, kind: purchase|topup|grant, status: pending|processing|done|failed_refunded, title, slug, amountCents, amountFormatted, esimId | null, failedReason | null, createdAt, doneAt }`

**EsimCard** `{ id, title, status, usage: { usedBytes, totalBytes | null, remainingBytes | null, updatedAt }, daysLeft | null, expiresAt | null, installBefore | null, activationRule, deviceLabel | null, lastSyncedAt, package: { id, slug, directionKind, locationCode }, createdAt }`

**EsimDetail** = EsimCard + `{ install: { iccid, smdpAddress, activationCode, lpaString, qrCodeUrl, appleUniversalLink }, device: { eid, installedAt }, topup: { allowed, count, max: 9 }, warnings: ["keep_installed", "install_same_device", "disable_home_roaming"], orders: Order[], refreshThrottled? }`

**LedgerEntry** `{ id, kind, amountCents, amountFormatted, balanceAfterCents, title, note, refType, refId, createdAt }`

**Payment** `{ id, publicNo, provider, status, amountCents, amountFormatted, creditedCents, checkoutUrl | null, returnUrl, crypto: CryptoPayment | null, expiresAt, creditedAt, createdAt }`

**CryptoPayment** `{ payCurrency, coin, network, payAddress, payExtraId | null, payAmount, paidAmount | null, rateUsd | null, qrValue, providerStatus | null, txid | null, explorerUrl | null, feePaidByUser, feeCents | null, totalCents | null }` — amounts are decimal strings; `feeCents`/`totalCents` are set for stablecoins (fee added on top of `amountCents`); `providerStatus` is NOWPayments' own (`waiting`, `confirming`, `confirmed`, `sending`, `partially_paid`, `finished`, `failed`, `expired`), show `status` to the user.

**SupportMessage** `{ id, sender: user|staff, staffName | null, text, createdAt }`

## 6. Enums

- eSIM status: `not_installed`, `installed`, `active`, `used_up`, `expired`, `suspended`, `cancelled`, `revoked`, `failed`
- Order status: `pending`, `processing`, `done`, `failed_refunded`; `failedReason`: `supplier_balance`, `price_mismatch`, `allocation_timeout`, `max_attempts`, `package_missing`, `supplier_<code>`, `topup_*`
- Payment status: `pending`, `confirming`, `credited`, `review_underpaid`, `review_overpaid`, `review_late`, `expired`, `cancelled`, `refunded`, `disputed`
- Referral status: `pending`, `credited`, `rejected`
- Content locales: `en`, `zh`, `ru`, `es`, `fr`

## 7. Dev & testing aids (`DEV_ENDPOINTS_ENABLED=true` only)

- OTP is always `123456` in dev (`OTP_DEV_FIXED_CODE`); e-mails land in Mailpit.
- Postman: import `docs/postman/waysim-client-api.postman_collection.json` and the `waysim-local` environment (see `docs/postman/README.md`); the Collection Runner can replay the whole flow (device → OTP → catalog → top-up → order → eSIM → support).
- There is no way to add balance without paying: top up with crypto, or an admin adjusts the balance in the dashboard (user card → «Баланс», audited).
- `POST /v1/dev/fake-supplier/esims/:tranNo/state { esimStatus?, smdpStatus?, orderUsage?, eid? }` — simulate the supplier (`IN_USE` + `ENABLED` activates the eSIM; `orderUsage` emits a usage update).
- `POST /v1/dev/catalog/sync`, `POST /v1/dev/packages/publish { slugs }` — pull the catalog from the eSIM Access API into the database and publish products by slug.
- Fake supplier: orders allocate after ~3 s; slugs listed in `FAKE_SUPPLIER_FAIL_SLUGS` fail (refund), `FAKE_SUPPLIER_TIMEOUT_SLUGS` never allocate (refund after the deadline).

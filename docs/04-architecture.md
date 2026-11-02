# 04 — Flutter mimarisi

Mimari, **elyeter** projesinden (`/Users/dadebay/Developer/apps/projects/elyeter`, bkz. onun `ARCHITECTURE.md`) alınmıştır:
feature-first, katmanlı, **BLoC/Cubit**. Amaç: aynı alışkanlıkları ve çalışan, test edilmiş çekirdeği yeniden kullanmak.

## Elyeter'den ne alındı / alınmadı

| Alınan | Waysim'deki karşılığı |
| --- | --- |
| State management: `bloc`, `flutter_bloc`, `equatable`, `hydrated_bloc` | Aynı. Tema + dil `HydratedCubit` (kalıcı). Özellik durumu `Cubit`/`Bloc`. |
| DI: `get_it` (`core/di/injector.dart`, her feature için `_registerX()`) | Aynı |
| Router: `go_router` | Aynı + `StatefulShellRoute` (3 sekme) + deep link |
| Network: `dio` + `ApiClient` (envelope açar, `AppException` fırlatır) + interceptor'lar | Aynı; `AuthInterceptor` **refresh token** akışına uyarlanır; `LanguageInterceptor` 5 dile |
| Hata: `Result<T>` (Success/Error), `Failure`, `AppException` → `toFailure()` | Aynı; `ApiCodes` Waysim hata kodlarıyla değişir |
| Depolama: `LocalStorage` (shared_preferences), `SecureStorage` (flutter_secure_storage) | Aynı (secure'a access+refresh token) |
| `AppLogger`, `AppBlocObserver`, `ApiLogInterceptor` (renkli log, prod'da sessiz) | Aynı |
| `NetworkInfo` (connectivity_plus) | Aynı → offline bandı |
| İkon: `hugeicons` + `AppIcons` (anlama göre adlandırılmış sabitler) | Aynı yaklaşım, Waysim ikon seti |
| UI paketleri: `flutter_svg`, `shimmer`, `cached_network_image`, `url_launcher`, `share_plus` | Aynı |
| Test: `bloc_test`, `mocktail`, `flutter_lints` + elyeter lint kuralları | Aynı |
| Flavor: `--dart-define=FLAVOR/API_BASE_URL` (`AppEnvironment`) | Aynı (dev/staging/prod) |
| l10n: `flutter gen-l10n`, ARB, `context.l10n` | Aynı; **5 dil** |

**Alınmadı:** `camera`/`image_picker`/`image` (görsel arama, avatar), e-ticaret feature'ları (cart/product/brand…), TMT para birimi, InterDisplay/Qurova
fontları (Waysim **Gilroy** kullanıyor — dosyalar elyeter'de değil, proje sahibinin `Salon` projesinden alındı), yüzen kapsül nav bar, ürün/kategori görselleri, `LanguageInterceptor`'daki tk/ru kısıtı.

## Yeni eklenenler (TZ'ye göre)

| Paket | Neden |
| --- | --- |
| `qr_flutter` | eSIM QR kodu, kripto ödeme QR'ı |
| `device_info_plus` | iOS model → eSIM uyumluluğu; "Мои устройства" cihaz modeli |
| `package_info_plus` | "О приложении" sürüm |
| `uuid` | idempotency key (sipariş/yükleme) |
| `firebase_core`, `firebase_messaging`, `firebase_crashlytics`, `firebase_app_check`, `flutter_local_notifications` | Push, hata raporu, App Attest/Play Integrity — **müşterinin Firebase projesi gelince** (T7.x) |
| root/jailbreak tespiti (`freerasp` veya benzeri) | Referral bonus kısıtı + uyarı (T6.x) |
| `flutter_native_splash` | Marka splash'ı (brand paketindeki splash PNG'leri) |

## Katmanlar ve kurallar

```
presentation (bloc/cubit, view, widgets)  →  domain (entity, abstract repository)  ←  data (datasource, model, repository impl)
```

1. **Bağımlılık içe doğru.** Bloc, Dio'yu veya model'i bilmez; `domain/repositories` arayüzüne konuşur.
2. **Hatalar tipli.** Data source `AppException` fırlatır, repository yakalayıp `Result<T>` döner; bloc exception görmez.
3. **Bloc'ta metin yok.** State `Failure` taşır; widget `failure.localize(context.l10n)` ile çevirir.
4. **Widget'ta ham renk/boyut/string yok.** `context.colors`, `AppSpacing`, `AppRadius`, `context.l10n`.
5. **Tek kayıt noktası:** `core/di/injector.dart`.
6. **Para = cent (int).** `Money` value object + `MoneyFormatter`.
7. **Backend yokken mock:** her repository arayüzünün `Mock…Repository` implementasyonu (bellekte durum tutar) vardır; `AppEnvironment.useMockApi`
   (`--dart-define=USE_MOCK_API=true`) ile DI'da değişir. Böylece tüm ekranlar API gelmeden çalışır/testlenir.
8. **TZ'deki "freezed + json_serializable"** yerine elyeter tarzı elle `fromJson` + `equatable` kullanılır (codegen yok). Backend OpenAPI
   spec'i gelince Dart client üretimi değerlendirilir (T9.x).

## Klasör yapısı

```
lib/
├─ main.dart                      # bootstrap(App.new)
├─ bootstrap.dart                 # hydrated storage, DI, hata kancaları
├─ app/
│  ├─ app.dart                    # MaterialApp.router + global provider'lar
│  ├─ cubit/                      # theme_cubit, locale_cubit (kalıcı)
│  ├─ router/                     # app_router.dart, app_routes.dart
│  └─ view/                       # home_shell.dart (3 sekme + destek FAB), widgets/app_tab_bar.dart
├─ core/
│  ├─ bloc/  constants/  di/  error/  localization/  network/  storage/
│  ├─ theme/                      # app_colors, app_color_tokens (ThemeExtension), app_typography, app_spacing, app_theme
│  ├─ utils/                      # result, app_logger, formatters (money, date, bytes), extensions
│  └─ widgets/                    # AppButton, AppTextField, OtpField, StatusBadge, AppBottomSheet, AppToast, Skeleton, EmptyState…
├─ features/
│  ├─ auth/        # e-posta OTP, oturum, refresh token
│  ├─ catalog/     # ülkeler, bölgeler, paketler, arama, son aramalar
│  ├─ purchase/    # uyumluluk, onay, sipariş durumu
│  ├─ esim/        # Мои eSIM, kart, QR, kurulum, kullanım, top-up
│  ├─ wallet/      # bakiye, yükleme (PayPal/kripto), siparişler
│  ├─ referral/
│  ├─ support/     # destek sheet'i, AI chat
│  ├─ profile/     # profil, ayarlar, cihazlar, hesap silme
│  ├─ legal/       # belgeler, hakkında, lisanslar
│  ├─ notification/# push izni + yönlendirme
│  └─ onboarding/  # (ilk açılış: guest ID, remote config)
└─ l10n/                          # arb/app_{en,zh,ru,es,fr}.arb + üretilen AppLocalizations
```

Her feature içinde: `data/{datasources,models,repositories}`, `domain/{entities,repositories}`, `presentation/{bloc|cubit,view,widgets}`.

## Tema ve yerelleştirme

- `AppColorTokens extends ThemeExtension` (renkler [02](02-design-system.md)'deki gibi); `AppTheme.light/dark`; `context.colors` → token'lar.
- `ThemeCubit` varsayılan **`ThemeMode.light`** (TZ), seçenekler: Светлая / Тёмная (tasarım ayarlar ekranı). Kalıcı.
- `LocaleCubit` varsayılan **`en`**; `en, zh, ru, es, fr`. Sistem dili desteklenen listedeyse ilk açılışta o seçilmez — **İngilizce varsayılan** (istek).
  Dil değişince `Content-Language` / `Accept-Language` ve push dili güncellenir (backend'e `PATCH /v1/me {language}`).
- Çince için CJK font fallback; sayı/para biçimi `intl` ile locale'e göre, ama para her zaman **USD ($)**.

## Test stratejisi (TZ §8)

- Unit: `Money`, bayt formatlayıcı, durum eşleme, idempotency key üretimi, `Result`/`Failure`.
- Bloc: `bloc_test` + `mocktail` (auth OTP akışı, satın alma, bakiye yükleme polling).
- Widget: bileşen kütüphanesi (açık/koyu, 5 dil taşma), kritik ekranlar. `integration_test`: giriş → satın alma → eSIM kartı (mock API).
- Statik: `flutter analyze` sıfır uyarı (elyeter lint seti).

## Komutlar

```bash
flutter pub get
flutter gen-l10n
flutter run --dart-define=FLAVOR=dev --dart-define=USE_MOCK_API=true
flutter analyze && flutter test
# release
flutter build ipa --obfuscate --split-debug-info=build/symbols --dart-define=FLAVOR=prod --dart-define=API_BASE_URL=https://api.waysim.co
```

# 05 — iOS / Android'e özel gereksinimler

Kimlikler (onay bekliyor, bkz. [07](07-open-questions.md)): **`com.waysim.app`** (iOS bundle ID + Android applicationId), URL şeması `waysim://`, domain `waysim.co`.
✅ = şablonda hazır/yapıldı, ⬜ = yapılacak.

## Ortak

- ⬜ Marka ikonları: iOS `AppIcon.appiconset`, Android `mipmap-*` (ic_launcher, round, foreground, **monochrome**), bildirim ikonu `ic_stat_waysim`, `waysim_colors.xml` — hepsi `design/brand` paketinin `flutter/` klasöründe hazır (T0.5).
- ⬜ Splash: `flutter_native_splash` (açık `splash_logo.png`, koyu `splash_logo_dark.png`, Android 12 `android12_splash(.dark).png`, arka plan açık `#FFFFFF` / koyu `#0E121A`).
- ⬜ Uygulama adı: **Waysim** (`CFBundleDisplayName`, `android:label`).
- ✅ Yalnızca dikey yön ve iPhone hedefi. iPad desteği ilk sürümde kapalı — Xcode `TARGETED_DEVICE_FAMILY = 1`.
- ⬜ Tüm metinler yerelleştirilmiş: iOS `CFBundleLocalizations` (en, zh-Hans, ru, es, fr) + `InfoPlist.strings`; Android `res/xml/locales_config.xml` + `android:localeConfig` (uygulama içi dil).

## iOS

| Konu | Yapılacak |
| --- | --- |
| Min iOS | Runner hedefinde **15.6** |
| **Associated Domains** | `applinks:waysim.co` entitlement'ı hazır. Davet ve ödeme dönüşü için [AASA dosyası](../deployment/waysim.co/.well-known/apple-app-site-association) `https://waysim.co/.well-known/apple-app-site-association` adresinde yayınlanmalı; 24 Ekim 2026'da 404 dönüyordu. |
| URL şeması | `CFBundleURLTypes` → `waysim` |
| **Push** | Capabilities: Push Notifications + Background Modes (`remote-notification`); APNs key'i Firebase'e yükle; izin **ilk satın almadan sonra** (`requestPermission`) |
| **App Attest** | Firebase App Check için `com.apple.developer.devicecheck.appattest-environment` entitlement |
| **eSIM tek dokunuş kurulum** | iOS 17.4+: `https://esimsetup.apple.com/esim_qrcode_provisioning?carddata=LPA:1$<SM-DP+>$<kod>` URL'ini `url_launcher` ile (harici uygulama modunda) aç. Eski sürümlerde QR/manuel. **Doğrula:** gerçek cihazda (simulator desteklemez) |
| eSIM uyumluluğu | `device_info_plus` → `utsname.machine` (ör. `iPhone14,5`) ↔ sunucudaki uyumlu model listesi |
| `LSApplicationQueriesSchemes` | `mailto`, `https`, `tel` (`canLaunchUrl` için) |
| Ödeme dönüşü | PayPal: `SFSafariViewController` (`url_launcher` `LaunchMode.inAppBrowserView`) → dönüş `https://waysim.co/pay/return` universal link |
| Hesap silme | Uygulama içinden mümkün olmalı (App Store 5.1.1(v)) — profilde var, kodla onaylı |
| Gizlilik | Runner `PrivacyInfo.xcprivacy` derlemeye giriyor; paketlerin kendi manifest'leri ayrıca mevcut. App Store Connect gizlilik yanıtları gerçek veri akışıyla eşleştirilmeli. |
| **Mağaza riski** | Dijital içerik değil **hizmet/eSIM** satışı + dahili bakiye: Apple 3.1.1/3.1.3 ve kripto kuralları **ödeme geliştirmesinden önce** kontrol edilmeli |
| Jailbreak | tespit → uyarı, referral bonusu yok |

## Android

| Konu | Yapılacak |
| --- | --- |
| minSdk | Flutter varsayılanı (**24** önerilir; `EuiccManager` API 28+ — eski sürümde "Нет/Не определено") |
| `INTERNET` | Manifest (release'te zorunlu; debug'da şablon ekler) |
| **POST_NOTIFICATIONS** | Android 13+ çalışma zamanı izni; ilk satın almadan sonra iste. Bildirim kanalı `waysim_default`, ikon `ic_stat_waysim`, renk `waysim_primary` |
| **App Links** | `<intent-filter android:autoVerify="true">` host `waysim.co` (`/r/`, `/pay/return`) + `waysim://`. Sunucu: `https://waysim.co/.well-known/assetlinks.json` (**release SHA-256** parmak izi) |
| **eSIM uyumluluğu** | Kotlin `MethodChannel` → `EuiccManager.isEnabled` (`getSystemService(Context.EUICC_SERVICE)`); `<uses-feature android:name="android.hardware.telephony.euicc" android:required="false"/>` (cihazı **eleme**) |
| eSIM kurulumu (Android) | QR veya manuel SM-DP+ + aktivasyon kodu girişi (Ayarlar → Ağ → SIM → eSIM ekle). Resmi tek-dokunuş intent'i (`EuiccManager.ACTION_START_EUICC_ACTIVATION` benzeri) **araştırılacak/doğrulanacak** — varsayım yapılmadı |
| Play Integrity | Firebase App Check (Play Integrity sağlayıcısı); `google-services.json` müşteri projesinden |
| Ödeme dönüşü | PayPal: Chrome Custom Tabs (`url_launcher`) → App Link ile dönüş |
| `<queries>` | `mailto`, `https` için (Android 11+ paket görünürlüğü) |
| R8/Obfuscation | `--obfuscate --split-debug-info`; Crashlytics symbol upload; ProGuard kuralları (Flutter/Firebase varsayılanları yeterli) |
| İmzalama | Upload keystore + Play App Signing; `key.properties` repoda **yok** (`.gitignore`) |
| Root | tespit → uyarı, referral bonusu yok |
| Data Safety formu | e-posta, cihaz ID, satın alma geçmişi, çökme günlükleri |

## Mağaza çıktıları (hazır olanlar `design/brand/store`)

- App Store: ikon 1024 ✅; ekran görüntüleri (6.7", 6.1") ⬜; açıklama (5 dil) ⬜; gizlilik URL'i, destek URL'i ⬜; **hesap silme** + inceleme için demo hesabı ⬜.
- Google Play: ikon 512 ✅, feature graphic 1024×500 ✅; ekran görüntüleri ⬜; Data Safety ⬜; iç test kanalı ⬜.
- TestFlight / Play iç testi: ilk dağıtım hedefi (CI/CD: GitHub Actions veya Codemagic).

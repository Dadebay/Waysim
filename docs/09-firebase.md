# 09 — Firebase: push, analytics, çökme raporları

Proje: **waysim** (`flutterfire configure` ile bağlandı; Android + iOS `com.waysim.app`). Her şey `FirebaseSetup.ready` bayrağına bağlı:
Firebase başlamazsa (yapılandırma yok, Play Hizmetleri yok, `--dart-define=FIREBASE=false`) uygulama yine açılır, bu servisler boşa düşer.

## Push (FCM / APNs)

Kod: `lib/core/services/fcm_push_service.dart`, `local_notifications_service.dart`, `push_router.dart` (aykitap ve elyeter'deki çalışan tarif).

| Durum | Bildirimi kim çizer |
| --- | --- |
| Uygulama **kapalı / arka planda** | Sistem (mesajın `notification` bloğundan). Android'de ikon `ic_stat_waysim`, renk `waysim_primary`, kanal `waysim_default` (manifest `meta-data`) |
| Uygulama **açık, Android** | `onMessage` → `flutter_local_notifications` ile elle |
| Uygulama **açık, iOS** | Firebase (`setForegroundNotificationPresentationOptions`) |
| Veri-only mesaj, uygulama kapalı | `_backgroundHandler` (kendi isolate'ı, Firebase'i kendisi başlatır) |

- **Topic: `waysim`** — herkes (ve "Haberler ve teklifler" anahtarı açıkken) bu topic'e abone olur; admin duyuruları buraya gider.
  Ayarlardan anahtar kapatılınca `unsubscribeFromTopic`. Kişisel olaylar (eSIM hazır, ≤100 MB, 1 gün kaldı…) cihaz token'ına gider;
  token `AuthRepository.registerPushToken` ile backend'e verilir (uç provizyoneldir, T7.1).
- **Bildirime dokunma**: uygulama kapalıyken (`getInitialMessage`), arka plandayken (`onMessageOpenedApp`) ve açıkken çizilen
  banner'da (yerel bildirim payload'ı) aynı akışa düşer → `PushRouter` yalnızca bilinen türleri açar; kimlikler doğrulanır.
- **İzin**: release'te ilk satın almadan sonra tek sefer (`PushPermissionGate`, ürün kuralı). **Debug build'lerde açılışta istenir**,
  böylece satın almadan test edilebilir. Hemen her kullanıcıya sormak isterseniz `FcmPushService.init` içindeki `kDebugMode` koşulunu kaldırın.
- **iOS**: `ios/Runner/Runner.entitlements` (`aps-environment`), `UIBackgroundModes → remote-notification`.
  ⚠️ Push yeteneği **ücretli Apple Developer takımı** ister; "Personal Team" ile imzalama hata verir — o durumda geçici olarak
  `CODE_SIGN_ENTITLEMENTS` satırlarını `project.pbxproj`'dan kaldırın. Firebase konsolunda *Project settings → Cloud Messaging →
  APNs Authentication Key* yüklenmeli (yoksa iOS'a hiçbir şey gelmez). Simülatör APNs almaz; gerçek cihazda deneyin.
- **Test**: debug build'de konsola FCM token'ı yazdırılır. Firebase konsolu → *Messaging → New campaign → Test message* ile token'a,
  ya da kampanyada **Topic = waysim** seçerek herkese gönderin.

## Analytics

Kod: `analytics_service.dart` (arayüz + olay adları), `firebase_services.dart` (`FirebaseAnalyticsService`).

| Soru | Nereden bakılır |
| --- | --- |
| **Kullanıcılar nereden giriyor?** | Firebase otomatik toplar: *Acquisition* raporu (Play yükleme kaynağı, kampanya bağlantıları). Davet bağlantısı ayrıca `invite_link_opened` olayı + `acquisition=invite` kullanıcı özelliği |
| **Kim ne satın alıyor?** | `view_item_list` (ülke/bölge açıldı) → `select_item` → `view_item` (detay) → `begin_checkout` → **`purchase`** (`value` $ cinsinden, `item_id` = paket slug, `item_category` = ülke, `transaction_id` = eSIM). Başarısızlık: `purchase_failed` (`reason`). Bakiye: `top_up_started` / `top_up_credited` |
| **Uygulamada ne kadar kalıyor?** | Otomatik: `session_start`, `user_engagement` (*Engagement time*), ortalama oturum süresi; `screen_view` ile hangi ekranlarda gezildiği |
| Diğer | `search` (`search_term`, `results`), `sign_up` / `login`, `esim_install_started` (`one_tap`/`qr`), `share` (referral), `setting_changed` |

Kullanıcı kimliği: yalnızca public ID (`A0123`); e-posta **asla** gönderilmez. Kullanıcı özellikleri: `language`, `theme`, `account`
(guest/signed_in), `news_push`, `acquisition`, `build=debug` (debug oturumlarını raporlardan ayıklamak için).
Canlı doğrulama: konsol → *DebugView* (Android: `adb shell setprop debug.firebase.analytics.app com.waysim.app`; iOS: Xcode argümanı `-FIRAnalyticsDebugEnabled`).
Gizlilik: mağaza formlarına "Analytics (kullanım verisi)" ve "Çökme verisi" eklendi (docs/08).

## Çökme raporları

Her yakalanmamış hata (`FlutterError.onError`, `PlatformDispatcher.onError`) `CompositeCrashReporter`'a gider:
1. **Crashlytics** (release'te açık, debug'da kapalı);
2. **Firestore `crash_reports`** — bu kullanıcı, bu telefonda, bu hatayı verdi:

| Alan | Örnek |
| --- | --- |
| `publicId` | `A0123` (misafirde de var) |
| `platform`, `osVersion`, `deviceModel` | `ios`, `iOS 18.2`, `iPhone16,2` |
| `appVersion`, `buildNumber`, `flavor`, `locale` | `1.0.0`, `7`, `prod`, `en-US` |
| `screen` | son gösterilen ekran (router adı, ör. `destination`) |
| `error`, `stack` | kırpılmış (1500 / 4000 karakter) |
| `fatal`, `status` (`new`), `createdAt` (sunucu saati) | |

Aynı çökme bir çalışmada bir kez yazılır, bir çalışma en çok 20 kayıt yazar; çevrimdışıyken Firestore yazmayı kuyruğa alır.
E-posta, ad, token, ödeme bilgisi **yazılmaz**.

### Konsolda yapılacaklar (bir kez)

1. *Firestore Database → Create database* (production mode).
2. *Rules* sekmesine yapıştırın — istemci yalnızca **ekleyebilir**, hiç kimse uygulamadan okuyamaz (raporları konsoldan/Admin SDK ile okursunuz):

```
rules_version = '2';
service cloud.firestore {
  match /databases/{db}/documents {
    match /crash_reports/{id} {
      allow create: if request.resource.data.keys().hasOnly([
          'error','stack','fatal','screen','publicId','platform','osVersion',
          'deviceModel','appVersion','buildNumber','locale','flavor',
          'createdAt','status'])
        && request.resource.data.error is string
        && request.resource.data.error.size() <= 1600
        && request.resource.data.stack is string
        && request.resource.data.stack.size() <= 4100
        && request.resource.data.createdAt == request.time;
      allow read, update, delete: if false;
    }
    match /{document=**} { allow read, write: if false; }
  }
}
```
3. *App Check → Apps*: Android için Play Integrity, iOS için App Attest'i kaydedin; debug build'in yazdırdığı **debug token**'ı *Manage debug tokens*'a ekleyin. Zorlamayı (enforce) Firestore ve backend hazır olunca açın.
4. *Cloud Messaging*: APNs anahtarını yükleyin. *Analytics*: veri akışlarının açık olduğunu doğrulayın.
5. (Release) iOS'ta Crashlytics dSYM yükleme betiği ve Android'de Crashlytics Gradle eklentisi, **obfuscate** edilmiş yığınları çözmek için eklenmeli (T7.2).

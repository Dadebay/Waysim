# 10 — Güvenlik denetimi ve sertleştirme

Kod tabanı elle okunarak denetlendi (ağ, depolama, kimlik, deep link, URL açma, Firebase, native ayarlar,
bağımlılıklar). Tasarım ve akışlar **değişmedi**. Başlangıç: `flutter analyze` temiz, 218 test yeşil;
bitiş: 227 test yeşil.

## Kapatılan açıklar

| # | Bulgu | Düzeltme |
| --- | --- | --- |
| 1 | Release derlemesi `FLAVOR=prod` verilmeden alınırsa istek/yanıt ve bloc durumları (e-posta, eSIM durumu) cihaz log'una yazılıyordu | `AppEnvironment.enableLogging` artık release'te her zaman kapalı |
| 2 | `USE_MOCK_API=true` ile release alınırsa sabit demo kodlu sahte backend mağaza sürümüne girebilirdi | `useMockApi` release'te her zaman `false` |
| 3 | `API_BASE_URL` düz `http://` olabilirdi (token + OTP açık metin) | Release'te `https://` zorunlu (`ensureSecureApiBaseUrl`, açılışta) |
| 4 | `AuthInterceptor` Bearer token'ı, mutlak URL'li her isteğe eklerdi | Token yalnız `baseUrl` ile aynı host'a gider |
| 5 | Sunucudan gelen bağlantılar (ödeme sayfası, mağaza sayfası, eSIM kurulum linki) doğrulanmadan açılıyordu | `safeHttpsUri` / `safeHttpsUriOn`: yalnız `https`, host dolu, kullanıcı bilgisi yok; eSIM linki yalnız `esimsetup.apple.com`, aksi halde LPA'dan yeniden üretilir |
| 6 | `/gallery` (tasarım galerisi) release'te deep link ile açılabiliyordu | Rota yalnız release dışı derlemelerde kayıtlı |
| 7 | Çökme raporlarına (Firestore) hata metniyle e-posta, Bearer/JWT, LPA, `code=`/`token=` sızabilirdi | `scrubSensitive` raporu yazmadan önce temizler |
| 8 | Firestore kuralları: yalnız birkaç alan sınırlıydı; `publicId`, `osVersion`… sınırsız, `fatal`/`status` tipsiz | Tüm alanlar tipli ve boyut sınırlı, `status == 'new'`, `fatal` bool |
| 9 | Android: otomatik yedekleme açıktı (token/tercih dosyaları buluta gidebilir) | `allowBackup="false"`, `usesCleartextTraffic="false"` |
| 10 | Android release, debug anahtarıyla imzalanıyordu | `android/key.properties` varsa upload anahtarıyla imzalar (dosya `.gitignore`'da); yoksa yerel `--release` için debug'a düşer |
| 11 | iOS Keychain `first_unlock`: yedekten başka telefona token taşınabilir | `first_unlock_this_device` |
| 12 | Root/jailbreak tespiti okunuyordu ama arayüz hiç tetiklenmiyordu (`NoopDeviceIntegrity`) | `DeviceContextIntegrity`: uyarı ve gizlenen davet alanı artık gerçekten çalışır |

## Temizlik

- Kullanılmayan paketler kaldırıldı: `cupertino_icons`, `bloc_test`, `mocktail` (lock dosyasından ~25 geçişli paket de çıktı).
- Kullanılmayan kod: `Paginated`, `doubleOrNull`, `NoopDeviceIntegrity`, 6 kullanılmayan `AppConstants`,
  `StorageKeys.notifyNews`, 2 kullanılmayan API kodu, 5 kullanılmayan ARB metni (5 dilde).
- 8 dosya `dart format` ile uyumsuzdu (CI'ı kırardı); biçimlendirildi.
- `android/build/reports/problems/problems-report.html` git'ten çıkarılacak derleme çıktısıydı; silindi.

## Elle yapılması gerekenler (kod dışı)

1. **Firestore kurallarını yayınla:** `firebase deploy --only firestore:rules`. Emülatörde bir çökme ve bir yavaş-kare
   raporu yazarak kabul edildiğini doğrula (kurallar bu denetimde cihazda denenmedi).
2. **App Check'i zorunlu kıl:** Firebase konsolu → App Check → Cloud Firestore → Enforce. Kurallar `request.auth`
   istemediği için sahte istemcileri ancak App Check keser.
3. **API anahtarlarını kısıtla:** Google Cloud → Credentials; `google-services.json` / `GoogleService-Info.plist` /
   `firebase_options.dart` içindeki anahtarları paket adı (`com.waysim.app`) + SHA-1 / bundle id ile sınırla.
   Bu anahtarlar gizli değildir ama kısıtsız bırakılırsa kötüye kullanılır.
4. **Android upload anahtarı:** `android/key.properties` oluştur (`storeFile`, `storePassword`, `keyAlias`, `keyPassword`).
   Anahtarı git dışında yedekle.
5. **Release komutu:** `flutter build ipa|appbundle --release --obfuscate --split-debug-info=build/symbols --dart-define=FLAVOR=prod`.

## Sonraya bırakılanlar (öneri)

- **Sertifika sabitleme (pinning):** gerçek `api.waysim.co` sertifika/SPKI özetleri backend'den gelince. Dio'nun
  `validateCertificate` kancası yanıt geldikten *sonra* çalıştığı için yetersiz; bağlantı kurulurken doğrulayan
  `SecurityContext` / `HttpClient` tabanlı çözüm gerekir. Yedek pin ve rotasyon planı şart (yanlış pin = uygulama çalışmaz).
- **FreeRASP / Play Integrity sunucu doğrulaması:** root tespiti şimdilik tek paketin cevabına dayanır; App Check
  token'ının backend'de doğrulanması (T6.1) asıl koruma.
- **Ekran koruması:** eSIM QR/aktivasyon kodu ekranı için iOS uygulama değiştirici bulanıklaştırması. Android'de
  `FLAG_SECURE` bilinçli olarak konmadı: müşteri QR'ı başka telefona göndermek için ekran görüntüsü alabilir.
- **Mock kod release paketinde:** `MockBackend` ve `DemoCredentials` derlemeye giriyor (çalışmıyor, ama boyut/ayak izi).
  İleride `mock/` ayrı bir giriş noktasına (`main_mock.dart`) taşınabilir.
- **CI:** `flutter pub outdated` + `dart pub deps` ile düzenli bağımlılık taraması ve gizli anahtar taraması (gitleaks) eklenebilir (T7.2).
- **Sunucu tarafı (backend):** OTP deneme sınırı/kilit, `/v1/auth/*` rate limit, refresh token yeniden kullanım
  tespiti, `Idempotency-Key` doğrulaması ve ödeme webhook imzası bu repoda yoktur; pentest kapsamına alınmalı (T7.4).

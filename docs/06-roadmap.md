# 06 — Yol haritası (adım adım görevler)

Durum: `[x]` bitti · `[ ]` yapılacak · `[~]` kısmen / müşteri girdisi bekliyor. Görevler sırayla; her faz sonunda `flutter analyze` + `flutter test` yeşil olmalı.
TZ'nin 8 aşamasıyla (0–7) eşleşme parantez içinde. Mobil için "gerçek API" aşamasına kadar her şey **mock data source** ile çalışır.

## İlerleme

Sayaç: `dart run tool/roadmap_status.dart` (aşağıdaki onay kutularını okur).

**Son durum:** bkz. `dart run tool/roadmap_status.dart`. Kalanların çoğu dış girdi bekliyor
(Firebase, Apple/Google hesapları, gerçek backend) — bkz. en alttaki liste.

### Bitenler (kronolojik, her görevden sonra eklenir)

- **T0.1–T0.5, T0.7–T0.10** — proje, kaynaklar, docs, paketler, marka ikonları, çekirdek, tema, 5 dil, router/kabuk.
- **T1.1, T1.2, T1.4–T1.7** — bileşen kütüphanesi + açık/koyu galeri (`--dart-define=INITIAL_ROUTE=/gallery`); galeri 5 dilde ve 1.6× yazı boyutunda taşmasız testli.
- **T2.1–T2.7** — domain, mock backend (+15 test), katalog (önbellekli), Home, arama, ülke/bölge sayfası, uyumluluk (Kotlin `EuiccManager` + iOS model), satın alma akışı (uçtan uca widget testi geçiyor).
- **T3.1–T3.4** — My eSIM listesi/arşiv, eSIM sayfası (QR, manuel, talimatlar, kullanım), kurulum, top-up.
- **T4.1, T4.3–T4.5, T4.7–T4.9** — OTP girişi, profil/ayarlar/cihazlar/hesap silme/belgeler, bakiye yükleme (PayPal+kripto), siparişler, giriş kapısı.
- **T0.6** — `flutter_native_splash` (açık/koyu + Android 12) iOS ve Android'e üretildi.
- **T1.3** — WCAG kontrast denetimi (`test/core/contrast_test.dart`): koyu temada `primary` metin için yetersizdi (2.9:1) → metinlerde `link`, rozet metinlerinde `successText`/`errorText` kullanılıyor; tasarımcıya bildirilecek.
- **Testler** — 43 test: mock backend (15), uçtan uca satın alma, eSIM listesi/QR, PayPal top-up, galeri (5 dil × açık/koyu), bayraklar (271 SVG), kontrast.
- **T4.2** — oturum yenileme: `AuthTokenRefresher` (`/v1/auth/refresh`, her yenilemede yeni çift) + `AuthInterceptor` kuyruğu; çevrimdışı yenileme oturumu bitirmez (9 test). Uç yolu OpenAPI'ye göre teyit edilecek (T7.1).
- **T4.6** — PayPal: uygulama içi tarayıcı, polling, **uygulamaya dönüşte anında kontrol**, `/pay/return` bağlantısı.
- **Firebase (bağlandı)** — push: topic `waysim`, kapalı/arka plan/açık teslim, dokunma yönlendirmesi, iOS `aps-environment` + arka plan modu, Android varsayılan ikon/renk/kanal; **Analytics**: satın alma hunisi (`view_item_list → begin_checkout → purchase`), oturum/etkileşim süresi, kaynak (davet bağlantısı), kullanıcı özellikleri; **çökme**: Crashlytics (Firestore istemci yazımları kapalı). Ayrıntı ve konsol adımları: [09-firebase.md](09-firebase.md). 86 test.
- **T5.4/T6.1–T6.3 (arayüzler)** — `PushService`, `AppAttestation`, `CrashReporter`, `DeviceIntegrity` arayüzleri + Noop uygulamaları DI'da; `PushRouter` (bildirim → ekran, kimlik doğrulamalı), ilk satın alma sonrası tek seferlik izin (`PushPermissionGate`), App Check başlığı (`AppCheckInterceptor`), root/jailbreak'te referral uyarısı ve davet alanı gizleme, yakalanmamış hatalar `CrashReporter`'a. **SDK'ları müşterinin Firebase projesi gelince bağlanacak.**
- **T6.5** — `minSupportedVersion` + `ForceUpdateGate` (sürüm karşılaştırma testli); bakım bayrağı satın almayı/yüklemeyi kapatıyor.
- **T2.8** — çevrimdışı: katalog diskte saklanır, ağ yokken önbellekten açılır ve aranır (testli).
- **T6.4 (kod tarafı)** — dört ana ekran iOS 44 pt / Android 48 dp dokunma alanı ve etiketli dokunma kılavuzlarını geçiyor; büyük yazı (1.6×) testli. VoiceOver/TalkBack turu cihazda.
- **T6.6 / T7.2** — `integration_test/purchase_flow_test.dart` (cihazda çalıştırılacak) ve `.github/workflows/ci.yml` (format, analyze, test, Android+iOS derleme) yazıldı; ikisi de henüz çalıştırılmadı.
- **T7.3 (metinler)** — 5 dilde mağaza metinleri, inceleme notları ve gizlilik formu taslağı: [08-store-listing.md](08-store-listing.md). Ekran görüntüleri ve inceleme hesabı backend gelince.
- **Tasarım/animasyon (1)** — tab bar: seçili sekme ikon arkasında büyüyen hap + ikon zıplaması + kalın etiket + hafif titreşim; `SegmentedTabs` iOS tarzı kayan thumb (sürüklenebilir); `TabSwitcher` ile içerik yön duyarlı kayma+solma (Home, My eSIM, paket sekmeleri, Siparişler). *Reduce Motion* açıkken animasyonsuz. 95 test.
- **Tasarım/animasyon (2)** — Home arama kutusu Hero ile uygulama çubuğuna uçar (sayfa solarak açılır, içerik kutu indikten sonra belirir, klavye kutu yerine oturunca açılır, geri dönerken önce klavye kapanır); banner'lar sonsuz döngü (3. banner'dan sonra aynı yönde 1.'ye, isteğe bağlı banner eklenip çıkarıldığında mevcut banner korunur); Ayarlar ve "Daha fazla" başlıkları ortalı. 99 test.
- **Tasarım/animasyon (Hero eşleşmeleri)** — ülke/bölge bayrağı liste satırından detay başlığına, eSIM kartı kimliği detay özetine, profilin Ayarlar/Daha fazla metinleri sayfa başlığına ve belge adı belge başlığına taşınır. Sistem hareketi azaltmayı istiyorsa bu uçuşlar atlanır.
- **Tasarım (3)** — Ayarlar: dil seçici parlayan bayraklı kartlar; tema seçici iki büyük önizleme kartı (açık/koyu gerçek renklerle mini uygulama, onay rozeti, hafif titreşim). Tema değişiminde yeni ekran soldan sağa 300 ms'de açılırken eski görünüm solar; "Hareketi azalt"ta değişim anındadır.
- **Tasarım (4)** — dil değişimi çapraz geçişle (`AppCrossfade`: ekran görüntüsü alınır, yeni dil altta çizilir, görüntü 250 ms'de erir; "Hareketi azalt"ta ve ekran görüntüsü 150 ms'de alınamazsa anında). Android alt sistem çubuğu gizli (`SystemUiManager`), durum çubuğu ikonları temaya uyar. 103+ test.
- **Tasarım (5)** — "Daha fazla" alt kartı: ortalı uygulama ikonu + ad + slogan + sürüm hapı + "Uygulama hakkında" satırı; "Hakkında" penceresi uygulama ikonunu (`assets/brand/app_icon.png`, 512×512) 128 dp gösterir. Benim cihazlarım, Davet et, Siparişler ve Bakiye yükleme başlıkları ortalandı. Kripto seçimi diyalog yerine alt sheet (coin rozeti, ağ hapı, radyo). 134 test.
- **Tasarım (6)** — eSIM sayfası PDF s.10 düzenine getirildi: gri sayfa + beyaz bölüm kartları (başlık+tek dokunuş, QR, manuel kurulum, talimat, kullanım), turuncu uyarı + mavi bilgi kutusu, beyaz kopyala düğmesi, ortalı başlık.
- **Açılış bağlantı kontrolü** — `ConnectionGate`: uygulama açılırken bağlantı yoksa "Нет подключения" ekranı (kodla çizilmiş animasyon: süzülen eSIM kartı, yayılan sinyal halkaları, sallanan çevrimdışı rozeti; "Hareketi azalt"ta durağan). Bağlantı gelince kendiliğinden devam eder; "Tekrar dene" ve "Çevrimdışı devam et" düğmeleri var. Sadece açılışı kapılar; sonradan kopmayı `OfflineBanner` karşılar. 5 dilde metin, 7 test (toplam 141).
- **Güvenlik denetimi ve sertleştirme** — release'te log/mock kapalı, `https` zorunlu, token yalnız kendi host'una, sunucu bağlantıları doğrulanır, galeri rotası release'te yok, çökme raporları temizlenir, Firestore istemci erişimi kapatıldı, Android yedek kapalı + upload imzası, iOS Keychain cihaza bağlı, root tespiti arayüze bağlandı; kullanılmayan 3 paket, ölü kod ve 5 ARB metni kaldırıldı. 227 test. Ayrıntı ve elle yapılacak adımlar: [10-security.md](10-security.md).
- **T7.1 (client-api 2026-10-23 güncellemesi)** — `meta.contacts` (web, e-posta, Telegram, Instagram) «Подробнее» ekranında kart olarak; `supportEmail` artık `contacts.email.label`. Kripto: `coins[]` ile coin→ağ seçimi, `feeOnTop`, stablecoin faturasında «$3.00 + $0.04 komisyon = $3.04» satırı; alt limit $1 (`wallet.limits.minCents`). Davet bağlantıları: `waysim://invite/KOD`, `https://waysim.co/<dil>/r/KOD` (Android manifest + router). `payment_credited` push'u `paymentId` ile ilgili ödemeyi açar. Doküman `docs/api/client-api.md` güncellendi. Yapılmadı: Android Play Install Referrer (paket gerekir); iOS entitlement hazır, AASA sitede yayınlanacak.
- **iOS: CocoaPods kaldırıldı** — tüm eklentiler Swift Package olduğu için `pod deintegrate` yapıldı; `Podfile`, `Podfile.lock`, `Pods/`, xcconfig `#include`'ları ve workspace'teki `Pods.xcodeproj` referansı silindi. Artık `pod install` gerekmez; ilk derleme Xcode/Flutter'ın SPM paketlerini çözmesiyle başlar.
- **T5.1–T5.3** — referral (sunucu bayrağıyla gizlenir), destek sayfası + `mailto`, AI sohbeti (mock).
- **Kurulum notu (varışta bağlanır)** — eSIM sayfasındaki tek dokunuş düğmesinin ve satın alma sonrası "Установить eSIM"in altına 5 dilde "eSIM varışta, yerel ağ bulununca bağlanır" notu; tek dokunuş bloğunda ayrıca mavi bilgi kutusu: "Подключение"de takılır veya Ayarlar'da "Активация…" yazarsa yolculuktan önce normaldir, eSIM'i silmeyin. Gerçek cihazda Avustralya eSIM'i kapsama dışında "Активация…"da kaldı. Backend hatası (bildirilecek): kullanım 0 iken `active` ve ilk bağlantıdan önce `expiresAt` (179 gün) gönderiyor; spesifikasyona göre `installed` ve `null` olmalı.
- **Tek dokunuş kurulum linki** — gerçek iPhone'da (iOS 26) düğme Apple'ın kurulum ekranını açıp "Подключение"de takılıyordu; aynı SM-DP+ ve kod elle girilince kuruluyordu. Link artık bu iki alandan Apple'ın belgelediği düz biçimde üretiliyor (`carddata=LPA:1$host$kod`, `:`/`$` kodlanmadan); sunucu linki yalnız alanlar beklenmedik karakter içerirse yedek. Cihazda doğrulanacak.
- **OTP teşhis logları** — iPhone'da kod e-postası geç geliyor/gelmiyor (Android'de anında). Debug konsolunda renkli `[AUTH]` blokları (istek, sunucu yanıtı `resendAfterSeconds`/`ttlSeconds`, süre, hata durum/kod/mesaj; e-posta maskeli), `[APPCHECK]` satırı (token eklendi mi, ne kadar sürdü) ve auth isteklerinde gönderilen başlıkların özeti (değerler değil, var/yok). Yalnız debug'da.
- **Kayıtta davet kodu alanı** — alan `referral.enabled`'a bağlıydı, ama bu bayrak yalnız oturumlu `/v1/referral`'dan geliyor; misafirde hep kapalı göründüğü için kayıtta alan hiç çıkmıyordu. Artık yalnız root/jailbreak'te gizli; kodu sunucu doğruluyor. Testli.

### Tamamlanmayanlar ve nedeni

| Görev | Durum | Neden |
| --- | --- | --- |
| T0.11 | kısmen | `flutter analyze` + testler yeşil; **cihazda/simülatörde çalıştırma proje sahibine bırakıldı** |
| T6.6 / T7.2 | kısmen | dosyalar yazıldı, ilk çalıştırma: `flutter test integration_test --dart-define=USE_MOCK_API=true` cihazda; CI için GitHub deposu gerekli |
| T6.1 App Check | kısmen | SDK bağlı (debug/Play Integrity/App Attest); konsolda uygulamaları kaydetme + zorlama backend gelince |
| T6.2 Root/jailbreak | kısmen | `root_jailbreak_detector` sonucu arayüze bağlı; daha güçlü tespit için RASP paketi (ör. freeRASP) eklenebilir |
| T5.4/T6.3 | cihazda doğrula | kod hazır; APNs anahtarı, Firestore kapalı kuralları projeye yayımlandı ([09](09-firebase.md)) |
| T5.5 Deep link | kısmen | `/r/KOD`, iOS Associated Domains ve AASA taslağı hazır; AASA sitede 404, gerçek cihaz testi bekliyor ([11](11-ios-release.md)) |
| T7.1 Gerçek API | dış girdi | backend OpenAPI'si yok |
| T7.3 Mağaza | kısmen | metinler hazır; ekran görüntüleri ve inceleme hesabı backend ve hesaplar gelince |
| T7.4 Pentest/yayın | dış girdi | pentest ve mağaza hesapları; sertifika sabitleme gerçek sertifika özetleri gelince ([10](10-security.md)) |

## Faz 0 — Proje kurulumu *(TZ aşama 0–2'nin mobil tarafı)*

- [x] **T0.1** Flutter projesini oluştur (iOS + Android); bundle/applicationId/Kotlin paketi `com.waysim.app` (proje sahibi onayladı)
- [x] **T0.2** Kaynakları topla: TZ + tasarım PDF'leri, eSIM Access API dokümanı, brand paketi, bayraklar → `docs/`, `assets/`, `design/`
- [x] **T0.3** Bu dokümanları yaz (`docs/01…07`)
- [x] **T0.4** `pubspec.yaml`: elyeter paketleri + yeni paketler, fontlar, asset klasörleri; `analysis_options.yaml` (elyeter lint seti); `l10n.yaml`
- [x] **T0.5** Marka varlıklarını native'e uygula: iOS AppIcon, Android mipmap/monochrome/`ic_stat_waysim`, `waysim_colors.xml`, uygulama adı "Waysim"
- [x] **T0.6** Splash (`flutter_native_splash`, açık+koyu, Android 12)
- [x] **T0.7** Çekirdeği elyeter'den taşı/uyarla: `result`, `failure`, `exceptions`, `AppLogger`, `AppBlocObserver`, `LocalStorage`, `SecureStorage`,
      `NetworkInfo`, `ApiClient`, interceptor'lar, `AppEnvironment`, `injector.dart`, `bootstrap.dart`
- [x] **T0.8** Tema: `AppColors`/`AppColorTokens` (ThemeExtension), `AppTypography` (Unbounded+Onest), `AppSpacing`/`AppRadius`, `AppTheme.light/dark`
- [x] **T0.9** Yerelleştirme: `en` (şablon), `zh`, `ru`, `es`, `fr` ARB iskeleti + `gen-l10n`; `LocaleCubit` (varsayılan en), `ThemeCubit` (varsayılan açık)
- [x] **T0.10** Router + kabuk: `go_router` `StatefulShellRoute` 3 sekme (Главное / Мои eSIM / Профиль), `AppTabBar`, yüzen destek FAB yer tutucusu
- [~] **T0.11** `flutter analyze` temiz, açılış testi (`flutter test`), iOS simülatör + Android derlemesi doğrulama

## Faz 1 — Tasarım sistemi bileşenleri

- [x] **T1.1** `AppButton` (primary/secondary/ghost/danger × sm/md/lg, disabled, loading)
- [x] **T1.2** `AppTextField`, `OtpField` (6 hücre, yapıştırma), `AppCard`, `SegmentedTabs`
- [x] **T1.3** Koyu tema kontrast denetimi (WCAG AA ≥ 4.5:1) ve düzeltme önerileri → tasarımcıya rapor
- [x] **T1.4** `StatusBadge` (7 durum), `PackageTile`, `CountryRow` + `FlagIcon` (SVG, fallback globe, `RepaintBoundary`)
- [x] **T1.5** `AppBottomSheet`, `AppToast`, `Skeleton`, `EmptyState`, `ErrorView`, `OfflineBanner`, `UsageProgress`, `CopyField`
- [x] **T1.6** `PromoCarousel` (5 sn auto, durdurma), `SupportFab`
- [x] **T1.7** Bileşen galerisi (debug ekranı, açık/koyu × 5 dil taşma testi) + widget testleri

## Faz 2 — Katalog ve satın alma (mock API) *(TZ aşama 2)*

- [x] **T2.1** Domain: `Money(cents)`, `Package`, `Region`, `Country`, `EsimStatus`, `Esim`, `Order`, `Balance`; formatlayıcılar (para, bayt→GB, tarih)
- [x] **T2.2** `catalog` feature: repository + mock data source (≈40 ülke, 7 bölge), cache (hydrated/prefs), `CatalogCubit`
- [x] **T2.3** Home: başlık + bakiye pill'i/"Войти", arama alanı, banner'lar, Местные/Региональные listesi
- [x] **T2.4** Arama: anında/yerel, eş anlamlı ve ülke kodu, son aramalar (saklı), bölge sonuçları
- [x] **T2.5** Ülke/bölge sayfası: uyumluluk bandı, Безлимитные / С лимитом ГБ, paket seçimi, "Сведения о пакете" sheet'i, "Купить за"
- [x] **T2.6** Cihaz eSIM uyumluluğu: Android Kotlin `MethodChannel` (`EuiccManager.isEnabled`), iOS `device_info_plus` + model listesi, "Как проверить" ekranı
- [x] **T2.7** Satın alma: onay sheet'i (bakiye önce/sonra), idempotency key (`uuid`), "Оформляем eSIM…", 30 sn zaman aşımı mesajı, bakiye yetersiz → yüklemeye yönlendir + geri dön, "eSIM готова!"
- [x] **T2.8** Hata/boş durumlar, offline bandı, pull-to-refresh, cache'ten gösterim

## Faz 3 — Мои eSIM *(TZ aşama 2–3)*

- [x] **T3.1** Liste: Текущие/Архив, durum rozetleri, kullanım progress, boş durum, "Принцип работы" sheet'i
- [x] **T3.2** eSIM kartı: `qr_flutter`, SM-DP+/kod/ICCID kopyalama, iPhone/Android talimat sekmeleri, kullanım ("обновлено N мин назад"), uyarılar
- [x] **T3.3** Kurulum: iOS 17.4+ tek dokunuş (Universal Link), diğerleri QR/manuel; "Установить" ile cihaz bağlama çağrısı
- [x] **T3.4** Top-up ("Пополнить пакет"): uygun planlar listesi → satın alma akışı (mock)

## Faz 4 — Hesap, giriş, bakiye *(TZ aşama 1/4'ün mobil tarafı)*

- [x] **T4.1** Giriş: e-posta + onay + (yeni) davet kodu → OTP ekranı (yapıştır, 60 sn tekrar gönder) → opsiyonel "Как к вам обращаться?"
- [x] **T4.2** Oturum: access + refresh (secure storage), `AuthInterceptor` yenileme + yarış koruması, 180 gün, misafir ID (`A0000`) ilk açılışta
- [x] **T4.3** Profil (misafir/girişli), Ayarlar (dil/tema/bildirim), Подробнее (6 belge WebView/URL + sürüm + lisanslar), Мои устройства
- [x] **T4.4** Hesap silme (kodla onay), çıkış
- [x] **T4.5** Bakiye yükleme: tutar seçimi/özel tutar (limit sunucudan), yöntem seçimi
- [x] **T4.6** PayPal: sunucu siparişi → Custom Tab/SFSafari → dönüş linki → durum poll → zafer/hata
- [x] **T4.7** Kripto: coin/ağ, fatura ekranı (tutar, adres, QR, sayaç, 3 adımlı durum), arka plan + push
- [x] **T4.8** Siparişler (Покупки/Пополнения)
- [x] **T4.9** Giriş sonrası "kaldığı yere dön" (`redirect` + `from`), misafir kapıları (satın alma, yükleme, referral, siparişler)

## Faz 5 — Referral, destek, push *(TZ aşama 6)*

- [x] **T5.1** Referral ekranı + paylaşım (`share_plus`) + remote config bayrağı (`referral.enabled/rewardCents`) ile gizleme
- [x] **T5.2** Destek sheet'i + `mailto:` (konu + teknik veri, yoksa kopyala)
- [x] **T5.3** AI chat ekranı (backend `/v1/support/chat`; hızlı çipler, rozet, uyarı, 30 gün geçmiş)
- [x] **T5.4** Push: Firebase kurulumu (müşteri projesi), izin akışı (ilk satın almadan sonra), kanal/ikon, token kaydı, yönlendirme (deep link), dil
- [~] **T5.5** Deep link: `waysim.co` Universal/App Links + `waysim://`; parametre doğrulama, onaysız aksiyon yok

## Faz 6 — Güvenlik ve kalite *(TZ aşama 7)*

- [~] **T6.1** Firebase App Check (App Attest / Play Integrity) → kayıt, referral, satın alma isteklerine token
- [~] **T6.2** Root/jailbreak/emülatör tespiti (uyarı + referral dışı)
- [x] **T6.3** Crashlytics (release), `--obfuscate --split-debug-info`, debug log'ların release'te kapalı olduğunun doğrulanması
- [x] **T6.4** Erişilebilirlik: Semantics, ≥44 pt, büyük font (1.3×–2.0×), VoiceOver/TalkBack turu
- [x] **T6.5** Bakım modu bayrağı (satın alma/yükleme kapanır), sürüm zorlama (min sürüm)
- [~] **T6.6** `integration_test` (giriş → satın alma → eSIM kartı), OWASP MASVS kontrol listesi

## Faz 7 — Gerçek API ve yayın

- [ ] **T7.1** Backend OpenAPI'si gelince data source'ları gerçek uçlara bağla (mock bayrağı kalır), uçtan uca staging testi
- [~] **T7.2** CI/CD (GitHub Actions/Codemagic): analyze, test, build, bağımlılık güvenlik taraması; TestFlight + Play iç test
- [~] **T7.3** Mağaza hazırlığı: ekran görüntüleri (5 dil), açıklamalar, gizlilik formları, inceleme hesabı (bkz. [05](05-platform-ios-android.md))
- [ ] **T7.4** Pentest bulgularının kapatılması; yayın

## Müşteri/ekipten beklenenler (engelleyiciler)

Firebase projesi (+ `GoogleService-Info.plist`, `google-services.json`), Apple Developer & Google Play hesapları, `waysim.co` DNS (AASA/assetlinks),
backend `/v1` OpenAPI + staging URL, banner içerikleri, 6 hukuki belge URL'i (RU/EN + diğer diller?), destek e-postası, FAQ (AI için),
uyumlu iPhone model listesi, referral varsayılanları. Ayrıntı: [07](07-open-questions.md).

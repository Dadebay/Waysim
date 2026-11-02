# 11 — iOS release hazırlığı

24 Ekim 2026 durumu: Xcode 27.1 ve Flutter 3.47.5 kurulu. `com.waysim.app` yalnız iPhone'u ve dikey yönü hedefler (iOS 15.6+). App icon 1024×1024 ve alfa kanalsız. Firebase yapılandırması, push arka plan modu, App Attest ve Associated Domains entitlement'ları projede. Uygulamanın topladığı veriler `ios/Runner/PrivacyInfo.xcprivacy` içinde beyan edilir; paketlerin kendi privacy manifest'leri ayrıca derlemeye girer. App Store Connect gizlilik yanıtları [mağaza taslağıyla](08-store-listing.md) ve gerçek backend davranışıyla yayın öncesi eşleştirilmelidir.

## Sitede gereken Universal Links dosyası

`https://waysim.co/.well-known/apple-app-site-association` 24 Ekim 2026'da **404** dönüyordu. Yerel kopya `/Users/dadebay/Developer/apps/Project Keys/22.Waysim/website/.well-known/apple-app-site-association` konumunda; bu dosyayı sitede aynı adrese, uzantısız, HTTPS üzerinden `application/json` olarak ve yönlendirme olmadan yayınlayın. Dosyadaki `V793RH49BX` Team ID'si Xcode projesinden alındı; Apple Developer hesabındaki Waysim App ID'si farklı takıma aitse dosyayı ve Xcode Team ayarını birlikte düzeltin. Ardından gerçek iPhone'da `https://waysim.co/en/r/TESTCODE` ve `https://waysim.co/pay/return` bağlantılarını deneyin. Apple'ın Associated Domains CDN önbelleği nedeniyle yeni dosyanın cihaza ulaşması zaman alabilir.

## Apple hesabında gerekenler

1. `com.waysim.app` App ID'sinde **Push Notifications**, **Associated Domains** ve **App Attest** yeteneklerini açın. Geliştirme ve dağıtım provisioning profillerini bu yeteneklerle yeniden oluşturun.
2. APNs Authentication Key (`.p8`) oluşturun ve Firebase Console → Project settings → Cloud Messaging içindeki iOS uygulamasına Key ID ve Team ID ile yükleyin. Anahtarı Git'e koymayın; `/Users/dadebay/Developer/apps/Project Keys/22.Waysim/` altında güvenli tutun.
3. Bu Mac'te yerel Apple Distribution sertifikası yok. `flutter build ipa` ve `xcodebuild -exportArchive`, otomatik imzalama ve Apple'ın bulutta yönettiği dağıtım sertifikasıyla çalışır.
4. App Store Connect'te **Waysim** uygulama kaydı `com.waysim.app` için oluşturuldu. Gizlilik etiketleri, güncel yaş derecelendirmesi, iPhone ekran görüntüleri, destek ve gizlilik URL'leri ve inceleme için çalışan test hesabı hazırlayın. Ödeme/bakiye akışını App Review kuralları açısından kontrol edin.

## Derleme ve doğrulama

Bu projede CocoaPods kaldırıldı ve eklentiler Swift Package Manager ile çözülüyor. `ios` içinde Podfile olmadığı için `pod install` çalıştırmayın. Proje kökünden `flutter pub get` ve aşağıdaki Flutter derlemesini kullanın; Xcode'da `ios/Runner.xcworkspace` dosyasını açın.

Xcode bir Firebase eklentisinin `PrivacyInfo.xcprivacy` dosyasını bulamazsa proje kökünden `flutter build ios --release --no-codesign --config-only --dart-define=FLAVOR=prod` çalıştırın. Flutter, bazı FlutterFire Swift paketlerini üretilmiş `build/ios/SourcePackages` önbelleğine kopyalar; bu klasörü silmek Xcode'un paket bağlantılarını kırar. Bu Mac'te gerçek önbellek `Project Keys/22.Waysim/flutter-build-cache` altında, proje içindeki `build` yolu ona giden kısayoldur.

İmza olmadan kaynak ve iOS release derlemesini doğrulama:

```sh
flutter build ios --release --no-codesign --dart-define=FLAVOR=prod
```

Üretim API ayarlarıyla App Store arşivi ve IPA oluşturma:

```sh
flutter build ipa --release --dart-define=FLAVOR=prod --dart-define=API_BASE_URL=https://api.waysim.co
```

24 Ekim 2026'da Xcode Organizer, `1.0.0 (1)` arşivini **Uploaded to Apple** olarak doğruladı. İlk yükleme denemesinde yeni App Store Connect kaydı oluşturulmasına rağmen kayıt hemen sorguda görünmedi; aynı arşivin ikinci denemesi başarılı oldu. Xcode beş üçüncü taraf framework için eksik dSYM uyarısı verdi (FirebaseAnalytics, GoogleAdsOnDeviceConversion, GoogleAppMeasurement, GoogleAppMeasurementIdentitySupport, RecaptchaEnterpriseSDK); uyarılar yüklemeyi durdurmadı. App Store Connect'teki build işlemesinin tamamlanmasını ayrıca kontrol edin.

25 Ekim 2026'da `1.0.0 (2)` üretim arşivi ve IPA oluşturulup `xcodebuild -exportArchive` ile App Store Connect'e yüklendi. Yükleme başarılı; App Store Connect → TestFlight → iOS → Build Uploads tablosunda build 2 **Processing** olarak doğrulandı. Aynı beş üçüncü taraf dSYM uyarısı tekrarlandı; yüklemeyi durdurmadı. Apple'ın işlemesi bitince build'i dağıtım sürümüne bağlayıp App Review hazırlığını tamamlayın.

Gerçek iPhone/TestFlight'ta giriş, davet Universal Link'i, PayPal dönüşü, eSIM kurulum bağlantısı, APNs/FCM ve App Check'i doğrulayın. Simülatör eSIM ve APNs davranışı için yeterli değildir. İmzalı arşivdeki `aps-environment` değerini ve Crashlytics dSYM yüklemesini de kontrol edin.

Kaynaklar: [Apple Associated Domains](https://developer.apple.com/documentation/xcode/supporting-associated-domains), [Apple privacy manifest](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files), [Firebase iOS FCM kurulumu](https://firebase.google.com/docs/cloud-messaging/flutter/get-started), [Apple'ın güncel SDK gereksinimi](https://developer.apple.com/news/upcoming-requirements/).

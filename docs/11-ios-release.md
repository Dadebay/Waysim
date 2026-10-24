# 11 — iOS release hazırlığı

24 Ekim 2026 durumu: Xcode 27.1 ve Flutter 3.47.5 kurulu. `com.waysim.app` yalnız iPhone'u ve dikey yönü hedefler (iOS 15.6+). App icon 1024×1024 ve alfa kanalsız. Firebase yapılandırması, push arka plan modu, App Attest ve Associated Domains entitlement'ları projede. Uygulamanın topladığı veriler `ios/Runner/PrivacyInfo.xcprivacy` içinde beyan edilir; paketlerin kendi privacy manifest'leri ayrıca derlemeye girer. App Store Connect gizlilik yanıtları [mağaza taslağıyla](08-store-listing.md) ve gerçek backend davranışıyla yayın öncesi eşleştirilmelidir.

## Sitede gereken Universal Links dosyası

`https://waysim.co/.well-known/apple-app-site-association` 24 Ekim 2026'da **404** dönüyordu. [Hazır dosyayı](../deployment/waysim.co/.well-known/apple-app-site-association) bu adreste, uzantısız, HTTPS üzerinden `application/json` olarak ve yönlendirme olmadan yayınlayın. Dosyadaki `V793RH49BX` Team ID'si Xcode projesinden alındı; Apple Developer hesabındaki Waysim App ID'si farklı takıma aitse dosyayı ve Xcode Team ayarını birlikte düzeltin. Ardından gerçek iPhone'da `https://waysim.co/en/r/TESTCODE` ve `https://waysim.co/pay/return` bağlantılarını deneyin. Apple'ın Associated Domains CDN önbelleği nedeniyle yeni dosyanın cihaza ulaşması zaman alabilir.

## Apple hesabında gerekenler

1. `com.waysim.app` App ID'sinde **Push Notifications**, **Associated Domains** ve **App Attest** yeteneklerini açın. Geliştirme ve dağıtım provisioning profillerini bu yeteneklerle yeniden oluşturun.
2. APNs Authentication Key (`.p8`) oluşturun ve Firebase Console → Project settings → Cloud Messaging içindeki iOS uygulamasına Key ID ve Team ID ile yükleyin. Anahtarı Git'e koymayın; `/Users/dadebay/Developer/apps/Project Keys/Waysim/` altında güvenli tutun.
3. Bu Mac'te Apple Development ve macOS Developer ID kimlikleri var, ancak **Apple Distribution sertifikası ve iOS provisioning profili yok**. Bu nedenle henüz App Store'a yüklenebilir imzalı IPA çıkarılamıyor. Doğru Apple Developer takımına erişim sağlandığında Xcode'un Signing & Capabilities bölümünde `Runner` için Automatic Signing ile sertifika/profil oluşturun.
4. App Store Connect'te uygulama kaydı, gizlilik etiketleri, güncel yaş derecelendirmesi, iPhone ekran görüntüleri, destek ve gizlilik URL'leri ve inceleme için çalışan test hesabı hazırlayın. Ödeme/bakiye akışını App Review kuralları açısından kontrol edin.

## Derleme ve doğrulama

Bu projede CocoaPods kaldırıldı ve eklentiler Swift Package Manager ile çözülüyor. `ios` içinde Podfile olmadığı için `pod install` çalıştırmayın. Proje kökünden `flutter pub get` ve aşağıdaki Flutter derlemesini kullanın; Xcode'da `ios/Runner.xcworkspace` dosyasını açın.

İmza olmadan kaynak ve iOS release derlemesini doğrulama:

```sh
flutter build ios --release --no-codesign --dart-define=FLAVOR=prod
```

Dağıtım sertifikası ve provisioning profili hazır olduğunda:

```sh
flutter build ipa --release --dart-define=FLAVOR=prod
```

Gerçek iPhone/TestFlight'ta giriş, davet Universal Link'i, PayPal dönüşü, eSIM kurulum bağlantısı, APNs/FCM ve App Check'i doğrulayın. Simülatör eSIM ve APNs davranışı için yeterli değildir. İmzalı arşivdeki `aps-environment` değerini ve Crashlytics dSYM yüklemesini de kontrol edin.

Kaynaklar: [Apple Associated Domains](https://developer.apple.com/documentation/xcode/supporting-associated-domains), [Apple privacy manifest](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files), [Firebase iOS FCM kurulumu](https://firebase.google.com/docs/cloud-messaging/flutter/get-started), [Apple'ın güncel SDK gereksinimi](https://developer.apple.com/news/upcoming-requirements/).

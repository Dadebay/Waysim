# Waysim — proje dokümanları

Waysim, iOS + Android için **turistik eSIM satan** bir mobil uygulamadır. Waysim bir **reseller**'dır:
müşteri uygulama içi **bakiyesinden** paket alır; backend, Waysim'in tedarikçideki (eSIM Access) ön ödemeli
bakiyesiyle eSIM'i satın alıp müşteriye verir. Alış fiyatı, marj ve API anahtarları müşteriye **asla** görünmez.
Domain: `waysim.co`.

Bu klasör, verilen kaynaklardan (TZ PDF, tasarım PDF, eSIM Access dokümanı, brand paketi, elyeter projesi)
derlenmiş **tek doğruluk kaynağıdır**. Kod yazarken önce buraya bak.

| Dosya | İçerik |
| --- | --- |
| [01-product-spec.md](01-product-spec.md) | Mobil uygulamanın ürün şartnamesi: ekranlar, akışlar, kurallar, durum eşlemeleri |
| [02-design-system.md](02-design-system.md) | Renk/tipografi/bileşen tokenları, ekran envanteri, ikon ve bayrak kuralları |
| [03-esim-provider-api.md](03-esim-provider-api.md) | eSIM Access API özeti (**yalnızca backend** konuşur), webhook'lar, durum eşlemesi |
| [04-architecture.md](04-architecture.md) | Flutter mimarisi, elyeter'den alınanlar, paket listesi, klasör yapısı |
| [05-platform-ios-android.md](05-platform-ios-android.md) | iOS/Android'e özel gereksinimler (deep link, push, eSIM kurulum, izinler, mağaza) |
| [06-roadmap.md](06-roadmap.md) | **Adım adım görev listesi** (checkbox'lı, durumu burada tutulur) |
| [07-open-questions.md](07-open-questions.md) | Verilen kararlar, TZ ile çelişen noktalar, müşteriden beklenenler |
| [09-firebase.md](09-firebase.md) | Push (topic `waysim`), Analytics olayları, Crashlytics çökme raporları, konsol adımları |
| [10-security.md](10-security.md) | Güvenlik denetimi: kapatılan açıklar, elle yapılacak adımlar (kurallar, App Check, anahtar kısıtı), sonraya kalanlar |
| [08-store-listing.md](08-store-listing.md) | App Store / Google Play metinleri (5 dil), inceleme notları, gizlilik formu taslağı |
| [reference/](reference/) | Ham kaynaklar: TZ ve tasarım PDF'leri (+ metin çıktıları), eSIM Access API ham çıktısı |

## Tek bakışta

- **Stack (mobil):** Flutter, **BLoC/Cubit** (elyeter'deki yapı), go_router, dio, get_it, hydrated_bloc.
  TZ "Riverpod" diyor — bilinçli sapma, bkz. [07](07-open-questions.md#1-tz-ile-çelişen-kararlar).
- **Diller:** English (varsayılan), 中文 (Çince), Русский, Español, Français — `flutter gen-l10n` ARB dosyaları.
- **Tema:** Açık (varsayılan) + **Koyu mod**. Tokenlar `ThemeExtension` içinde; widget'larda ham renk yok.
- **Font:** **Gilroy** (Regular/Medium/SemiBold/Bold; tam Kiril+Latin) — proje sahibinin tercihi, tasarım PDF'indeki Unbounded+Onest yerine. Dosyalar `assets/fonts/`.
- **İkonlar:** **Sadece Hugeicons** (`hugeicons`, stroke-rounded, 24px); `Icons.*` (Material) kullanılmaz — testle korunur. **Bayraklar:** `assets/flags/*.svg` (271 adet, emoji değil).
- **Marka:** birincil `#2F4E8F`, vurgu (pin) `#F2B84B`. Logo/ikonlar `assets/brand/` ve `design/brand/`.
- **Mobil sadece Waysim backend'ine konuşur.** eSIM Access'e doğrudan istek atılmaz (anahtarlar sunucuda kalır).

## Klasör haritası (repo)

```
waysim/
├─ docs/               ← bu klasör
├─ design/brand/       ← logo, store görselleri, web ikonları (kaynak dosyalar)
├─ assets/
│  ├─ brand/           ← uygulamada kullanılan logo/mark SVG + splash PNG
│  ├─ flags/           ← ülke bayrakları (ISO alpha-2 küçük harf: tr.svg, us.svg…)
│  └─ fonts/           ← Gilroy (Regular, Medium, SemiBold, Bold)
├─ lib/                ← bkz. 04-architecture.md
├─ android/  ios/
```

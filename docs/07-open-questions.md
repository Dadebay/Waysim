# 07 — Kararlar, çelişkiler ve açık sorular

## 1. TZ ile çelişen kararlar

| Konu | TZ / tasarım | Bu projede | Neden |
| --- | --- | --- | --- |
| State management | Riverpod | **BLoC/Cubit** | Proje sahibi elyeter'deki state management'ın alınmasını istedi. Backend ekibine/PM'e bildirilmeli; TZ §1.1 ve §8 güncellenmeli. |
| Model üretimi | freezed + json_serializable, OpenAPI'den Dart client | Elle `fromJson` + `equatable` (şimdilik) | Elyeter yapısı; codegen bağımlılığı yok. OpenAPI hazır olunca client üretimi değerlendirilir. |
| Diller | **en + ru** (ARB) | **en (varsayılan), zh, ru, es, fr** | Proje sahibi 5 dil istedi (Hytay = Çince, Spain = İspanyolca, Fransuz = Fransızca). Çince/İspanyolca/Fransızca için **çeviri + backend içerikleri (paket metinleri, belgeler, push) + mağaza metinleri** de gerekir → kapsam artar. |
| Font | Unbounded (başlık) + Onest (gövde) | **Gilroy** (tüm metin) | Proje sahibi "elyeter'deki Gilroy" istedi. **Elyeter'de Gilroy yok** (orada InterDisplay + Qurova var); Gilroy dosyaları proje sahibinin `Salon` projesinde bulundu ve oradan alındı (Kiril 64/64, Latin tam). ⚠️ Gilroy ticari font — lisansı kontrol et. Değişirse tek dosya: `app_typography.dart`. |
| Tema varsayılanı | Açık | Açık (+ koyu mod tam destekli) | Proje sahibi "dark mode da olacak" dedi; varsayılan TZ'deki gibi açık bırakıldı. Sisteme uyma istenirse `ThemeMode.system`. |
| Çince tipografi | (tasarım Çince göstermiyor) | Gilroy CJK içermez → sistem CJK fontu fallback | Çince başlık/gövde görünümü tasarımcıya gösterilmeli. |

## 2. Bu oturumda verilen varsayımlar (onay bekliyor)

1. **Bundle/applicationId: `com.waysim.app`** — proje sahibi karar verdi (2026-10-07). Mağazada kayıttan sonra değiştirilemez.
2. Dart paket adı `waysim`, görünen ad "Waysim".
3. Firebase paketleri henüz eklenmedi (müşterinin projesi yok); T5.4/T6.x.
4. İngilizce varsayılan: sistem dili Türkçe/Rusça olsa bile ilk açılışta İngilizce (talep: "english default").
5. Android `minSdk` 24 önerisi; iOS min 15.0.
6. iPad kapalı (ilk sürüm).

## 3. TZ'deki açık sorular (müşteri yanıtı gerekir)

- "Как к вам обращаться?" adımı gerekli mi?
- Referral bonusu: kayıt sonrası mı, arkadaşın ilk alımı sonrası mı? ($3 ucuz pakette tüm kârı yer.)
- `Z9999` sonrası ID formatı (`AA0000`?)
- Operatör rolü: ban + "Сервер и защита" hakları
- Yükleme limitleri ve ödeme komisyonunu kim öder
- İade yalnızca kurulmamış eSIM için mi?
- Kripto eksik/fazla ödeme: gerçek tutarı mı yükle, iade mi?
- IP ve kişisel veri saklama süresi
- Admin: Next.js mi Flutter Web mi?
- ⚠️ **Mağaza ödeme kuralları (dahili bakiye + kripto)** — ödeme geliştirmesinden önce.

## 4. Teknik doğrulama bekleyenler (varsayım yok)

- Android'de resmi "tek dokunuş eSIM kurulumu" yolu (reseller uygulaması için) var mı? Yoksa QR/manuel yeterli mi?
- iOS Universal Link formatı gerçek cihazda test edilecek (`esimsetup.apple.com/esim_qrcode_provisioning?carddata=…`).
- eSIM Access paketlerinin `location` alanındaki ülke kodlarından hangileri `assets/flags/`'ta yok (bazı özel kodlar: `!RG`, `!GL`, bölgeler).
- Paket `location` kodu → ülke adı çevirisi (5 dil): backend mi, istemci `intl`/yerel liste mi? (öneri: backend, `Accept-Language` ile).
- Hytay: Basitleştirilmiş (`zh-Hans`) mı Geleneksel mi? (öneri: **zh-Hans**).

## 5. Dış kaynaklar

- TZ PDF: `reference/waysim-tz-ru.pdf` · Tasarım PDF: `reference/waysim-design-ru.pdf`
- eSIM Access dokümanı: <https://docs.esimaccess.com/> · MCP: <https://mcp.esimaccess.com/> · Konsol: <https://console.esimaccess.com/>
- Elyeter (referans proje): `/Users/dadebay/Developer/apps/projects/elyeter`

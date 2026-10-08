# 03 — eSIM tedarikçi API'si (eSIM Access)

> **Önemli:** Bu API'yi **yalnızca Waysim backend'i** çağırır (AccessCode/SecretKey sunucuda kalır). Flutter uygulaması
> **hiçbir zaman** `api.esimaccess.com`'a istek atmaz; sadece Waysim API'sine (`/v1`, OpenAPI) konuşur. Bu doküman,
> backend ekibiyle sözleşmeyi ve mobil tarafın göreceği alanları anlamak içindir.

Kaynaklar: <https://docs.esimaccess.com/> (Postman Documenter; tam ham çıktı: [reference/esim-access-api.raw.md](reference/esim-access-api.raw.md)),
MCP sunucusu <https://mcp.esimaccess.com/mcp> (OAuth 2.1 + PKCE; 17 araç — paket listele, sipariş, kullanım, top-up, askıya alma, iptal,
SMS, webhook, bilgi bankası, tanılama. Geliştirme sırasında sorgu/test için faydalı; üretim entegrasyonu REST ile yapılır).

## Genel

| | |
| --- | --- |
| Base URL | `https://api.esimaccess.com` (**sandbox yok**; testte gerçek ortam + test kredisi, siparişi iptal edip iade al) |
| Görseller | `https://p.qrsim.net/` (QR PNG) |
| Metot | Tüm uçlar **POST**, JSON |
| Hız limiti | **8 istek/sn** |
| Para | `price * 10 000` (10000 = $1.00); bakiye de aynı ölçek. Bizde **cent** (1/100) → dönüşte `/100` |
| Birim | Hacim **byte**, zaman **UTC**, ülke kodu **ISO alpha-2** |
| Başarı | `{ success: true, errorCode: null\|"0", errorMsg, obj: {...} }` |

### Kimlik doğrulama (HMAC kullan)

Başlıklar: `RT-AccessCode`, `RT-RequestID` (uuid v4), `RT-Timestamp` (ms, string), `RT-Signature`.

```
signStr   = RT-Timestamp + RT-RequestID + RT-AccessCode + requestBody
signature = HMAC_SHA256(signStr, SecretKey) → hex, küçük harf
```

Sadece `RT-AccessCode` ile de çalışır; **TZ imzayı zorunlu kılar**. Hata kodları: `101001` timestamp süresi dolmuş, `101002` IP engelli,
`101003` imza uyuşmuyor.

## Uçlar

| Amaç | Uç | Önemli alanlar |
| --- | --- | --- |
| Paket listesi | `/api/v1/open/package/list` | `locationCode` (`JP`, `!RG` bölgesel, `!GL` global), `type` `BASE`/`TOPUP`, `slug`, `packageCode`, `iccid`, `dataType` (1 sabit, 2 gün-pass) |
| Sipariş | `/api/v1/open/esim/order` | `transactionId` (≤50, **idempotency**), `amount`, `packageInfoList[{packageCode|slug, count, price, periodNum}]` → `orderNo` |
| Profil sorgu | `/api/v1/open/esim/query` | `orderNo` / `iccid` / `esimTranNo` / zaman aralığı + `pager{pageNum,pageSize 5–500}` |
| İptal | `/api/v1/open/esim/cancel` | `esimTranNo` (önerilen) veya `iccid`; **sadece kurulmamış** (`GOT_RESOURCE` + `RELEASED`), iade Waysim'in tedarikçi bakiyesine |
| Askıya al / devam | `/api/v1/open/esim/suspend` · `/unsuspend` | `esimTranNo` / `iccid` |
| Geri çek | `/api/v1/open/esim/revoke` | Aktif eSIM'i kapatır, **iade yok** |
| Bakiye | `/api/v1/open/balance/query` | `obj.balance` (×10000) — eşik altı → admin uyarısı |
| Top-up | `/api/v1/open/esim/topup` | `esimTranNo`, `packageCode` (**slug önerilir**), `transactionId`, `periodNum`; sadece `New`/`In Use`/`Depleted`, süresi dolmuşa olmaz |
| Kullanım | `/api/v1/open/esim/usage/query` | `esimTranNoList` (≤10) → `dataUsage`, `totalData`, `lastUpdateTime` (2–3 saatte bir güncellenir, gerçek zamanlı değil) |
| SMS | `/api/v1/open/esim/sendSms` | `message` ≤500 (ücretsiz, destekleyen eSIM'lerde) |
| Bölgeler | `/api/v1/open/location/list` | `code`, `name`, `type` (1 tek ülke, 2 çoklu), `subLocationList` |
| Gün-pass fiyat kademesi | `/api/v1/open/discountRule/list` | `discountRuleCode` → `periodRuleList[minDays,maxDays,payRatio]` |
| Webhook kaydet | `/api/v1/open/webhook/save` (`/query` ile okunur) | ilk kayıtta `CHECK_HEALTH` testi; 200 dönmezse kaydedilmez |

### Paket (`packageList[]`) alanları

`packageCode`, `slug` (kalıcı, `TR_5_30`), `name`, `price` (×10000), `currencyCode`, `volume` (byte), `duration` + `durationUnit`,
`unusedValidTime` (kurulum süresi, gün — TZ: **180**), `location` (virgüllü alpha-2 listesi), `locationNetworkList[{locationName, locationLogo, operatorList[{operatorName,networkType}]}]`,
`dataType` (1 toplam · 2 günlük limit-yavaşlat · 3 günlük limit-kes · 4 günlük sınırsız), `smsStatus`, `activeType` (1 ilk kurulum · 2 ilk ağ bağlantısı),
`speed`, `ipExport`, `supportTopUpType` (1 yok · 2 var · 3 `periodNum` ile), `fupPolicy`, `retailPrice` (önerilen), `favorite`.

> Uygulama "Безлимитные / С лимитом ГБ" sekmelerini `dataType`'tan (2/3/4 = sınırsız-günlük, 1 = limitli) backend'in
> normalize ettiği `type` alanıyla çizer. "Раздача интернета / Пополнение / Звонки и SMS / Сеть" satırları paket detayındaki
> `operatorList`, `supportTopUpType`, `smsStatus` alanlarından gelir.

### eSIM profili (`esimList[]`)

`esimTranNo` (**kalıcı anahtar — ICCID yeniden kullanılır, esimTranNo ile sorgula**), `orderNo`, `transactionId`, `iccid`, `imsi`, `ac` (`LPA:1$<SM-DP+>$<kod>`),
`qrCodeUrl`, `shortUrl`, `smdpStatus`, `esimStatus`, `eid`, `activeType`, `expiredTime`, `totalVolume`, `orderUsage`, `totalDuration`, `durationUnit`,
`apn`, `pin`/`puk`, `packageList[]`.

## Durumlar

`esimStatus`: `CREATE`, `PAYING`, `PAID`, `GETTING_RESOURCE`, `GOT_RESOURCE`, `IN_USE`, `USED_UP`, `UNUSED_EXPIRED`, `USED_EXPIRED`, `CANCEL`, `SUSPENDED`, `REVOKE`.
`smdpStatus`: `RELEASED`, `DOWNLOAD`, `INSTALLATION`, `ENABLED`, `DISABLED`, `DELETED`.

Kombinasyonlar (tedarikçi tablosu): New = `RELEASED`+`GOT_RESOURCE`+kullanım 0 · Onboard = `ENABLED`+`IN_USE|GOT_RESOURCE`+kullanım 0 ·
In Use = kullanım > 0 · Depleted = `USED_UP` · Deleted = `DELETED`. Eşleme tablosu → [01-product-spec.md §5](01-product-spec.md).

## Sipariş akışı (TZ §5.4)

1. Backend kontrol (paket aktif, kullanıcı banlı değil, bakiye yeter) → **tek DB transaction'ında** sipariş + bakiye düşümü.
2. BullMQ worker tedarikçiye `esim/order` (`transactionId` = bizim idempotency key) gönderir.
3. Tedarikçi **asenkron** üretir: webhook `ORDER_STATUS` (`GOT_RESOURCE`) → `esim/query` ile profili çek (ICCID/QR). Webhook gelmezse
   artan beklemeyle poll. Profil hazır değilse `200010` ("hâlâ ayrılıyor").
4. Mobil: push "eSIM готова" + liste yenilenir. Hata: birkaç denemeden sonra sipariş "Не выполнен" + otomatik iade + push.
   **Timeout'ta önce tedarikçide sipariş durumunu sor, sonra iade et.**

## Webhook'lar (`notifyType`)

Zarf: `{ notifyType, notifyId (dedupe), eventGenerateTime, content }`. İdempotent işle. Kaynak doğrulama: dokümanda imza yok →
**URL'de gizli token + IP beyaz listesi** (`3.1.131.226, 54.254.74.88, 18.136.190.97, 18.136.60.197, 18.136.19.137, 54.151.164.206, 52.76.129.149, 18.142.83.98`).

| Tip | Ne zaman | İçerik | Mobil karşılığı |
| --- | --- | --- | --- |
| `ORDER_STATUS` | profil hazır (`GOT_RESOURCE`) | `orderNo`, `orderStatus`, `transactionId` (top-up'ta gelmez) | push "eSIM hazır" |
| `ESIM_STATUS` | yaşam döngüsü değişti | `iccid`, `esimStatus`, `smdpStatus`, `esimTranNo`… | durum rozeti |
| `SMDP_EVENT` | SM-DP+ adımları (çok sık) | `eid`, `seqNumber`, `notifyStatus` | sadece tanılama; `DOWNLOAD` takılı kalırsa destek |
| `DATA_USAGE` | eşik (0.5, 0.1…) | `totalVolume`, `orderUsage`, `remain`, `remainThreshold` | push "≤100 MB" (TZ) |
| `VALIDITY_USAGE` | 1 gün kaldı | `remain` (gün), `expiredTime` | push "1 gün kaldı" |
| `CHECK_HEALTH` | ilk kayıt testi | sentetik | yok sayılır |

Ek (2025-03): bakiye düşük uyarısı webhook'u (%25, %10) — admin bildirimi.

## İş kuralları

- **Top-up:** sadece `New`/`In Use`/`Depleted`; eSIM başına en çok **9** kez (TZ); sabit hacimli pakette GB **ve** gün eklenir, sınırsızda sadece gün;
  paket slug ile verilir; listeyi `package/list?type=TOPUP&iccid=…` ile al; `supportTopUpType` 2/3 değilse "Пополнить пакет" gizli.
- **İptal:** yalnızca `New`; kurulu eSIM'i sadece tedarikçi desteği iptal eder.
- **Süreler:** kurulum için 180 gün; paket süresi ilk ağ bağlantısından başlar (`activeType 2`). Silinen eSIM aynı QR ile **aynı cihaza** yeniden kurulur.
- **Kurulum:** iOS 17.4+ → Apple Universal Link (LPA dizesi); diğerleri QR / manuel (SM-DP+ + kod).
- **Kısıtlar:** sadece turist + telefon (router/IoT/uzun süreli tek ülke yok), yaptırım ülkelerine satış yok.
- **Hata kodları (özet):** `200002` işlem durumuna uygun değil · `200005/6` fiyat/toplam yanlış · `200007` **bakiye yetersiz** · `200010` profil indiriliyor ·
  `200011` stok yetersiz · `310241/3` paket yok · `310272` orderNo yok · `310403` ICCID siparişte yok · `900001` sistem meşgul (tekrar dene) ·
  `000101–000107` istek biçimi · `101001–101003` imza/IP.

## Mobil için çıkarımlar

1. Mobil model katmanı (`domain/entities`) tedarikçi alanlarını **taşımaz**; `Package`, `Esim`, `EsimStatus`, `Money(cents)` gibi
   kendi varlıklarımız var, sözleşme OpenAPI'den.
2. `Money` her yerde **cent (int)**; gösterim `$5.99` formatlayıcıdan.
3. `esimTranNo`/`orderNo` mobilde **opak ID**; ICCID sadece "Ручная установка" ekranında gösterilir.
4. Geliştirme sırasında backend yokken `data/datasources/*_mock_data_source.dart` ile sahte katalog/eSIM verisi (bkz. [06](06-roadmap.md) T2.x).

# 01 — Ürün şartnamesi (mobil)

Kaynak: `reference/waysim-tz-ru.pdf` (§1–§5, §7) ve `reference/waysim-design-ru.pdf`. Burada yalnızca
**mobil uygulamayı ilgilendiren** kısımlar var; backend/admin için PDF'e bak.

## 1. Temel kavramlar

- **Paket (package):** ülke veya bölge + hacim (GB veya sınırsız) + süre (gün) + fiyat. *Local* = tek ülke, *Regional* = çok ülke.
- **Bakiye (balance):** kullanıcının uygulama içi USD hesabı. Sadece uygulamada yüklenir/harcanır, **çekilemez**.
  Sunucuda **cent** (int) olarak tutulur; istemcide `double` ile para hesabı yapılmaz.
- **Misafir (guest):** kayıt olmamış kullanıcı. İlk açılışta bile public ID alır (`A0000`).
- **ID formatı:** `A0000…A9999`, sonra `B0000…Z9999` (toplam 260 000). Profilde `ID A0123` + kopyalama.

## 2. Gezinme

3 sekme: **Главное (Home) · Мои eSIM (My eSIM) · Профиль (Profile)** + tüm ekranlarda **yüzen destek butonu**
(56 pt daire, sağ altta, tab bar'ın üstünde; sabit "Купить/Пополнить" butonlarının üstüne çıkar).

Misafire açık: katalog, arama, ayarlar, belgeler, destek. **Giriş gerektirir:** satın alma, bakiye yükleme, referral, siparişler
(giriş sonrası kullanıcı kaldığı yere döner).

Deep link: `https://waysim.co/...` (Universal/App Links) ve `waysim://` — davet, ödeme dönüşü, push yönlendirmesi.
Parametreler doğrulanır; **bir link onaysız aksiyon yapmaz**.

Genel durumlar: yüklerken skeleton, hatada "Повторить", "Нет подключения" bandı, katalog + eSIM listesi **cache'ten** gösterilir,
pull-to-refresh.

## 3. Home (Главное)

- Başlık: "Привет, {Имя}!" (isim yoksa "Привет!") + **bakiye pill'i** (+ → bakiye yükleme). Misafirde bakiye yerine **"Войти"**.
- Arama: "Где вам нужен eSIM?" — anında, **cache'teki katalogda**, ilk harften; yerel + İngilizce isimler, eş anlamlılar,
  ülke kodları ("США", "USA", "US"). Sonuçta ülkeler ve bölgeler "от $X"; **son aramalar** saklanır (Очистить).
- **3 kare banner** (sunucudan içerik/aksiyon): swipe + 5 sn otomatik kaydırma (döngü, dokununca durur).
  1) eSIM nedir → "Принцип работы" sheet'i. 2) "Пригласите друга — получите $X" → referral (program kapalıysa banner yok).
  3) Seyahatte kolaylık → "Местные" listesi.
- **Местные / Региональные** segment (varsayılan Местные). Ülkeler alfabetik, bayrak + "от $X". Bölgeler: Avrupa, Asya, Amerika,
  Afrika, Orta Doğu, Okyanusya, Tüm dünya (tedarikçi paketlerine göre). **Paketi olmayan gösterilmez.**

## 4. Ülke/bölge ve satın alma

- Cihaz uyumluluğu: "Устройство поддерживает eSIM: Да/Нет" + "Как проверить".
  Android → Kotlin platform channel `EuiccManager.isEnabled`. iOS → `device_info_plus` model + sunucudaki uyumlu model listesi.
  Belirlenemezse talimat linki. **"Нет" ise uyarıdan sonra yine de satın alınabilir.**
- Paket listesi: sekmeler **Безлимитные / С лимитом ГБ** (boş olan gizlenir), fiyata göre sıralı: hacim, gün, fiyat. Radio seçimi.
- Seçili paket altında: "Сведения о пакете" (kaydırmalı sheet; RU/EN metinler sunucudan), **"Купить за $X"**, yasal not:
  *"Размещая заказ, вы подтверждаете, что используемое устройство совместимо с eSIM и не привязано к оператору."* +
  *"Разовая покупка — без подписки и автопродления."*
- Bölge: aynısı + açılır **ülke listesi**.
- Satın alma: misafir → önce giriş → pakete geri. **Onay sheet'i:** paket, fiyat, bakiye önce/sonra, onay metni, "Оплатить $X".
  Bakiye yetmezse → "Пополнить баланс" (tutar önceden doldurulur, satın almaya dönüş).
- İstemci **sadece paket ID + idempotency key** yollar (fiyat sunucudan). "Оформляем eSIM…" ekranı; 30 sn'den uzunsa
  "пришлём уведомление". Tedarikçi hatasında para **otomatik bakiyeye iade**. Fiyat sheet açıkken değiştiyse sunucu
  "цена изменилась" döner → yeni fiyatı göster.
- Başarı: "eSIM готова!" → "Установить eSIM" / "Позже".

## 5. Мои eSIM

- Boş/misafir: "Пока нет eSIM" + **"Приобрести eSIM"** (→ Home) + **"Принцип работы eSIM"** (4 adımlı sheet:
  Paket seç → Bakiyeden öde → Seyahatten önce kur (QR / tek dokunuş) → Varışta aç + veri dolaşımı).
- Liste: **Текущие / Архив** (tükenen ve süresi dolanlar arşivde). Kart: bayrak/bölge, paket, **durum rozeti**, kalan trafik
  (progress), kalan gün, cihaz + "обновлено N мин назад", "Установить до {tarih}".
- **eSIM kartı (detay):** QR (`qr_flutter`), **SM-DP+ adresi**, **aktivasyon kodu** (kopyala), ICCID; iOS 17.4+ **tek dokunuşla kurulum**
  (Apple Universal Link); iPhone/Android talimat sekmeleri; harcama + "Пополнить пакет" (top-up); *eSIM'i silmeyin* uyarısı;
  ana SIM için veri dolaşımını kapatma uyarısı. **Bir paket = bir cihaz** (bağlama "Установить"a basınca olur).

### Durum eşlemesi (tedarikçi → uygulama)

| Tedarikçi (`esimStatus` / `smdpStatus`) | Uygulamada | Rozet rengi |
| --- | --- | --- |
| (sipariş sürüyor, `GETTING_RESOURCE`/`PAID`) | Оформляется | nötr |
| `GOT_RESOURCE` + `RELEASED` (New) | **Не установлена** | warning |
| `GOT_RESOURCE`/`IN_USE` + `INSTALLATION`/`ENABLED`, kullanım 0 (Onboard) | **Установлена** | primary |
| `IN_USE` (kullanım > 0) | **Активна** | success |
| `USED_UP` | **Израсходована** | nötr/error-soft |
| `UNUSED_EXPIRED` / `USED_EXPIRED` | **Истекла** | nötr |
| `CANCEL` | **Не выполнен, средства возвращены** | error |
| `SUSPENDED`, `REVOKE(D)` | (destek durumu; admin'e düşer) | — |

> Dönüşümü **backend** yapar; uygulama kendi enum'unu (`EsimStatus`) alır, tedarikçi string'lerini görmez.

## 6. Profil ve giriş

- Misafir: "Войдите, чтобы покупать eSIM" + "Зарегистрироваться" (bu cihazda önceden girildiyse "Войти") + "Настройки", "Подробнее".
- **Giriş yalnızca e-posta kodu (OTP) ile, şifre yok:** e-posta + şartları kabul (18+ onay kutusu) → yeni kullanıcıya
  "Код приглашения" (opsiyonel) → **6 haneli kod** (panodan yapıştır, 60 sn sonra tekrar gönder) → yeni kullanıcıya opsiyonel
  "Как к вам обращаться?". Sunucu cevabı yeni/mevcut adres için **aynı** (enumeration yok).
- Oturum: access token ~15 dk, **refresh token `flutter_secure_storage`'da** (Keychain/Keystore), her yenilemede yenisi.
  180 gün uygulama açılmazsa oturum biter.
- Girişli profil: isim, e-posta, **ID A0123**, **Баланс $X + Пополнить**, Заказы, Пригласить друзей (+$3), Мои устройства,
  Настройки, Подробнее, **Удалить аккаунт** (App Store zorunlu, kodla onay), Выйти.
- **Ayarlar:** Dil (5 dil, bayrakla), Tema (Светлая/Тёмная), Bildirimler (Статус eSIM/баланс/расход; Новости и предложения).
- **Подробнее:** 6 yasal belge (waysim.co'dan: Общие положения, Условия использования, Политика возврата, Допустимое использование,
  Конфиденциальность, Cookie) + "О приложении" (sürüm) + açık kaynak lisansları.
- **Hesap silme:** geri alınamaz; bakiye + bonus yanar, kurulmamış paketler iade edilmeden iptal, kurulu eSIM'ler süre sonuna kadar çalışır,
  kişisel veri 30 gün içinde anonimleşir.

## 7. Bakiye ve yükleme

- Tutarlar $10 / $20 / $50 / $100 + özel tutar (sunucu limitleri; öneri **$5–$500**).
- **PayPal:** sipariş sunucuda oluşur; ödeme gömülü tarayıcıda (SFSafariViewController / Custom Tabs, `url_launcher`);
  bakiye **capture + sunucu doğrulamasından sonra** eklenir. İade/itirazlar webhook ile bakiyeden düşer.
- **Kripto:** sunucu fatura açar → ekranda coin + ağ (USDT/TRC-20), tam tutar, adres, QR, sayaç, durum çubuğu
  (**Ожидаем → Подтверждения N из M → Зачислено**). Eksik/fazla/geç ödeme → "На проверке". Ekran kapatılabilir, push gelir.
- Bir ödeme **tam bir kez** yüklenir; sonrasında push + satın almaya dönüş.
- Metin: *"Баланс тратится только на eSIM-пакеты и не выводится…Платёжный сервис может взять комиссию."*
- ⚠️ **Mağaza riski:** App Store/Google Play'in dahili bakiye ve kripto kuralları ödeme geliştirmesinden **önce** kontrol edilmeli (TZ açık soru).

## 8. Siparişler

Sekmeler **Покупки / Пополнения**. Satır: başlık (Ülke · hacim · gün / "Пополнение пакета · Турция +3 ГБ"), `−$5.99`,
"Заказ 10234 · 3 окт, 14:20", durum (Выполнен / **Не выполнен, средства возвращены**).

## 9. Destek ve push

- Destek butonu → sheet "Чем помочь?": **Онлайн-чат с ИИ** (24/7) ve **Написать нам** (e-posta).
- **AI chat:** backend üzerinden (anahtar sunucuda). Üstte "Отвечает ИИ" rozeti, uyarı *"ИИ может ошибаться. Он не видит ваши платежи…"*,
  hızlı soru çipleri, "Не помогло? Написать сотруднику", "История чата хранится 30 дней". ~30 mesaj/gün, 2000 karakter.
- **Написать нам:** `mailto:` — konu "Waysim — обращение, ID A0123" + teknik veri; mail uygulaması yoksa adres + kopyala.
- **Push (FCM; iOS'ta APNs):** izin **ilk satın almadan sonra** istenir. Ayarlardan tamamen kapatılabilir; metin uygulama dilinde;
  dokununca ilgili ekran. Olaylar: eSIM hazır; sipariş başarısız + iade; bakiye yüklendi; bonus; ≤100 MB kaldı; 1 gün kaldı; paket bitti; toplu duyuru.

## 10. Referral

"Пригласить друзей" (banner veya profil): 6–8 karakterlik kod (`WAY7K2Q`), `waysim.co/r/KOD`, "Поделиться ссылкой" (`share_plus`),
istatistik (Приглашено / Начислено / На проверке / Отклонено), kurallar, davet listesi (maskeli e-posta + durum).
Kod yalnızca **ilk kayıtta** girilir (link ile otomatik). Bonus bakiyeye gider, **sadece paketlerde harcanır**.
Kontroller: Firebase App Check (App Attest / Play Integrity), emülatör/root/jailbreak, IP, tek kullanımlık e-posta yasağı,
ayda ≤10 bonus. **Program kapalıysa** banner #2, profil satırı, kayıttaki kod alanı ve bonus push'ları **gizlenir**
(`referral.enabled`, `referral.rewardCents` açılışta ve ekrana dönüşte çekilir). Bonus tutarı metinlere **sunucudan** basılır.

## 11. Güvenlik (mobil)

- Token'lar **sadece** `flutter_secure_storage`. Release: `--obfuscate --split-debug-info`, debug log yok.
- Firebase App Check: kayıt, referral, satın alma. Root/jailbreak → uyarı + referral bonusu yok.
- Para her zaman cent/int; fiyat sunucudan; her sipariş/yükleme **idempotency key** taşır.
- Yaptırım ülkeleri (ABD/AB/UK/HK) için kayıt/ödemede ülke kısıtı (backend). Sadece turist + telefon kullanımı (router/IoT yok).
- Bakım modu bayrağı: açıksa satın alma ve yükleme kapanır (sunucudan gelen config).

## 12. Kabul ölçütleri (UI)

Dokunma alanı ≥ **44 pt**, güvenli alanlar, büyük sistem fontu düzeni bozmaz, animasyon **200–300 ms**,
metin kodda **yok** (ARB), bayrak **SVG** (emoji değil), kontrast WCAG AA (metin ≥ 4.5:1).

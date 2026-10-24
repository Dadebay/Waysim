# 08 — Mağaza metinleri (taslak)

App Store ve Google Play için 5 dilde ilk taslak. **Yayından önce müşteri onaylamalı**; fiyat, ülke sayısı gibi sayılar bilerek yok
(kataloğa göre değişir, yanlış beyan mağaza reddi sebebi). Ekran görüntüleri ve inceleme hesabı backend hazır olunca eklenir.

Ortak: ad **Waysim**, kategori *Travel* (alternatif: *Utilities*), yaş sınırı 4+/Everyone, gizlilik politikası `https://waysim.co/privacy`,
destek `support@waysim.co`.

## English (default)

- **Subtitle / short description (≤80):** Travel eSIM data plans. No roaming bills.
- **Description:** Get mobile data in 100+ destinations without swapping your SIM. Pick a country or region, choose a plan, pay from your Waysim balance and install the eSIM in minutes. One-time purchases — no subscription or auto-renewal. Top up your balance with PayPal or crypto, add data to an installed eSIM, track usage and invite friends for bonus credit. Works on phones that support eSIM; data only (no calls or SMS).
- **Keywords:** esim, travel, roaming, data plan, sim, internet abroad, tourist sim

## Русский

- **Подзаголовок / краткое описание:** eSIM для поездок. Без счетов за роуминг.
- **Описание:** Мобильный интернет за границей без замены SIM-карты. Выберите страну или регион, подберите пакет, оплатите с баланса Waysim и установите eSIM за пару минут. Разовые покупки — без подписки и автопродления. Пополняйте баланс через PayPal или криптовалютой, докупайте трафик на установленную eSIM, следите за расходом и приглашайте друзей, чтобы получать бонусы. Работает на телефонах с поддержкой eSIM; только интернет (без звонков и SMS).
- **Ключевые слова:** esim, роуминг, интернет за границей, путешествия, сим-карта

## Español

- **Subtítulo / descripción corta:** Planes eSIM para viajar. Sin facturas de roaming.
- **Descripción:** Datos móviles en el extranjero sin cambiar de SIM. Elige un país o región, escoge un plan, paga con tu saldo de Waysim e instala la eSIM en minutos. Compras únicas: sin suscripción ni renovación automática. Recarga tu saldo con PayPal o criptomonedas, añade datos a una eSIM ya instalada, consulta el consumo e invita a amigos para ganar saldo. Funciona en teléfonos compatibles con eSIM; solo datos (sin llamadas ni SMS).
- **Palabras clave:** esim, viajes, roaming, datos móviles, internet en el extranjero

## Français

- **Sous-titre / description courte :** Forfaits eSIM pour voyager. Sans frais d’itinérance.
- **Description :** Des données mobiles à l’étranger sans changer de carte SIM. Choisissez un pays ou une région, un forfait, payez avec votre solde Waysim et installez l’eSIM en quelques minutes. Achats uniques : sans abonnement ni renouvellement automatique. Rechargez votre solde via PayPal ou en crypto, ajoutez des données à une eSIM installée, suivez votre consommation et parrainez vos amis pour gagner du crédit. Compatible avec les téléphones eSIM ; données uniquement (pas d’appels ni de SMS).
- **Mots-clés :** esim, voyage, itinérance, forfait data, internet à l’étranger

## 中文（简体）

- **副标题 / 简短描述：** 旅行 eSIM 流量套餐，告别漫游账单。
- **描述：** 出国也能上网，无需更换 SIM 卡。选择国家或地区和套餐，用 Waysim 余额付款，几分钟内即可安装 eSIM。一次性购买，无订阅，不自动续费。可通过 PayPal 或加密货币为余额充值，为已安装的 eSIM 追加流量，随时查看用量，并邀请好友获得奖励。适用于支持 eSIM 的手机；仅提供数据流量（不含通话和短信）。
- **关键词：** esim, 旅行, 漫游, 流量套餐, 出国上网

## İnceleme (App Review) notları

- Hesap silme uygulama içinden yapılır: *Profile → Delete account* (e-postaya gelen kodla onay).
- Bakiye yalnızca eSIM paketlerinde harcanır, çekilemez; yükleme PayPal ve kripto ile. **Apple 3.1.x ve Google Play ödeme politikaları
  gönderimden önce madde madde kontrol edilmeli** (docs/07 risk maddesi).
- İnceleme ekibine test hesabı ve test bakiyesi verilir (backend hazır olunca).

## Gizlilik formu (taslak yanıtlar)

| Veri | Toplanıyor mu | Amaç |
| --- | --- | --- |
| E-posta | Evet | Hesap, giriş kodu, destek |
| Kullanıcı kimliği (A0123) | Evet | Hesap, destek |
| Cihaz kimliği / model | Evet | eSIM'i tek cihaza bağlama, sahtekârlık önleme |
| Satın alma geçmişi | Evet | Siparişler, iade |
| Çökme günlükleri (cihaz modeli, sürüm, ekran, hata) | Evet (Crashlytics) | Kararlılık |
| Kullanım verisi (ekranlar, aramalar, satın alma olayları, oturum süresi) | Evet (Firebase Analytics) | Analitik, ürün iyileştirme |
| Konum, kişiler, fotoğraflar, mikrofon, kamera | Hayır | — |

İzleme (ATT) yok; reklam SDK'sı yok.

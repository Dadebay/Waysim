# 02 — Tasarım sistemi

Kaynak: `reference/waysim-design-ru.pdf` (26 sayfa; son sayfa = tasarım sistemi) ve TZ §3.
Kural: **widget'larda ham renk, boyut veya string yok** — yalnızca token (`context.colors`, `AppSpacing`, `AppRadius`, `context.l10n`).

## Renkler (açık / koyu)

| Token | Açık | Koyu |
| --- | --- | --- |
| primary | `#2F4E8F` | `#4A6CB8` |
| primaryPressed | `#26406F` | `#3D5A9C` |
| primarySubtle | `#EAEFF8` | `#1C2740` |
| link | `#2F4E8F` | `#8FA9E0` |
| background | `#FFFFFF` | `#0E121A` |
| surface | `#F5F7FA` | `#161B25` |
| textPrimary | `#161D2B` | `#F2F4F8` |
| textSecondary | `#667085` | `#98A2B3` |
| textOnPrimary | `#FFFFFF` | `#FFFFFF` |
| border | `#E3E8EF` | `#2A3242` |
| success | `#12855A` | `#3CCB8A` |
| warning | `#B54708` | `#F79009` |
| error | `#D92D20` | `#F97066` |
| errorSubtle | `#FEF3F2` | `#3A1714` |

- Marka vurgusu (pin ikonu): **`#F2B84B`** (logo'da; UI tokenı değil, sadece marka görselleri).
- success/warning için "subtle" zemin rozetlerde kullanılır (tasarımda açık yeşil / açık turuncu); koyu temada tokenın düşük opaklığı.
- Koyu değerler TZ'de *öneri*: WCAG AA (≥ 4.5:1) kontrol edilecek (görev T1.3).
- Flutter: tokenlar `ThemeExtension<AppColorTokens>` → iki `ThemeData` (light/dark). Tema **varsayılan açık**, kullanıcı ayarlardan değiştirir.

## Tipografi

Tüm metin **Gilroy** (proje sahibinin kararı; tasarım PDF'i başlıkta Unbounded, gövdede Onest gösteriyor — boyut/satır yükseklikleri
aynen korunur, sadece aile değişir). Kiril ve Latin tam; Çince metin için sistem fontuna düşülür (CJK fallback — `fontFamilyFallback`).

| Stil | Boyut/satır | Font |
| --- | --- | --- |
| display | 32/38 | Gilroy Bold |
| h1 | 26/32 | Gilroy Bold |
| h2 | 20/26 | Gilroy Bold |
| h3 | 17/24 | Gilroy SemiBold |
| body | 16/24 | Gilroy Regular |
| bodyMedium | 15/22 | Gilroy Medium |
| bodySmall | 14/20 | Gilroy Regular |
| caption | 12/16 | Gilroy Regular |

Dosyalar statik: `Gilroy-Regular/Medium/SemiBold/Bold.ttf` (`pubspec.yaml` ağırlıkları 400/500/600/700). ⚠️ Gilroy ticari bir fonttur —
mağaza yayınından önce **lisansı** doğrula (bkz. 07).

**İkon kuralı:** her yerde `hugeicons` (`AppIcons` sabitleri → `HugeIcon`); Material `Icons.*` yok.

## Ölçüler

- Boşluk: **4 · 8 · 12 · 16 · 20 · 24 · 32**; ekran kenar boşluğu **20**; dokunma alanı **≥ 44**.
- Köşe: **12** (küçük), **16** (buton), **22** (kart), **28** (sheet üst köşeleri).
- Gölge: kart = yumuşak, belirsiz; "accent" = primary renkli, geniş, düşük opaklık (ör. primary buton/aktif eleman).
- İkon: çizgisel (stroke) 24 px, çizgi kalınlığı 1.8–2. Bayrak: SVG, daire kırpma (list satırı 28–32 px, header 24 px).
- Animasyon: **200–300 ms**, ease-out.

## Bileşen envanteri (T1.4–T1.6'da yazılır)

| Bileşen | Varyantlar / notlar |
| --- | --- |
| `AppButton` | primary / secondary / ghost / danger × sm·md·lg, disabled, loading (spinner) |
| `AppTextField` | normal, focus (primary kenar), error (errorSubtle zemin + kırmızı yardımcı metin) |
| `OtpField` | 6 hücre, panodan yapıştır, hata durumu |
| `AppCard` | surface/border, 22 radius |
| `CountryRow` | bayrak + ad + "от $X" + chevron |
| `PackageTile` | "5 ГБ  30 дней … $5.99 (radio)", seçili = primary kenar + subtle zemin |
| `SegmentedTabs` | Местные/Региональные, Безлимитные/С лимитом ГБ, Текущие/Архив, Покупки/Пополнения |
| `StatusBadge` | Оформляется · Не установлена (warning) · Установлена (primary) · Активна (success) · Израсходована · Истекла · Не выполнен (error) |
| `AppBottomSheet` | 28 radius, grabber, kapatma (X) |
| `AppToast` | koyu pill, ✓ + "Скопировано" |
| `PromoCarousel` | kare banner, otomatik 5 sn, nokta göstergesi |
| `SupportFab` | 56 pt daire, primary, chat ikonu |
| `AppTabBar` | Главное / Мои eSIM / Профиль (ikon + etiket) |
| `EmptyState`, `Skeleton`, `ErrorView(Retry)`, `OfflineBanner` | TZ §4.1 |
| `UsageProgress` | kalan GB / toplam, kalan gün |
| `QrCard`, `CopyField` | SM-DP+, aktivasyon kodu, ICCID |

## Ekran envanteri (tasarım PDF'indeki 25 sayfa)

1. Home (açık + koyu) — başlık+bakiye, arama, banner, Местные/Региональные
2. Arama (son sorgular, ülkeler, bölgeler)
3. Ülke sayfası (uyumluluk bandı, paket listesi, "Купить за")
4. Paket detay sheet'i · Satın alma onay sheet'i
5. eSIM hazır ("eSIM готова!") · Мои eSIM (liste / boş) · Принцип работы (4 adım)
6. eSIM kartı (tek dokunuş, QR, manuel kurulum, talimat sekmeleri, kullanım, top-up)
7. Giriş (e-posta + davet kodu + onay) · Kod girişi (OTP, tekrar gönder)
8. Profil (misafir / girişli) · Ayarlar (dil, tema, bildirimler) · Подробнее (belgeler + sürüm)
9. Hesap silme · Bakiye yükleme (tutar + yöntem) · Kripto ödeme · Siparişler
10. Referral · Destek sheet'i · AI chat
11. Tasarım sistemi sayfası

> **Not (5 dil):** Tasarım yalnızca RU/EN gösteriyor. Dil seçici 5 dili (EN, 中文, RU, ES, FR) listeler; metin uzunlukları (özellikle FR/RU)
> taşma testine tabidir.

## Bayrak kuralları

- Kaynak: `assets/flags/{iso2 küçük}.svg` (flag-icons 4:3 seti). Dil seçicide: `gb` (English), `cn` (中文), `ru`, `es`, `fr`.
- Ülke satırında tedarikçinin `location` alpha-2 kodu → `assets/flags/{code.toLowerCase()}.svg`. Dosya yoksa globe ikonu.
- Bölgeler (Asia, Europe…) bayrak değil **globe ikonlu daire** (tasarımda öyle).
- Karmaşık SVG'ler (`es`, `mx`, `bo`, `rs` > 50 KB) listede kasıyorsa `RepaintBoundary` + önceden raster cache (T1.5'te ölç).

## Marka varlıkları

`assets/brand/`: `logo.svg`, `logo_white.svg`, `mark.svg`, `mark_white.svg`, `splash_logo(.dark).png`, `android12_splash(.dark).png`.
`design/brand/`: tüm PNG/SVG logo boyutları, store ikonları (App Store 1024, Play 512 + feature graphic 1024×500), web favicon seti, `preview.png`.
Native ikonlar (iOS AppIcon set, Android mipmap + monochrome + `ic_stat_waysim`, `waysim_colors.xml`) paketin `flutter/` klasöründen
projeye kopyalanır (T0.5).

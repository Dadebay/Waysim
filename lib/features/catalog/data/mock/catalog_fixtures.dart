import '../../../../core/utils/formatters/money.dart';
import '../../domain/entities/destination.dart';
import '../../domain/entities/esim_package.dart';

/// In-memory catalog used until the backend exists (`USE_MOCK_API`).
/// Names are the five app languages; the real server sends the one asked for.
abstract final class CatalogFixtures {
  // code, en, ru, es, fr, zh, aliases, price factor (1.0 ≈ $1.99 for 1 GB)
  static const _countries =
      <(String, String, String, String, String, String, List<String>, double)>[
        (
          'AL',
          'Albania',
          'Албания',
          'Albania',
          'Albanie',
          '阿尔巴尼亚',
          ['alb'],
          1.5,
        ),
        (
          'AM',
          'Armenia',
          'Армения',
          'Armenia',
          'Arménie',
          '亚美尼亚',
          ['arm'],
          2.0,
        ),
        (
          'AU',
          'Australia',
          'Австралия',
          'Australia',
          'Australie',
          '澳大利亚',
          ['aus'],
          1.0,
        ),
        (
          'AT',
          'Austria',
          'Австрия',
          'Austria',
          'Autriche',
          '奥地利',
          ['aut'],
          1.0,
        ),
        (
          'AZ',
          'Azerbaijan',
          'Азербайджан',
          'Azerbaiyán',
          'Azerbaïdjan',
          '阿塞拜疆',
          ['aze'],
          2.5,
        ),
        ('BR', 'Brazil', 'Бразилия', 'Brasil', 'Brésil', '巴西', ['bra'], 1.5),
        ('CA', 'Canada', 'Канада', 'Canadá', 'Canada', '加拿大', ['can'], 1.0),
        ('CN', 'China', 'Китай', 'China', 'Chine', '中国', ['chn'], 2.0),
        ('EG', 'Egypt', 'Египет', 'Egipto', 'Égypte', '埃及', ['egy'], 2.0),
        ('FR', 'France', 'Франция', 'Francia', 'France', '法国', ['fra'], 1.0),
        ('GE', 'Georgia', 'Грузия', 'Georgia', 'Géorgie', '格鲁吉亚', ['geo'], 1.5),
        (
          'DE',
          'Germany',
          'Германия',
          'Alemania',
          'Allemagne',
          '德国',
          ['deu', 'ger'],
          1.0,
        ),
        ('GR', 'Greece', 'Греция', 'Grecia', 'Grèce', '希腊', ['grc'], 1.0),
        ('IN', 'India', 'Индия', 'India', 'Inde', '印度', ['ind'], 1.5),
        (
          'ID',
          'Indonesia',
          'Индонезия',
          'Indonesia',
          'Indonésie',
          '印度尼西亚',
          ['idn', 'bali'],
          1.5,
        ),
        ('IL', 'Israel', 'Израиль', 'Israel', 'Israël', '以色列', ['isr'], 2.0),
        ('IT', 'Italy', 'Италия', 'Italia', 'Italie', '意大利', ['ita'], 1.0),
        ('JP', 'Japan', 'Япония', 'Japón', 'Japon', '日本', ['jpn'], 1.5),
        (
          'KZ',
          'Kazakhstan',
          'Казахстан',
          'Kazajistán',
          'Kazakhstan',
          '哈萨克斯坦',
          ['kaz'],
          2.0,
        ),
        (
          'KG',
          'Kyrgyzstan',
          'Киргизия',
          'Kirguistán',
          'Kirghizistan',
          '吉尔吉斯斯坦',
          ['kgz', 'kyrgyz'],
          2.5,
        ),
        (
          'MY',
          'Malaysia',
          'Малайзия',
          'Malasia',
          'Malaisie',
          '马来西亚',
          ['mys'],
          1.5,
        ),
        ('MX', 'Mexico', 'Мексика', 'México', 'Mexique', '墨西哥', ['mex'], 1.5),
        ('MA', 'Morocco', 'Марокко', 'Marruecos', 'Maroc', '摩洛哥', ['mar'], 2.5),
        (
          'NL',
          'Netherlands',
          'Нидерланды',
          'Países Bajos',
          'Pays-Bas',
          '荷兰',
          ['holland', 'nld'],
          1.0,
        ),
        ('PL', 'Poland', 'Польша', 'Polonia', 'Pologne', '波兰', ['pol'], 1.0),
        (
          'PT',
          'Portugal',
          'Португалия',
          'Portugal',
          'Portugal',
          '葡萄牙',
          ['prt'],
          1.0,
        ),
        (
          'SA',
          'Saudi Arabia',
          'Саудовская Аравия',
          'Arabia Saudita',
          'Arabie saoudite',
          '沙特阿拉伯',
          ['ksa', 'sau'],
          2.0,
        ),
        (
          'SG',
          'Singapore',
          'Сингапур',
          'Singapur',
          'Singapour',
          '新加坡',
          ['sgp'],
          1.0,
        ),
        (
          'KR',
          'South Korea',
          'Южная Корея',
          'Corea del Sur',
          'Corée du Sud',
          '韩国',
          ['korea', 'kor'],
          1.5,
        ),
        ('ES', 'Spain', 'Испания', 'España', 'Espagne', '西班牙', ['esp'], 1.0),
        (
          'CH',
          'Switzerland',
          'Швейцария',
          'Suiza',
          'Suisse',
          '瑞士',
          ['che'],
          1.5,
        ),
        (
          'TH',
          'Thailand',
          'Таиланд',
          'Tailandia',
          'Thaïlande',
          '泰国',
          ['tha'],
          1.0,
        ),
        (
          'TR',
          'Türkiye',
          'Турция',
          'Turquía',
          'Turquie',
          '土耳其',
          ['turkey', 'tur'],
          1.0,
        ),
        (
          'AE',
          'United Arab Emirates',
          'ОАЭ',
          'Emiratos Árabes Unidos',
          'Émirats arabes unis',
          '阿拉伯联合酋长国',
          ['uae', 'dubai', 'are', 'эмираты'],
          1.5,
        ),
        (
          'GB',
          'United Kingdom',
          'Великобритания',
          'Reino Unido',
          'Royaume-Uni',
          '英国',
          ['uk', 'england', 'gbr', 'британия', 'англия'],
          1.0,
        ),
        (
          'US',
          'United States',
          'США',
          'Estados Unidos',
          'États-Unis',
          '美国',
          ['usa', 'us', 'america', 'штаты'],
          1.0,
        ),
        (
          'UZ',
          'Uzbekistan',
          'Узбекистан',
          'Uzbekistán',
          'Ouzbékistan',
          '乌兹别克斯坦',
          ['uzb'],
          2.0,
        ),
        ('VN', 'Vietnam', 'Вьетнам', 'Vietnam', 'Viêt Nam', '越南', ['vnm'], 1.0),
      ];

  // code, en, ru, es, fr, zh, member countries, note, price factor
  static const _regions =
      <
        (
          String,
          String,
          String,
          String,
          String,
          String,
          List<String>,
          String?,
          double,
        )
      >[
        (
          'EU',
          'Europe',
          'Европа',
          'Europa',
          'Europe',
          '欧洲',
          [
            'AL',
            'AT',
            'FR',
            'DE',
            'GR',
            'IT',
            'NL',
            'PL',
            'PT',
            'ES',
            'CH',
            'GB',
          ],
          null,
          3.0,
        ),
        (
          'ASIA',
          'Asia',
          'Азия',
          'Asia',
          'Asie',
          '亚洲',
          ['CN', 'IN', 'ID', 'JP', 'KR', 'MY', 'SG', 'TH', 'VN'],
          null,
          4.5,
        ),
        (
          'AMERICAS',
          'Americas',
          'Америки',
          'América',
          'Amériques',
          '美洲',
          ['US', 'CA'],
          'USA & Canada',
          2.5,
        ),
        (
          'AFRICA',
          'Africa',
          'Африка',
          'África',
          'Afrique',
          '非洲',
          ['EG', 'MA'],
          null,
          5.0,
        ),
        (
          'MIDDLE_EAST',
          'Middle East',
          'Ближний Восток',
          'Oriente Medio',
          'Moyen-Orient',
          '中东',
          ['AE', 'SA', 'IL'],
          null,
          3.0,
        ),
        (
          'OCEANIA',
          'Oceania',
          'Океания',
          'Oceanía',
          'Océanie',
          '大洋洲',
          ['AU'],
          null,
          3.5,
        ),
        (
          'CENTRAL_ASIA',
          'Central Asia',
          'Центральная Азия',
          'Asia Central',
          'Asie centrale',
          '中亚',
          ['KZ', 'UZ', 'KG', 'AM'],
          null,
          2.0,
        ),
        (
          'GLOBAL',
          'Worldwide',
          'Весь мир',
          'Todo el mundo',
          'Monde entier',
          '全球',
          [
            'US',
            'GB',
            'FR',
            'DE',
            'ES',
            'IT',
            'TR',
            'AE',
            'TH',
            'JP',
            'KR',
            'SG',
            'AU',
            'CA',
            'MX',
            'BR',
            'EG',
            'IN',
            'CN',
            'ID',
          ],
          null,
          6.0,
        ),
      ];

  static List<Destination> destinations() => [
    for (final c in _countries)
      Destination(
        code: c.$1,
        kind: DestinationKind.country,
        names: {'en': c.$2, 'ru': c.$3, 'es': c.$4, 'fr': c.$5, 'zh': c.$6},
        aliases: c.$7,
        minPrice: _price(c.$8, 1.99),
      ),
    for (final r in _regions)
      Destination(
        code: r.$1,
        kind: DestinationKind.region,
        names: {'en': r.$2, 'ru': r.$3, 'es': r.$4, 'fr': r.$5, 'zh': r.$6},
        minPrice: _price(r.$9, 1.99),
        countryCount: r.$7.length,
        coverageNote: r.$8,
      ),
  ];

  static const _gb = 1024 * 1024 * 1024;

  /// Fixed-volume tiers: GB, days, base price in dollars.
  static const _limitedTiers = [
    (1, 7, 1.99),
    (3, 30, 3.99),
    (5, 30, 5.99),
    (10, 30, 8.99),
    (20, 30, 16.99),
    (50, 30, 38.99),
  ];

  /// Unlimited tiers: days, base price (1 GB of full speed a day).
  static const _unlimitedTiers = [(3, 7.99), (7, 14.99), (15, 27.99)];

  static List<EsimPackage> packages(String code) {
    final factor = _factorFor(code);
    final coverage = _coverageFor(code);
    return [
      for (final t in _limitedTiers)
        EsimPackage(
          id: '${code}_${t.$1}_${t.$2}',
          destinationCode: code,
          kind: PackageKind.limited,
          days: t.$2,
          volumeBytes: t.$1 * _gb,
          price: _price(factor, t.$3),
          network: 'Local partner · 4G/5G',
          coverage: coverage,
          speed: '4G/5G',
        ),
      for (final t in _unlimitedTiers)
        EsimPackage(
          id: '${code}_U1_${t.$1}',
          destinationCode: code,
          kind: PackageKind.unlimited,
          days: t.$1,
          dailyBytes: _gb,
          price: _price(factor, t.$2),
          network: 'Local partner · 4G/5G',
          coverage: coverage,
          speed: '4G/5G',
        ),
    ];
  }

  /// Add-on plans for an installed eSIM: smaller, cheaper, same destination.
  static List<EsimPackage> topUps(String code) {
    final factor = _factorFor(code);
    return [
      for (final t in const [(1, 7, 1.99), (3, 30, 3.99), (5, 30, 5.99)])
        EsimPackage(
          id: 'TOPUP_${code}_${t.$1}_${t.$2}',
          destinationCode: code,
          kind: PackageKind.limited,
          days: t.$2,
          volumeBytes: t.$1 * _gb,
          price: _price(factor, t.$3),
          coverage: _coverageFor(code),
        ),
    ];
  }

  static double _factorFor(String code) {
    for (final c in _countries) {
      if (c.$1 == code) return c.$8;
    }
    for (final r in _regions) {
      if (r.$1 == code) return r.$9;
    }
    return 1;
  }

  /// Country codes a plan for [code] covers: itself, or a region's members.
  static List<String> _coverageFor(String code) {
    for (final r in _regions) {
      if (r.$1 == code) return r.$7;
    }
    return [code];
  }

  /// `$x.99`, the shop's price ending, scaled by [factor].
  static Money _price(double factor, double base) {
    final scaled = base * factor;
    final dollars = scaled.floor() + (scaled - scaled.floor() >= 0.5 ? 1 : 0);
    final whole = dollars < 1 ? 1 : dollars;
    return Money((whole - 1) * 100 + 99);
  }
}

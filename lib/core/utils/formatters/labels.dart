import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../features/catalog/domain/entities/esim_package.dart';
import 'data_size.dart';

/// Text for sizes, durations and times, assembled from translated pieces so
/// every language gets its own word order and plural forms.
extension LabelFormatting on AppLocalizations {
  /// `5 GB` / `850 MB`.
  String dataSize(int bytes) {
    final size = DataSize.of(bytes);
    return size.inGigabytes ? unitGb(size.value) : unitMb(size.value);
  }

  /// "5 GB" or "Unlimited".
  String packageVolume(EsimPackage p) =>
      p.isUnlimited ? dataUnlimited : dataSize(p.volumeBytes ?? 0);

  /// "30 days", or "1 GB a day · 7 days" for an unlimited plan.
  String packageDuration(EsimPackage p) {
    final days = durationDays(p.days);
    final daily = p.dailyBytes;
    return p.isUnlimited && daily != null
        ? '${dailyAllowance(dataSize(daily))} · $days'
        : days;
  }

  /// The words around a "from $X" price, split off so the price can be set in
  /// bold between them: `('from ', '')` in English, `('', ' 起')` in Chinese.
  (String prefix, String suffix) get priceFromParts {
    const marker = '\u0000';
    final parts = priceFrom(marker).split(marker);
    return (parts.first, parts.length > 1 ? parts.last : '');
  }

  /// "just now", "12 min ago", "3 h ago", "2 d ago".
  String ago(DateTime then, DateTime now) {
    final diff = now.difference(then);
    if (diff.inMinutes < 1) return agoJustNow;
    if (diff.inMinutes < 60) return agoMinutes(diff.inMinutes);
    if (diff.inHours < 24) return agoHours(diff.inHours);
    return agoDays(diff.inDays);
  }

  /// "Oct 3, 14:20" in the app language.
  String orderDate(DateTime d) =>
      DateFormat.MMMd(localeName).add_Hm().format(d);

  /// "Oct 3".
  String shortDate(DateTime d) => DateFormat.MMMd(localeName).format(d);

  /// "April 1, 2027".
  String longDate(DateTime d) => DateFormat.yMMMMd(localeName).format(d);
}

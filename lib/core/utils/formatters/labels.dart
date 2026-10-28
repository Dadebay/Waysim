import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../features/catalog/domain/entities/esim_package.dart';
import 'data_size.dart';

extension LabelFormatting on AppLocalizations {
  String dataSize(int bytes) {
    final size = DataSize.of(bytes);
    return size.inGigabytes ? unitGb(size.value) : unitMb(size.value);
  }

  String packageVolume(EsimPackage p) =>
      p.isUnlimited ? dataUnlimited : dataSize(p.volumeBytes ?? 0);

  String packageDuration(EsimPackage p) {
    final days = durationDays(p.days);
    final daily = p.dailyBytes;
    return p.isUnlimited && daily != null
        ? '${dailyAllowance(dataSize(daily))} · $days'
        : days;
  }

  (String prefix, String suffix) get priceFromParts {
    const marker = '\u0000';
    final parts = priceFrom(marker).split(marker);
    return (parts.first, parts.length > 1 ? parts.last : '');
  }

  String ago(DateTime then, DateTime now) {
    final diff = now.difference(then);
    if (diff.inMinutes < 1) return agoJustNow;
    if (diff.inMinutes < 60) return agoMinutes(diff.inMinutes);
    if (diff.inHours < 24) return agoHours(diff.inHours);
    return agoDays(diff.inDays);
  }

  String orderDate(DateTime d) =>
      DateFormat.MMMd(localeName).add_Hm().format(d);

  String shortDate(DateTime d) => DateFormat.MMMd(localeName).format(d);

  String longDate(DateTime d) => DateFormat.yMMMMd(localeName).format(d);
}

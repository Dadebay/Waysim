import '../../../core/widgets/status_badge.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/formatters/labels.dart';
import '../../catalog/domain/entities/esim_package.dart';
import '../domain/entities/esim.dart';

extension EsimStatusPresentation on EsimStatus {
  String label(AppLocalizations l10n) => switch (this) {
    EsimStatus.provisioning => l10n.statusProvisioning,
    EsimStatus.notInstalled => l10n.statusNotInstalled,
    EsimStatus.installed => l10n.statusInstalled,
    EsimStatus.active => l10n.statusActive,
    EsimStatus.usedUp => l10n.statusUsedUp,
    EsimStatus.expired => l10n.statusExpired,
    EsimStatus.suspended => l10n.statusSuspended,
    EsimStatus.cancelled => l10n.statusCancelled,
    EsimStatus.revoked => l10n.statusRevoked,
    EsimStatus.failed => l10n.statusFailed,
  };

  StatusTone get tone => switch (this) {
    EsimStatus.provisioning => StatusTone.info,
    EsimStatus.notInstalled => StatusTone.warning,
    EsimStatus.installed => StatusTone.info,
    EsimStatus.active => StatusTone.success,
    EsimStatus.usedUp => StatusTone.neutral,
    EsimStatus.expired => StatusTone.neutral,
    EsimStatus.suspended => StatusTone.warning,
    EsimStatus.cancelled ||
    EsimStatus.revoked ||
    EsimStatus.failed => StatusTone.neutral,
  };
}

extension EsimLabels on AppLocalizations {
  String esimTitle(Esim e) {
    final name = e.nameFor(localeName);
    final count = e.countryCount;
    return count == null ? name : esimRegionTitle(name, count);
  }

  String esimPlan(Esim e) {
    if (e.kind == PackageKind.unlimited) {
      final daily = e.dailyBytes;
      return daily == null
          ? '$dataUnlimited · ${durationDays(e.days)}'
          : unlimitedPlan(
              dailyAllowance(dataSize(daily)),
              durationDays(e.days),
            );
    }
    return esimPackageLine(dataSize(e.volumeBytes ?? 0), durationDays(e.days));
  }
}

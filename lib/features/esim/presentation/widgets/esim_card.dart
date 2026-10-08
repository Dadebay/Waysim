import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters/labels.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_hero.dart';
import '../../../../core/widgets/country_row.dart';
import '../../../../core/widgets/flag_icon.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/usage_progress.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/esim.dart';
import '../esim_labels.dart';

/// One eSIM in the My eSIM list.
class EsimCard extends StatelessWidget {
  const EsimCard({super.key, required this.esim, required this.onInstall});

  final Esim esim;

  /// Tapped on the "Install" button of a not-yet-installed eSIM.
  final VoidCallback onInstall;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final now = DateTime.now();

    final lead = esim.isRegion
        ? const RegionIcon(size: 40)
        : FlagIcon(esim.destinationCode, size: 40);

    return AppCard(
      onTap: () => context.push(AppRoute.esim.withParams({'id': esim.id})),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppHero(
            tag: AppHeroTags.esimHeader(esim.id),
            child: Material(
              type: MaterialType.transparency,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  lead,
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.esimTitle(esim), style: context.text.h3),
                        const SizedBox(height: 2),
                        Text(
                          l10n.esimPlan(esim),
                          style: context.text.bodySm.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  StatusBadge(
                    label: esim.status.label(l10n),
                    tone: esim.status.tone,
                  ),
                ],
              ),
            ),
          ),
          ..._details(context, l10n, now),
        ],
      ),
    );
  }

  List<Widget> _details(
    BuildContext context,
    AppLocalizations l10n,
    DateTime now,
  ) {
    final c = context.colors;
    final small = context.text.bodySm;
    final muted = small.copyWith(color: c.textSecondary);

    switch (esim.status) {
      case EsimStatus.active:
        final days = esim.daysLeft(now);
        return [
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Text(
                  esim.isUnlimited || esim.remainingBytes == null
                      ? l10n.dataUnlimited
                      : l10n.esimLeftOf(
                          l10n.dataSize(esim.remainingBytes!),
                          l10n.dataSize(esim.volumeBytes!),
                        ),
                  style: small.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (days != null) Text(l10n.esimDaysLeft(days), style: muted),
            ],
          ),
          if (!esim.isUnlimited) ...[
            const SizedBox(height: AppSpacing.sm),
            UsageProgress(remainingFraction: esim.remainingFraction),
          ],
          if (esim.deviceName != null && esim.updatedAt != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.esimDeviceUpdated(
                esim.deviceName!,
                l10n.ago(esim.updatedAt!, now),
              ),
              style: muted,
            ),
          ],
        ];
      case EsimStatus.notInstalled:
        final by = esim.installBy;
        return [
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  by == null ? '' : l10n.esimInstallBy(l10n.longDate(by)),
                  style: muted,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              AppButton(
                label: l10n.actionInstall,
                size: AppButtonSize.sm,
                expand: false,
                onPressed: onInstall,
              ),
            ],
          ),
        ];
      case EsimStatus.installed:
        return [
          const SizedBox(height: AppSpacing.md),
          Text(l10n.esimValidityFromFirst, style: muted),
        ];
      case EsimStatus.provisioning || EsimStatus.usedUp || EsimStatus.expired:
        return const [];
    }
  }
}

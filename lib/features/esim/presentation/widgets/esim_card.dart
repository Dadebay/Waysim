import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_icons.dart';
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
        ? const RegionIcon(size: 44)
        : FlagIcon(esim.destinationCode, size: 44);

    return AppCard(
      onTap: () => context.push(AppRoute.esim.withParams({'id': esim.id})),
      padding: const EdgeInsets.all(AppSpacing.xl),
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
                        Text(
                          l10n.esimTitle(esim),
                          style: context.text.h3.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
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
          const SizedBox(height: AppSpacing.xl),
          Divider(height: 1, thickness: 1, color: c.border),
          const SizedBox(height: AppSpacing.lg),
          Text(
            esim.isUnlimited || esim.remainingBytes == null
                ? l10n.dataUnlimited
                : l10n.esimLeftOf(
                    l10n.dataSize(esim.remainingBytes!),
                    l10n.dataSize(esim.volumeBytes!),
                  ),
            style: context.text.bodyMed.copyWith(
              color: c.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (days != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.esimDaysLeft(days),
              style: muted.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
          if (!esim.isUnlimited) ...[
            const SizedBox(height: AppSpacing.md),
            UsageProgress(remainingFraction: esim.remainingFraction),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: esim.updatedAt == null
                    ? const SizedBox.shrink()
                    : Text(
                        l10n.esimUpdated(l10n.ago(esim.updatedAt!, now)),
                        style: context.text.caption.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
              ),
              HugeIcon(
                icon: AppIcons.chevronRight,
                size: 18,
                color: c.textSecondary,
              ),
            ],
          ),
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
      case EsimStatus.provisioning ||
          EsimStatus.usedUp ||
          EsimStatus.expired ||
          EsimStatus.suspended ||
          EsimStatus.cancelled ||
          EsimStatus.revoked ||
          EsimStatus.failed:
        return const [];
    }
  }
}

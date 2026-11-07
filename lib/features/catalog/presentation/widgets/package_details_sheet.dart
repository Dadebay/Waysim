import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters/labels.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/esim_package.dart';

Future<bool> showPackageDetailsSheet(
  BuildContext context, {
  required EsimPackage package,
  required String destinationName,
  required String coverage,
  required bool canBuy,
}) async {
  final l10n = context.l10n;
  final buy = await showAppSheet<bool>(
    context,
    title: l10n.packageDetailsLink,
    closeLabel: l10n.actionClose,
    builder: (sheetContext) => _Details(
      package: package,
      destinationName: destinationName,
      coverage: coverage,
      canBuy: canBuy,
    ),
  );
  return buy ?? false;
}

class _Details extends StatelessWidget {
  const _Details({
    required this.package,
    required this.destinationName,
    required this.coverage,
    required this.canBuy,
  });

  final EsimPackage package;
  final String destinationName;
  final String coverage;
  final bool canBuy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final p = package;

    final dataDescription = p.details?.trim();
    final dataValue = p.isUnlimited
        ? (p.dailyBytes == null
              ? l10n.dataUnlimited
              : l10n.dailyAllowance(l10n.dataSize(p.dailyBytes!)))
        : l10n.detailDataFull(l10n.dataSize(p.volumeBytes ?? 0));

    final featureRows = <_Row>[
      if (p.network != null) _Row(l10n.detailNetwork, p.network!),
      _Row(
        l10n.detailHotspot,
        p.hotspot ? l10n.detailAvailable : l10n.detailUnavailable,
        good: p.hotspot,
      ),
      _Row(
        l10n.detailTopUp,
        p.topUp ? l10n.detailAvailable : l10n.detailUnavailable,
        good: p.topUp,
      ),
      _Row(
        l10n.detailCalls,
        p.smsAndCalls ? l10n.detailCallsIncluded : l10n.detailDataOnly,
      ),
      _Row(l10n.detailInstall, l10n.detailInstallWithin(p.installWithinDays)),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        0,
        AppSpacing.page,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: c.primarySubtle,
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          destinationName,
                          style: context.text.bodySm.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(l10n.packageVolume(p), style: context.text.h2),
                        Text(
                          l10n.durationDays(p.days),
                          style: context.text.bodySm.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    p.price.format(),
                    style: context.text.h2.copyWith(color: c.primary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _DetailGroup(
            children: [
              _Row(l10n.detailCoverage, coverage),
              _DataDetail(
                value: dataValue,
                description: dataDescription?.isNotEmpty == true
                    ? dataDescription
                    : p.isUnlimited && p.dailyBytes != null
                    ? l10n.detailDataUnlimited(l10n.dataSize(p.dailyBytes!))
                    : null,
              ),
              _Row(
                l10n.detailValidity,
                l10n.durationDays(p.days),
                note: p.activationOnInstall
                    ? l10n.activationOnInstall
                    : l10n.detailValidityNote,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _DetailGroup(children: featureRows),
          if (canBuy) ...[
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: l10n.buyFor(p.price.format()),
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.oneTimePurchase,
              textAlign: TextAlign.center,
              style: context.text.caption.copyWith(color: c.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailGroup extends StatelessWidget {
  const _DetailGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.border),
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          children: [
            for (final (index, child) in children.indexed) ...[
              if (index > 0) Divider(color: c.border, height: 1),
              child,
            ],
          ],
        ),
      ),
    );
  }
}

class _DataDetail extends StatelessWidget {
  const _DataDetail({required this.value, this.description});

  final String value;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.detailData,
            style: context.text.bodySm.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: context.text.h2),
          if (description != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              description!,
              style: context.text.bodySm.copyWith(color: c.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.note, this.good});

  final String label;
  final String value;
  final String? note;

  final bool? good;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  label,
                  style: context.text.bodySm.copyWith(color: c.textSecondary),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 5,
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: context.text.bodyMed.copyWith(
                    fontWeight: FontWeight.w700,
                    color: switch (good) {
                      true => c.success,
                      false => c.textSecondary,
                      null => c.textPrimary,
                    },
                  ),
                ),
              ),
            ],
          ),
          if (note != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              note!,
              style: context.text.caption.copyWith(color: c.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

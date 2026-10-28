import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/services/esim_compatibility.dart';
import '../../../../core/services/esim_support_cubit.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';

/// One tappable row with the device's eSIM support; each answer opens a sheet
/// that says what to check next.
class CompatBanner extends StatelessWidget {
  const CompatBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    return switch (context.watch<EsimSupportCubit>().state) {
      EsimSupport.yes => _CompatRow(
        icon: AppIcons.check,
        color: c.success,
        label: l10n.compatYesRow,
        onTap: () => showSupportedSheet(context),
      ),
      EsimSupport.no => _CompatRow(
        icon: AppIcons.warning,
        color: c.error,
        label: l10n.compatNoRow,
        onTap: () => showUnsupportedSheet(context),
      ),
      _ => _CompatRow(
        icon: AppIcons.info,
        color: c.textSecondary,
        label: l10n.compatSheetTitle,
        onTap: () => showCompatSheet(context),
      ),
    };
  }
}

/// How to find out whether a phone has eSIM, in the words of its platform.
Future<void> showCompatSheet(BuildContext context) {
  final l10n = context.l10n;
  final isIos = Theme.of(context).platform == TargetPlatform.iOS;
  return showAppSheet<void>(
    context,
    title: l10n.compatSheetTitle,
    closeLabel: l10n.actionClose,
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        0,
        AppSpacing.page,
        AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isIos ? l10n.compatSheetIos : l10n.compatSheetAndroid,
            style: context.text.body,
          ),
          const SizedBox(height: AppSpacing.xl),
          Builder(
            builder: (sheetContext) => AppButton(
              label: l10n.actionGotIt,
              onPressed: () => Navigator.of(sheetContext).pop(),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Shown before buying on a phone that reports no eSIM support.
/// Resolves `true` when the customer chooses to buy anyway.
Future<bool> confirmBuyWithoutEsim(BuildContext context) async {
  final l10n = context.l10n;
  final proceed = await showAppSheet<bool>(
    context,
    title: l10n.compatWarningTitle,
    closeLabel: l10n.actionClose,
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        0,
        AppSpacing.page,
        AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.compatWarningBody, style: sheetContext.text.body),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: l10n.actionContinueAnyway,
            onPressed: () => Navigator.of(sheetContext).pop(true),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: l10n.actionCancel,
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.of(sheetContext).pop(false),
          ),
        ],
      ),
    ),
  );
  return proceed ?? false;
}

/// White card row: tinted icon disc, label, chevron.
class _CompatRow extends StatelessWidget {
  const _CompatRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final AppIconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                _IconDisc(icon: icon, color: color),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(label, style: context.text.bodyMed)),
                HugeIcon(
                  icon: AppIcons.chevronRight,
                  size: 20,
                  color: c.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconDisc extends StatelessWidget {
  const _IconDisc({required this.icon, required this.color});

  final AppIconData icon;
  final Color color;
  static const double size = 44;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.22),
        shape: BoxShape.circle,
      ),
      child: HugeIcon(
        icon: icon,
        size: size * 0.5,
        color: context.colors.textPrimary,
      ),
    );
  }
}

/// Large tinted circle at the top of a "Check your device" sheet.
class _SheetBadge extends StatelessWidget {
  const _SheetBadge({required this.icon, required this.fill});

  final AppIconData icon;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
        child: HugeIcon(
          icon: icon,
          size: 48,
          color: context.colors.textPrimary,
        ),
      ),
    );
  }
}

/// "Check your device" for a phone with eSIM: it also has to be free of a
/// carrier lock, and iPhone regional variants need the EID check.
Future<void> showSupportedSheet(BuildContext context) {
  final l10n = context.l10n;
  final isIos = Theme.of(context).platform == TargetPlatform.iOS;
  return showAppSheet<void>(
    context,
    title: l10n.compatNoSheetTitle,
    closeLabel: l10n.actionClose,
    builder: (sheetContext) {
      final c = sheetContext.colors;
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          0,
          AppSpacing.page,
          AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SheetBadge(
              icon: AppIcons.check,
              fill: c.success.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(l10n.compatYesRow, style: sheetContext.text.h3),
            const SizedBox(height: AppSpacing.md),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: l10n.compatYesLead),
                  TextSpan(
                    text: l10n.compatYesBold,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              style: sheetContext.text.body,
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.compatLockTitle,
                    style: sheetContext.text.bodyMed.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    isIos ? l10n.compatLockIos : l10n.compatLockAndroid,
                    style: sheetContext.text.bodySm,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: c.background,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: c.border, width: 2),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HugeIcon(
                          icon: AppIcons.tip,
                          size: 24,
                          color: c.textPrimary,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            l10n.compatLockTip,
                            style: sheetContext.text.bodySm.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: l10n.actionGotIt,
              onPressed: () => Navigator.of(sheetContext).pop(),
            ),
          ],
        ),
      );
    },
  );
}

/// "Check your device": why this phone cannot use Waysim, and what to check
/// when buying for another one.
Future<void> showUnsupportedSheet(BuildContext context) {
  final l10n = context.l10n;
  return showAppSheet<void>(
    context,
    title: l10n.compatNoSheetTitle,
    closeLabel: l10n.actionClose,
    builder: (sheetContext) {
      final c = sheetContext.colors;
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          0,
          AppSpacing.page,
          AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SheetBadge(
              icon: AppIcons.warning,
              fill: c.warning.withValues(alpha: 0.7),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(l10n.compatNoRow, style: sheetContext.text.h3),
            const SizedBox(height: AppSpacing.md),
            Text(l10n.compatNoBody, style: sheetContext.text.body),
            const SizedBox(height: AppSpacing.lg),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: l10n.compatNoOtherLead),
                  TextSpan(
                    text: l10n.compatNoOtherBold,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              style: sheetContext.text.body,
            ),
            const SizedBox(height: AppSpacing.xl),
            Material(
              color: c.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.card),
                onTap: () => showCompatSheet(sheetContext),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      _IconDisc(icon: AppIcons.phone, color: c.link),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          l10n.compatNoCheckDevices,
                          style: sheetContext.text.bodyMed,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: l10n.actionGotIt,
              onPressed: () => Navigator.of(sheetContext).pop(),
            ),
          ],
        ),
      );
    },
  );
}

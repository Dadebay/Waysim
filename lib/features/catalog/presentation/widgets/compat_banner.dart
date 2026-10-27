import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/services/esim_compatibility.dart';
import '../../../../core/services/esim_support_cubit.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';

/// Shows a result only when the device or the person has confirmed it.
class CompatBanner extends StatelessWidget {
  const CompatBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final supportCubit = context.watch<EsimSupportCubit>();
    final support = supportCubit.state;

    if (support == EsimSupport.no && !supportCubit.isModelBased) {
      return _UnsupportedRow(onTap: () => showUnsupportedSheet(context));
    }

    final (icon, tint, value) = switch (support) {
      EsimSupport.yes => (AppIcons.check, c.success, l10n.compatYes),
      EsimSupport.likely => (AppIcons.info, c.warning, l10n.compatUnknown),
      EsimSupport.no => (AppIcons.error, c.error, l10n.compatNo),
      _ => (AppIcons.info, c.textSecondary, l10n.compatUnknown),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                HugeIcon(icon: icon, size: 20, color: tint),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: '${l10n.compatLabel} '),
                        TextSpan(
                          text: value,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    style: context.text.caption,
                  ),
                ),
                if (supportCubit.isModelBased && support != EsimSupport.likely)
                  TextButton(
                    onPressed: supportCubit.clearEidConfirmation,
                    child: Text(l10n.compatChangeEid),
                  )
                else if (support == null || support == EsimSupport.unknown)
                  TextButton(
                    onPressed: () => showCompatSheet(context),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(44, 44),
                      foregroundColor: c.link,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                    ),
                    child: Text(
                      l10n.compatHowToCheck,
                      style: context.text.caption.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            if (support == EsimSupport.likely)
              Padding(
                padding: const EdgeInsets.only(left: 20 + AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.compatLikely,
                      style: context.text.caption.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.sm,
                      children: [
                        TextButton(
                          onPressed: () =>
                              supportCubit.confirmEid(present: true),
                          child: Text(l10n.compatEidFound),
                        ),
                        TextButton(
                          onPressed: () =>
                              supportCubit.confirmEid(present: false),
                          child: Text(l10n.compatEidMissing),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
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

/// Red "device doesn't support eSIMs" row; opens [showUnsupportedSheet].
class _UnsupportedRow extends StatelessWidget {
  const _UnsupportedRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final label = context.l10n.compatNoRow;
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
                _IconDisc(icon: AppIcons.warning, color: c.error),
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
            Center(
              child: Container(
                width: 100,
                height: 100,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.warning.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: HugeIcon(
                  icon: AppIcons.warning,
                  size: 48,
                  color: c.textPrimary,
                ),
              ),
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

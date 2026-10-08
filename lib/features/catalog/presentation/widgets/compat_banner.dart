import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/services/esim_compatibility.dart';
import '../../../../core/services/esim_support_cubit.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';

/// "Device supports eSIM: Yes — How to check".
class CompatBanner extends StatelessWidget {
  const CompatBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final support = context.watch<EsimSupportCubit>().state;

    final (icon, tint, value) = switch (support) {
      EsimSupport.yes => (AppIcons.check, c.success, l10n.compatYes),
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
        child: Row(
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
            TextButton(
              onPressed: () => showCompatSheet(context),
              style: TextButton.styleFrom(
                minimumSize: const Size(44, 44),
                foregroundColor: c.link,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
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

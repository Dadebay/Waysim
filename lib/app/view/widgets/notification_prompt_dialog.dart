import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/extensions/context_extensions.dart';
import '../../../core/widgets/app_button.dart';

/// Our own card shown before the system notification dialog, so the customer
/// knows why we ask. Resolves `true` for "Turn on".
Future<bool> showNotificationPrompt(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _NotificationPromptDialog(),
  );
  return result ?? false;
}

class _NotificationPromptDialog extends StatelessWidget {
  const _NotificationPromptDialog();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    return Dialog(
      alignment: Alignment.bottomCenter,
      insetPadding: const EdgeInsets.all(AppSpacing.page),
      backgroundColor: c.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sheet),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.notifPromptTitle, style: context.text.h3),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.notifPromptBody,
              style: context.text.bodySm.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: l10n.notifPromptLater,
              variant: AppButtonVariant.secondary,
              onPressed: () => Navigator.of(context).pop(false),
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: l10n.notifPromptEnable,
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ),
    );
  }
}

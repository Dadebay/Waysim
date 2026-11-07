import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_icons.dart';
import '../theme/app_spacing.dart';
import '../utils/extensions/context_extensions.dart';
import 'app_toast.dart';

class CopyField extends StatelessWidget {
  const CopyField({
    super.key,
    required this.label,
    required this.value,
    this.copyValue,
    this.monospace = false,
  });

  final String label;
  final String value;

  final String? copyValue;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: c.border),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.lg,
          top: AppSpacing.sm,
          bottom: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: context.text.caption.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  SelectableText(
                    value,
                    style: context.text.bodyMed.copyWith(
                      fontWeight: FontWeight.w600,
                      fontFeatures: monospace
                          ? const [FontFeature.tabularFigures()]
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            Semantics(
              button: true,
              label: l10n.actionCopy,
              excludeSemantics: true,
              child: InkResponse(
                radius: 26,
                onTap: () async {
                  await Clipboard.setData(
                    ClipboardData(text: copyValue ?? value),
                  );
                  if (context.mounted) {
                    AppToast.show(context, l10n.toastCopied);
                  }
                },
                child: SizedBox(
                  width: 56,
                  height: 48,
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: c.background,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: c.border),
                      ),
                      child: Center(
                        child: HugeIcon(
                          icon: AppIcons.copy,
                          size: 20,
                          color: c.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

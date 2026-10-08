import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';

/// "How eSIM works": the four steps, as a sheet.
Future<void> showHowItWorksSheet(BuildContext context) {
  final l10n = context.l10n;
  return showAppSheet<void>(
    context,
    title: l10n.howTitle,
    closeLabel: l10n.actionClose,
    builder: (_) => const _HowItWorks(),
  );
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final steps = [
      (l10n.howStep1Title, l10n.howStep1Body),
      (l10n.howStep2Title, l10n.howStep2Body),
      (l10n.howStep3Title, l10n.howStep3Body),
      (l10n.howStep4Title, l10n.howStep4Body),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        0,
        AppSpacing.page,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, step) in steps.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: c.primarySubtle,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${i + 1}',
                      style: context.text.bodySm.copyWith(
                        color: c.link,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(step.$1, style: context.text.h3),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          step.$2,
                          style: context.text.bodySm.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          AppButton(
            label: l10n.actionGotIt,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

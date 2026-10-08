import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../utils/extensions/context_extensions.dart';

/// Colour family of a [StatusBadge].
enum StatusTone { neutral, info, warning, success, error }

/// Pill label for an eSIM, order or invitation status. Knows nothing about
/// what the status means — callers map their enum to a tone and a label.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.tone});

  final String label;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, fg) = switch (tone) {
      StatusTone.neutral => (c.surface, c.textSecondary),
      StatusTone.info => (c.primarySubtle, c.link),
      StatusTone.warning => (c.warningSubtle, c.warning),
      StatusTone.success => (c.successSubtle, c.successText),
      StatusTone.error => (c.errorSubtle, c.errorText),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: tone == StatusTone.neutral ? Border.all(color: c.border) : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 5,
        ),
        child: Text(
          label,
          maxLines: 2,
          textAlign: TextAlign.center,
          style: context.text.caption.copyWith(
            color: fg,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

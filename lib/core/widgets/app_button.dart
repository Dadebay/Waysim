import 'package:flutter/material.dart';

import '../constants/app_icons.dart';
import '../theme/app_spacing.dart';
import '../utils/extensions/context_extensions.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }

enum AppButtonSize {
  sm(44, 15),
  md(52, 16),
  lg(56, 16);

  const AppButtonSize(this.height, this.fontSize);

  /// Never below the 44 pt tap target.
  final double height;
  final double fontSize;
}

/// The design system's button: primary / secondary / ghost / danger in
/// sm · md · lg, with disabled and loading states. [onPressed] `null`
/// disables; [loading] swaps the label for a spinner and ignores taps.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.lg,
    this.loading = false,
    this.expand = true,
    this.icon,
    this.trailingIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool loading;

  /// Fill the available width (the default for lg/md call-to-action buttons).
  final bool expand;
  final AppIconData? icon;
  final AppIconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enabled = onPressed != null && !loading;

    final (bg, fg, pressed) = switch (variant) {
      AppButtonVariant.primary => (
        c.primary,
        c.textOnPrimary,
        c.primaryPressed,
      ),
      AppButtonVariant.secondary => (
        c.primarySubtle,
        c.link,
        c.primarySubtle.withValues(alpha: 0.7),
      ),
      AppButtonVariant.ghost => (Colors.transparent, c.link, c.primarySubtle),
      AppButtonVariant.danger => (c.error, c.textOnPrimary, c.error),
    };

    final disabledBg = variant == AppButtonVariant.ghost
        ? Colors.transparent
        : c.border;
    final disabledFg = c.textSecondary;

    final style = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size(0, size.height)),
      maximumSize: WidgetStatePropertyAll(Size(double.infinity, size.height)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      ),
      elevation: const WidgetStatePropertyAll(0),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
      ),
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? (loading ? bg : disabledBg)
            : states.contains(WidgetState.pressed)
            ? pressed
            : bg,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? (loading ? fg : disabledFg)
            : fg,
      ),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      textStyle: WidgetStatePropertyAll(
        context.text.label.copyWith(fontSize: size.fontSize),
      ),
    );

    final content = AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: loading
          ? SizedBox.square(
              key: const ValueKey('spinner'),
              dimension: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: fg),
            )
          : Row(
              key: const ValueKey('label'),
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  HugeIcon(
                    icon: icon!,
                    size: 20,
                    color: enabled ? fg : disabledFg,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (trailingIcon != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  HugeIcon(
                    icon: trailingIcon!,
                    size: 20,
                    color: enabled ? fg : disabledFg,
                  ),
                ],
              ],
            ),
    );

    final button = FilledButton(
      // While loading the button stays "enabled" visually but ignores taps.
      onPressed: loading ? () {} : onPressed,
      style: style,
      child: content,
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: IgnorePointer(
        ignoring: loading,
        child: expand
            ? SizedBox(width: double.infinity, child: button)
            : button,
      ),
    );
  }
}

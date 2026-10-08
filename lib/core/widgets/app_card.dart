import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../utils/extensions/context_extensions.dart';

/// Rounded (22) bordered surface; tappable when [onTap] is given.
/// [selected] draws the primary border and subtle fill used by a chosen
/// package. [elevated] adds the soft card shadow.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.selected = false,
    this.elevated = false,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.color,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool selected;
  final bool elevated;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final radius = BorderRadius.circular(AppRadius.card);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: color ?? (selected ? c.primarySubtle : c.background),
        borderRadius: radius,
        border: Border.all(
          color: selected ? c.primary : c.border,
          width: selected ? 1.5 : 1,
        ),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: c.shadow,
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

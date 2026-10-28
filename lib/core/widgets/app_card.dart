import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../utils/extensions/context_extensions.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.selected = false,
    this.elevated = false,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.color,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.linear,
    this.borderWidth,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool selected;
  final bool elevated;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Duration animationDuration;
  final Curve animationCurve;
  final double? borderWidth;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final radius = BorderRadius.circular(AppRadius.card);

    return AnimatedContainer(
      duration: animationDuration,
      curve: animationCurve,
      decoration: BoxDecoration(
        color: color ?? (selected ? c.primarySubtle : c.background),
        borderRadius: radius,
        border: Border.all(
          color: selected ? c.primary : c.border,
          width: borderWidth ?? (selected ? 1.5 : 1),
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

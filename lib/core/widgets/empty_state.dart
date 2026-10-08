import 'package:flutter/material.dart';

import '../constants/app_icons.dart';
import '../theme/app_spacing.dart';
import '../utils/extensions/context_extensions.dart';

/// Centered illustration-less empty state: icon, title, body, optional actions.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.actions = const [],
  });

  final AppIconData icon;
  final String title;
  final String? body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.page),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: c.primarySubtle,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: HugeIcon(icon: icon, size: 32, color: c.primary),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(title, style: context.text.h2, textAlign: TextAlign.center),
            if (body != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                body!,
                style: context.text.body.copyWith(color: c.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
            if (actions.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xxl),
              for (final (i, a) in actions.indexed) ...[
                if (i > 0) const SizedBox(height: AppSpacing.md),
                a,
              ],
            ],
          ],
        ),
      ),
    );
  }
}

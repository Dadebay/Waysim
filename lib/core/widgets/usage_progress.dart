import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../utils/extensions/context_extensions.dart';

class UsageProgress extends StatelessWidget {
  const UsageProgress({super.key, required this.remainingFraction});

  final double remainingFraction;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final value = remainingFraction.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Stack(
        children: [
          Container(height: 6, color: c.border),
          FractionallySizedBox(
            widthFactor: value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 6,
              color: value <= 0.1 ? c.warning : c.primary,
            ),
          ),
        ],
      ),
    );
  }
}

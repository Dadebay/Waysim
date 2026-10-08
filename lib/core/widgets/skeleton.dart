import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_spacing.dart';
import '../utils/extensions/context_extensions.dart';

/// Shimmering placeholder block. Wrap a group of [SkeletonBox]es in one
/// [Skeleton] so they animate together.
class Skeleton extends StatelessWidget {
  const Skeleton({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Shimmer.fromColors(
      baseColor: c.surface,
      highlightColor: c.border,
      period: const Duration(milliseconds: 1400),
      child: child,
    );
  }
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.radius = AppRadius.sm,
    this.circle = false,
  });

  final double? width;
  final double height;
  final double radius;
  final bool circle;

  @override
  Widget build(BuildContext context) => Container(
    width: circle ? height : width,
    height: height,
    decoration: BoxDecoration(
      // Opaque: Shimmer paints through this colour.
      color: Colors.white,
      shape: circle ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: circle ? null : BorderRadius.circular(radius),
    ),
  );
}

/// A list of destination-row skeletons (flag + two lines + price).
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.count = 6});

  final int count;

  @override
  Widget build(BuildContext context) => Skeleton(
    child: Column(
      children: [
        for (var i = 0; i < count; i++)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              children: [
                SkeletonBox(height: 40, circle: true),
                SizedBox(width: AppSpacing.md),
                Expanded(child: SkeletonBox(height: 16)),
                SizedBox(width: AppSpacing.xxl),
                SkeletonBox(width: 64, height: 16),
              ],
            ),
          ),
      ],
    ),
  );
}

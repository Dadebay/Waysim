import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_constants.dart';
import '../theme/app_spacing.dart';
import '../utils/extensions/context_extensions.dart';

/// Two-or-more option switch: Local / Regional, Unlimited / Data,
/// Current / Archive, Purchases / Top-ups.
///
/// Behaves like an iOS segmented control: one raised thumb slides to the new
/// segment on an ease-out curve instead of each segment lighting up on its
/// own, the labels fade between weights, a light haptic tick confirms the
/// change, and the thumb can be dragged across the segments.
class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const _padding = 4.0;
  static const _height = 44.0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final count = labels.length;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppConstants.animationBase;

    void select(int index) {
      final next = index.clamp(0, count - 1);
      if (next == selectedIndex) return;
      HapticFeedback.selectionClick();
      onChanged(next);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.button),
        border: Border.all(color: c.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(_padding),
        child: LayoutBuilder(
          builder: (context, box) {
            final segmentWidth = box.maxWidth / count;

            // Which segment a horizontal position falls in.
            int indexAt(double dx) => (dx / segmentWidth).floor();

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: (d) =>
                  select(indexAt(d.localPosition.dx)),
              child: SizedBox(
                height: _height,
                child: Stack(
                  children: [
                    // The thumb. Alignment runs -1..1 across the free space, so
                    // segment i of n sits at -1 + 2i/(n-1).
                    AnimatedAlign(
                      duration: duration,
                      curve: Curves.easeOutCubic,
                      alignment: Alignment(
                        count == 1 ? 0 : -1 + 2 * selectedIndex / (count - 1),
                        0,
                      ),
                      child: FractionallySizedBox(
                        widthFactor: 1 / count,
                        heightFactor: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: c.background,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            boxShadow: [
                              BoxShadow(
                                color: c.shadow,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (final (i, label) in labels.indexed)
                          Expanded(
                            child: Semantics(
                              button: true,
                              selected: i == selectedIndex,
                              label: label,
                              excludeSemantics: true,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => select(i),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                    ),
                                    child: AnimatedDefaultTextStyle(
                                      duration: duration,
                                      curve: Curves.easeOut,
                                      style: context.text.bodyMed.copyWith(
                                        fontWeight: i == selectedIndex
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: i == selectedIndex
                                            ? c.textPrimary
                                            : c.textSecondary,
                                      ),
                                      child: Text(
                                        label,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

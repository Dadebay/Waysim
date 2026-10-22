import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_spacing.dart';
import '../utils/extensions/context_extensions.dart';
import 'app_card.dart';

/// One plan in the package list: `5 GB  30 days ........ $5.99 (o)`.
class PackageTile extends StatelessWidget {
  const PackageTile({
    super.key,
    required this.volume,
    required this.duration,
    required this.price,
    required this.selected,
    required this.onTap,
    this.selectedDays,
    this.minDays,
    this.maxDays,
    this.onDaysChanged,
  });

  /// "5 GB" or "Unlimited".
  final String volume;

  /// "30 days" or "1 GB per day · 7 days".
  final String duration;
  final String price;
  final bool selected;
  final VoidCallback onTap;
  final int? selectedDays;
  final int? minDays;
  final int? maxDays;
  final ValueChanged<int>? onDaysChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final motionDuration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppConstants.animationBase;
    final canChooseDays =
        selectedDays != null &&
        minDays != null &&
        maxDays != null &&
        minDays! < maxDays! &&
        onDaysChanged != null;

    return Semantics(
      button: true,
      selected: selected,
      label: '$volume, $duration, $price',
      excludeSemantics: !canChooseDays,
      child: AppCard(
        selected: selected,
        onTap: onTap,
        animationDuration: motionDuration,
        animationCurve: Curves.easeInOutSine,
        borderWidth: 1.5,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Column(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.end,
                      spacing: AppSpacing.sm,
                      children: [
                        Text(volume, style: context.text.h3),
                        Text(
                          duration,
                          style: context.text.caption.copyWith(
                            color: c.textSecondary,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    price,
                    style: context.text.bodyMed.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _Radio(selected: selected, duration: motionDuration),
                ],
              ),
            ),
            if (canChooseDays) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    context.l10n.durationDays(selectedDays!),
                    style: context.text.bodySm,
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: selectedDays! <= minDays!
                        ? null
                        : context.l10n.durationDays(selectedDays! - 1),
                    onPressed: selectedDays! <= minDays!
                        ? null
                        : () => onDaysChanged!(selectedDays! - 1),
                    icon: const Icon(Icons.remove_rounded),
                  ),
                  IconButton(
                    tooltip: selectedDays! >= maxDays!
                        ? null
                        : context.l10n.durationDays(selectedDays! + 1),
                    onPressed: selectedDays! >= maxDays!
                        ? null
                        : () => onDaysChanged!(selectedDays! + 1),
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.selected, required this.duration});

  final bool selected;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AnimatedContainer(
      duration: duration,
      curve: Curves.easeInOutSine,
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? c.primary : c.border,
          width: selected ? 6.5 : 1.5,
        ),
        color: c.background,
      ),
    );
  }
}

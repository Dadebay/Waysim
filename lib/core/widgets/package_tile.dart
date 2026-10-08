import 'package:flutter/material.dart';

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
  });

  /// "5 GB" or "Unlimited".
  final String volume;

  /// "30 days" or "1 GB per day · 7 days".
  final String duration;
  final String price;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Semantics(
      button: true,
      selected: selected,
      label: '$volume, $duration, $price',
      excludeSemantics: true,
      child: AppCard(
        selected: selected,
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: ConstrainedBox(
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
              _Radio(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
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

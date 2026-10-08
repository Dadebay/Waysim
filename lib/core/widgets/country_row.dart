import 'package:flutter/material.dart';

import '../constants/app_icons.dart';
import '../theme/app_spacing.dart';
import '../utils/extensions/context_extensions.dart';

/// A destination in a list: leading flag/globe, name (+ optional subtitle,
/// e.g. "20 countries"), the lowest price and a chevron.
class CountryRow extends StatelessWidget {
  const CountryRow({
    super.key,
    required this.leading,
    required this.title,
    required this.price,
    required this.onTap,
    this.subtitle,
    this.pricePrefix = '',
    this.priceSuffix = '',
    this.highlight,
    this.showChevron = true,
  });

  final Widget leading;
  final String title;
  final String? subtitle;

  /// The price figure, already formatted (`$1.99`).
  final String price;

  /// Words around the price, from the translated "from {price}" template
  /// ("from " / "" in English, "" / " 起" in Chinese).
  final String pricePrefix;
  final String priceSuffix;
  final VoidCallback onTap;

  /// Characters of [title] to emphasise (search match), as a prefix length.
  final int? highlight;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    Widget titleText = Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.text.bodyMed.copyWith(fontWeight: FontWeight.w600),
    );
    final h = highlight;
    if (h != null && h > 0 && h <= title.length) {
      titleText = Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: title.substring(0, h),
              style: TextStyle(color: c.link),
            ),
            TextSpan(text: title.substring(h)),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.text.bodyMed.copyWith(fontWeight: FontWeight.w600),
      );
    }

    return Semantics(
      button: true,
      label: [title, ?subtitle, '$pricePrefix$price$priceSuffix'].join(', '),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: [
                leading,
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleText,
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.caption.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text.rich(
                  TextSpan(
                    children: [
                      if (pricePrefix.isNotEmpty)
                        TextSpan(
                          text: pricePrefix,
                          style: context.text.bodySm.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                      TextSpan(
                        text: price,
                        style: context.text.bodyMed.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (priceSuffix.isNotEmpty)
                        TextSpan(
                          text: priceSuffix,
                          style: context.text.bodySm.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                if (showChevron) ...[
                  const SizedBox(width: AppSpacing.sm),
                  HugeIcon(
                    icon: AppIcons.chevronRight,
                    size: 18,
                    color: c.textSecondary,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Round globe used for regions and as the stand-in for a missing flag.
class RegionIcon extends StatelessWidget {
  const RegionIcon({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: c.primarySubtle, shape: BoxShape.circle),
      child: Center(
        child: HugeIcon(
          icon: AppIcons.globe,
          size: size * 0.52,
          color: c.primary,
        ),
      ),
    );
  }
}

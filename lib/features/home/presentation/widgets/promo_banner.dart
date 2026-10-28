import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

enum PromoTone { primary, subtle }

class PromoBanner extends StatelessWidget {
  const PromoBanner({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.body,
    this.action,
    this.tone = PromoTone.primary,
    this.compact = false,
  });

  final String title;
  final String? body;
  final String? action;
  final AppIconData icon;
  final PromoTone tone;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final filled = tone == PromoTone.primary;
    final bg = filled ? c.primary : c.primarySubtle;
    final fg = filled ? c.textOnPrimary : c.link;
    final tile = filled
        ? c.textOnPrimary.withValues(alpha: 0.16)
        : c.background;
    final iconTile = Container(
      width: compact ? 36 : 44,
      height: compact ? 36 : 44,
      decoration: BoxDecoration(
        color: tile,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Center(
        child: HugeIcon(icon: icon, size: compact ? 20 : 24, color: fg),
      ),
    );

    return Semantics(
      button: true,
      label: [title, ?body, ?action].join('. '),
      excludeSemantics: true,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.card),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Positioned(
                right: -48,
                top: -48,
                child: Container(
                  width: 168,
                  height: 168,
                  decoration: BoxDecoration(
                    color: fg.withValues(alpha: filled ? 0.10 : 0.06),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              if (compact)
                Positioned(
                  right: AppSpacing.lg,
                  top: AppSpacing.lg,
                  child: iconTile,
                ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!compact) iconTile,
                    const Spacer(),
                    Text(
                      title,
                      maxLines: compact ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                      style: (compact ? context.text.h3 : context.text.h2)
                          .copyWith(color: fg),
                    ),
                    if (body != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        body!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySm.copyWith(
                          color: fg.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                    if (action != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        action!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySm.copyWith(
                          color: fg,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

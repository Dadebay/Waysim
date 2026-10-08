import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

enum PromoTone { primary, subtle }

/// One square banner of the Home carousel. Content and action come from the
/// server (title, body, destination); the layout is fixed.
class PromoBanner extends StatelessWidget {
  const PromoBanner({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.body,
    this.action,
    this.tone = PromoTone.primary,
  });

  final String title;
  final String? body;
  final String? action;
  final AppIconData icon;
  final PromoTone tone;
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
              // A large soft circle, the design's only decoration.
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
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: tile,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Center(
                        child: HugeIcon(icon: icon, size: 24, color: fg),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.h2.copyWith(color: fg),
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

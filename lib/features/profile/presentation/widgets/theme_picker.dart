import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_color_tokens.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class ThemePicker extends StatelessWidget {
  const ThemePicker({super.key, required this.mode, required this.onChanged});

  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dark = mode == ThemeMode.dark;

    void choose(ThemeMode next) {
      if (next == mode) return;
      HapticFeedback.selectionClick();
      onChanged(next);
    }

    return Row(
      children: [
        Expanded(
          child: _ThemeCard(
            label: l10n.themeLight,
            icon: AppIcons.sun,
            tokens: AppColorTokens.light,
            selected: !dark,
            onTap: () => choose(ThemeMode.light),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _ThemeCard(
            label: l10n.themeDark,
            icon: AppIcons.moon,
            tokens: AppColorTokens.dark,
            selected: dark,
            onTap: () => choose(ThemeMode.dark),
          ),
        ),
      ],
    );
  }
}

class _ThemeCard extends StatefulWidget {
  const _ThemeCard({
    required this.label,
    required this.icon,
    required this.tokens,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final AppIconData icon;

  final AppColorTokens tokens;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_ThemeCard> createState() => _ThemeCardState();
}

class _ThemeCardState extends State<_ThemeCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion ? Duration.zero : AppConstants.animationBase;
    final radius = BorderRadius.circular(AppRadius.card);

    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.label,
      excludeSemantics: true,
      child: AnimatedScale(
        scale: _pressed && !reduceMotion ? 0.97 : 1,
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: duration,
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: widget.selected ? c.primarySubtle : c.background,
            borderRadius: radius,
            border: Border.all(
              color: widget.selected ? c.primary : c.border,

              width: 1.5,
            ),
            boxShadow: widget.selected
                ? [
                    BoxShadow(
                      color: c.primary.withValues(alpha: 0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : const [],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: radius,
              excludeFromSemantics: true,
              onHighlightChanged: (pressed) =>
                  setState(() => _pressed = pressed),
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    _Preview(tokens: widget.tokens),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        HugeIcon(
                          icon: widget.icon,
                          size: 20,
                          color: widget.selected ? c.link : c.textSecondary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            widget.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.bodyMed.copyWith(
                              fontWeight: FontWeight.w700,
                              color: widget.selected ? c.link : c.textPrimary,
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          duration: duration,
                          curve: Curves.easeOutCubic,
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.selected
                                ? c.primary
                                : Colors.transparent,
                            border: Border.all(
                              color: widget.selected ? c.primary : c.border,
                              width: 1.5,
                            ),
                          ),
                          child: AnimatedOpacity(
                            opacity: widget.selected ? 1 : 0,
                            duration: duration,
                            curve: Curves.easeOutCubic,
                            child: AnimatedScale(
                              scale: widget.selected ? 1 : 0.9,
                              duration: duration,
                              curve: Curves.easeOutCubic,
                              child: Center(
                                child: HugeIcon(
                                  icon: AppIcons.check,
                                  size: 13,
                                  color: c.textOnPrimary,
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
            ),
          ),
        ),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.tokens});

  final AppColorTokens tokens;

  @override
  Widget build(BuildContext context) {
    Widget bar(double width, Color color, {double height = 6}) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
    );

    return ExcludeSemantics(
      child: AspectRatio(
        aspectRatio: 1.35,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: tokens.background,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: tokens.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  bar(34, tokens.textPrimary, height: 7),
                  Container(
                    width: 22,
                    height: 10,
                    decoration: BoxDecoration(
                      color: tokens.primarySubtle,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: tokens.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: bar(40, tokens.textOnPrimary, height: 6),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: tokens.primarySubtle,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  bar(46, tokens.textSecondary),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: tokens.primarySubtle,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  bar(32, tokens.textSecondary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

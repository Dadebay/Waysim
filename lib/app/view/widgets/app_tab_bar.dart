import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/extensions/context_extensions.dart';

class AppTabBar extends StatelessWidget {
  const AppTabBar({
    super.key,
    required this.currentIndex,
    required this.onSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onSelected;

  static const _itemHeight = 64.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final items = [
      (AppIcons.home, l10n.tabHome),
      (AppIcons.myEsim, l10n.tabMyEsim),
      (AppIcons.profile, l10n.tabProfile),
    ];

    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppConstants.animationBase;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: _itemHeight,
          child: Row(
            children: [
              for (final (index, item) in items.indexed)
                Expanded(
                  child: _TabItem(
                    index: index,
                    icon: item.$1,
                    label: item.$2,
                    selected: index == currentIndex,
                    duration: duration,
                    onTap: () {
                      if (index != currentIndex) {
                        HapticFeedback.selectionClick();
                      }
                      onSelected(index);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatefulWidget {
  const _TabItem({
    required this.index,
    required this.icon,
    required this.label,
    required this.selected,
    required this.duration,
    required this.onTap,
  });

  final int index;
  final AppIconData icon;
  final String label;
  final bool selected;
  final Duration duration;
  final VoidCallback onTap;

  @override
  State<_TabItem> createState() => _TabItemState();
}

class _TabItemState extends State<_TabItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tap = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );
  bool _pressed = false;

  @override
  void dispose() {
    _tap.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.duration != Duration.zero) _tap.forward(from: 0);
    widget.onTap();
  }

  Widget _animated(Widget child) {
    return AnimatedBuilder(
      animation: _tap,
      child: child,
      builder: (context, child) {
        final t = _tap.value;
        final decay = 1 - t;
        var dy = 0.0;
        var angle = 0.0;
        var scale = 1.0;
        switch (widget.index) {
          case 0:
            dy = -8 * math.sin(t * math.pi) * decay;
          case 1:
            angle = 0.35 * math.sin(t * math.pi * 4) * decay;
          default:
            scale = 1 + 0.3 * math.sin(t * math.pi) * decay;
        }
        return Transform.translate(
          offset: Offset(0, dy),
          child: Transform.rotate(
            angle: angle,
            child: Transform.scale(scale: scale, child: child),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final selected = widget.selected;
    final duration = widget.duration;
    final icon = widget.icon;
    final label = widget.label;
    final color = selected ? colors.link : colors.textSecondary;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: _handleTap,
        onHighlightChanged: (value) => setState(() => _pressed = value),
        containedInkWell: true,
        highlightShape: BoxShape.rectangle,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppConstants.minTapTarget,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: duration,
                curve: Curves.easeOutCubic,
                width: selected ? 56 : 28,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? colors.primarySubtle : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: selected ? 1.0 : 0.0),
                  duration: duration,
                  curve: Curves.easeOutBack,
                  builder: (context, t, child) =>
                      Transform.scale(scale: 1 + 0.1 * t, child: child),
                  child: AnimatedScale(
                    scale: _pressed ? 0.8 : 1,
                    duration: const Duration(milliseconds: 90),
                    child: _animated(
                      HugeIcon(icon: icon, size: 24, color: color),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: duration,
                style: context.text.caption.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/extensions/context_extensions.dart';

/// Bottom tab bar: Home · My eSIM · Profile.
///
/// The selected tab has a soft pill behind its icon and uses the brand colour
/// for its icon and bold label.
/// A light haptic tick confirms the change, as on iOS.
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

    // Reduce Motion: the state still changes, only the movement is dropped.
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppConstants.animationBase;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(top: BorderSide(color: colors.border)),
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

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.duration,
    required this.onTap,
  });

  final AppIconData icon;
  final String label;
  final bool selected;
  final Duration duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = selected ? colors.link : colors.textSecondary;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
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
              // The pill grows from nothing behind the icon; the icon gives a
              // small bounce as it becomes selected.
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
                  child: HugeIcon(icon: icon, size: 24, color: color),
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

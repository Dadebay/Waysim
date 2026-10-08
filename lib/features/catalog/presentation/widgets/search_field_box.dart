import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// The rounded search box, shared by the Home tab (resting) and the search
/// page (focused, in the app bar). [focus] runs 0 → 1 between the two looks —
/// border colour and weight, fill — so a flying copy can sit anywhere in
/// between and the box never "jumps" between two different designs.
class SearchFieldBox extends StatelessWidget {
  const SearchFieldBox({super.key, required this.child, this.focus = 0});

  final Widget child;

  /// 0 = Home look, 1 = search-page look.
  final double focus;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.only(left: AppSpacing.lg),
      decoration: BoxDecoration(
        color: Color.lerp(c.surface, c.background, focus),
        border: Border.all(
          color: Color.lerp(c.border, c.primary, focus)!,
          width: 1 + 0.5 * focus,
        ),
        borderRadius: BorderRadius.circular(AppRadius.button),
        boxShadow: focus > 0
            ? [
                BoxShadow(
                  color: c.primary.withValues(alpha: 0.12 * focus),
                  blurRadius: 0,
                  spreadRadius: 4 * focus,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

/// Magnifier + placeholder: what both ends of the flight show, so the flying
/// copy needs no live text field (and no keyboard, no focus).
class SearchFieldHint extends StatelessWidget {
  const SearchFieldHint({super.key, required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        HugeIcon(icon: AppIcons.search, size: 20, color: c.textSecondary),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            hint,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.bodyMed.copyWith(color: c.textSecondary),
          ),
        ),
      ],
    );
  }
}

/// The tag both ends of the search flight share.
const searchFieldHeroTag = 'search-field';

/// An ease-out that starts fast and settles gently — close to the curve iOS
/// uses for navigation — applied to the flying rectangle.
class SearchFlightRectTween extends RectTween {
  SearchFlightRectTween({super.begin, super.end});

  static const _curve = Cubic(0.22, 1.0, 0.36, 1.0);

  @override
  Rect? lerp(double t) => super.lerp(_curve.transform(t));
}

/// What flies between the Home field and the search page's field.
Widget searchFlightShuttle(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection direction,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  final hint = flightContext.l10n.searchHint;
  return Material(
    type: MaterialType.transparency,
    child: AnimatedBuilder(
      animation: animation,
      // 0 at the Home end, 1 at the search page end, in either direction.
      builder: (context, _) => SearchFieldBox(
        focus: animation.value.clamp(0.0, 1.0),
        child: SearchFieldHint(hint: hint),
      ),
    ),
  );
}

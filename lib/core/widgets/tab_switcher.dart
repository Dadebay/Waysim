import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

/// Swaps the content under a segmented control with a short slide and fade
/// that follows the tab: moving to a tab on the right brings the new content
/// in from the right and sends the old one out to the left, and the reverse.
class TabSwitcher extends StatefulWidget {
  const TabSwitcher({super.key, required this.index, required this.child});

  /// The selected tab; changing it triggers the transition.
  final int index;

  /// The content for [index].
  final Widget child;

  @override
  State<TabSwitcher> createState() => _TabSwitcherState();
}

class _TabSwitcherState extends State<TabSwitcher> {
  /// +1 when the last change went to a higher tab, -1 to a lower one.
  int _direction = 1;

  @override
  void didUpdateWidget(TabSwitcher old) {
    super.didUpdateWidget(old);
    if (widget.index != old.index) {
      _direction = widget.index > old.index ? 1 : -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    final currentKey = ValueKey<int>(widget.index);

    return AnimatedSwitcher(
      duration: reduce ? Duration.zero : AppConstants.animationBase,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      // The old and new content share the same box while they cross over.
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.topCenter,
        // Keep the constraints the parent gave (a list inside Expanded must
        // still fill it).
        fit: StackFit.passthrough,
        children: [...previous, ?current],
      ),
      transitionBuilder: (child, animation) {
        final incoming = child.key == currentKey;
        // The incoming content starts on the side the tab is heading to; the
        // outgoing one leaves towards the opposite side.
        final side = incoming ? _direction : -_direction;
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0.08 * side, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(key: currentKey, child: widget.child),
    );
  }
}

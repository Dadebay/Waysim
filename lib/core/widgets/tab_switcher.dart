import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

class TabSwitcher extends StatefulWidget {
  const TabSwitcher({super.key, required this.index, required this.child});

  final int index;

  final Widget child;

  @override
  State<TabSwitcher> createState() => _TabSwitcherState();
}

class _TabSwitcherState extends State<TabSwitcher> {
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

      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.topCenter,

        fit: StackFit.passthrough,
        children: [...previous, ?current],
      ),
      transitionBuilder: (child, animation) {
        final incoming = child.key == currentKey;

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

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class SimRefreshIndicator extends StatefulWidget {
  const SimRefreshIndicator({super.key, required this.active});

  final bool active;

  @override
  State<SimRefreshIndicator> createState() => _SimRefreshIndicatorState();
}

class _SimRefreshIndicatorState extends State<SimRefreshIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(SimRefreshIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) _syncAnimation();
  }

  void _syncAnimation() {
    if (widget.active && !MediaQuery.disableAnimationsOf(context)) {
      if (!_pulse.isAnimating) _pulse.repeat();
    } else {
      _pulse.stop();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      label: MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
      liveRegion: widget.active,
      excludeSemantics: true,
      child: Center(
        child: SizedBox(
          width: 68,
          height: 68,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (widget.active)
                SizedBox.square(
                  dimension: 68,
                  child: CircularProgressIndicator(
                    key: const ValueKey('sim-refresh-ring'),
                    value: reduceMotion ? 0.75 : null,
                    color: c.primary,
                    backgroundColor: c.primarySubtle,
                    strokeWidth: 3,
                  ),
                ),
              AnimatedBuilder(
                animation: _pulse,
                builder: (context, _) {
                  final wave = widget.active && !reduceMotion
                      ? math.sin(_pulse.value * math.pi * 2)
                      : 0.0;
                  return Transform.translate(
                    key: const ValueKey('sim-refresh-motion'),
                    offset: Offset(0, -3 * wave),
                    child: Transform.rotate(
                      angle: 0.10 * wave,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: c.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: c.border),
                          boxShadow: [
                            BoxShadow(
                              color: c.shadow,
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Center(
                            child: HugeIcon(
                              icon: AppIcons.myEsim,
                              size: 30,
                              color: c.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

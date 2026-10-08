import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_icons.dart';
import '../utils/extensions/context_extensions.dart';

/// Looping "no connection" artwork drawn in code (no Lottie file to ship, and
/// it follows the light/dark theme): an eSIM card that floats while signal
/// rings keep reaching out from it, and a small "offline" badge that wobbles
/// on its corner.
///
/// Holds still when the system asks to reduce motion.
class NoConnectionArt extends StatefulWidget {
  const NoConnectionArt({super.key, this.size = 260});

  final double size;

  @override
  State<NoConnectionArt> createState() => _NoConnectionArtState();
}

class _NoConnectionArtState extends State<NoConnectionArt>
    with SingleTickerProviderStateMixin {
  static const _period = Duration(milliseconds: 3600);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _period,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..stop()
        ..value = 0.18;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final size = widget.size;
    final cardWidth = size * 0.4;
    final cardHeight = cardWidth * 1.28;

    return Semantics(
      image: true,
      label: context.l10n.noConnectionTitle,
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: size,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value;
              final float = math.sin(t * 2 * math.pi) * size * 0.022;
              // The badge shakes for a moment, then rests.
              final shakePhase = (t * 2) % 1;
              final shake = shakePhase < 0.35
                  ? math.sin(shakePhase / 0.35 * 4 * math.pi) *
                        (1 - shakePhase / 0.35) *
                        0.28
                  : 0.0;

              return Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _RingsPainter(
                        progress: t,
                        color: c.primary,
                        floorColor: c.primarySubtle,
                        coreRadius: cardHeight * 0.62,
                      ),
                    ),
                  ),
                  // Soft shadow on the "floor", breathing opposite to the card.
                  Positioned(
                    bottom: size * 0.17,
                    child: Container(
                      width: cardWidth * (0.8 - float / size * 3),
                      height: size * 0.035,
                      decoration: BoxDecoration(
                        color: c.shadow,
                        borderRadius: BorderRadius.circular(size),
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(0, float),
                    child: SizedBox(
                      width: cardWidth + size * 0.1,
                      height: cardHeight + size * 0.05,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: 0,
                            bottom: 0,
                            child: _SimCard(
                              width: cardWidth,
                              height: cardHeight,
                              color: c.primary,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Transform.rotate(
                              angle: shake,
                              child: _OfflineBadge(size: size * 0.22),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Concentric rings that grow out of the card and fade, three at a time.
class _RingsPainter extends CustomPainter {
  _RingsPainter({
    required this.progress,
    required this.color,
    required this.floorColor,
    required this.coreRadius,
  });

  final double progress;
  final Color color;
  final Color floorColor;
  final double coreRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxRadius = size.shortestSide / 2;

    canvas.drawCircle(center, coreRadius, Paint()..color = floorColor);

    for (var i = 0; i < 3; i++) {
      final phase = (progress + i / 3) % 1;
      final eased = Curves.easeOutCubic.transform(phase);
      final radius = coreRadius + (maxRadius - coreRadius) * eased;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = color.withValues(alpha: (1 - phase) * 0.32),
      );
    }
  }

  @override
  bool shouldRepaint(_RingsPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.floorColor != floorColor ||
      old.coreRadius != coreRadius;
}

/// A SIM-shaped card: cut corner, brand mark, gold contact chip.
class _SimCard extends StatelessWidget {
  const _SimCard({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _SimPainter(color: color, shadow: context.colors.shadow),
          ),
        ),
        Positioned(
          left: width * 0.14,
          top: height * 0.14,
          child: SvgPicture.asset(
            'assets/brand/mark_white.svg',
            width: width * 0.34,
          ),
        ),
        Positioned(
          left: width * 0.5 - width * 0.23,
          bottom: height * 0.12,
          child: _Chip(width: width * 0.46, height: height * 0.3),
        ),
      ],
    ),
  );
}

class _SimPainter extends CustomPainter {
  _SimPainter({required this.color, required this.shadow});

  final Color color;
  final Color shadow;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width * 0.14;
    final cut = size.width * 0.3;
    final path = Path()
      ..moveTo(radius, 0)
      ..lineTo(size.width - cut, 0)
      ..lineTo(size.width, cut)
      ..lineTo(size.width, size.height - radius)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width - radius,
        size.height,
      )
      ..lineTo(radius, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - radius)
      ..lineTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..close();

    canvas.drawShadow(path, shadow, 14, true);
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(color, Colors.white, 0.14)!,
            Color.lerp(color, Colors.black, 0.18)!,
          ],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(_SimPainter old) =>
      old.color != color || old.shadow != shadow;
}

class _Chip extends StatelessWidget {
  const _Chip({required this.width, required this.height});

  final double width;
  final double height;

  static const _gold = Color(0xFFF2B84B);

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: _gold,
      borderRadius: BorderRadius.circular(width * 0.16),
    ),
    child: CustomPaint(painter: _ChipLinesPainter()),
  );
}

class _ChipLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0x33000000);
    canvas
      ..drawLine(
        Offset(size.width * 0.34, 0),
        Offset(size.width * 0.34, size.height),
        line,
      )
      ..drawLine(
        Offset(size.width * 0.66, 0),
        Offset(size.width * 0.66, size.height),
        line,
      )
      ..drawLine(
        Offset(0, size.height * 0.5),
        Offset(size.width, size.height * 0.5),
        line,
      );
  }

  @override
  bool shouldRepaint(_ChipLinesPainter old) => false;
}

class _OfflineBadge extends StatelessWidget {
  const _OfflineBadge({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: c.background,
        shape: BoxShape.circle,
        border: Border.all(color: c.warning.withValues(alpha: 0.35), width: 2),
        boxShadow: [
          BoxShadow(
            color: c.shadow,
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: HugeIcon(
          icon: AppIcons.offline,
          size: size * 0.5,
          color: c.warning,
        ),
      ),
    );
  }
}

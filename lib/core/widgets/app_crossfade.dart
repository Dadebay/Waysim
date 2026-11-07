import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../constants/app_constants.dart';

enum AppScreenTransition { crossfade, revealFromLeft, revealFromRight }

class AppCrossfade extends StatefulWidget {
  const AppCrossfade({super.key, required this.child});

  final Widget child;

  static AppCrossfadeState? of(BuildContext context) =>
      context.findAncestorStateOfType<AppCrossfadeState>();

  @override
  State<AppCrossfade> createState() => AppCrossfadeState();
}

class AppCrossfadeState extends State<AppCrossfade>
    with SingleTickerProviderStateMixin {
  final _boundary = GlobalKey();

  late final AnimationController _fade;
  late final CurvedAnimation _fadeCurve;
  late final Animation<double> _oldScreenOpacity;

  @override
  void initState() {
    super.initState();
    _fade = AnimationController(
      vsync: this,
      duration: AppConstants.animationBase,
    );
    _fadeCurve = CurvedAnimation(parent: _fade, curve: Curves.easeOutCubic);
    _oldScreenOpacity = ReverseAnimation(_fadeCurve);
  }

  ui.Image? _snapshot;
  AppScreenTransition _transition = AppScreenTransition.crossfade;
  bool _busy = false;

  static const _captureTimeout = Duration(milliseconds: 350);

  Future<void> run(
    VoidCallback change, {
    AppScreenTransition transition = AppScreenTransition.crossfade,
    Duration? duration,
  }) async {
    if (_busy) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      change();
      return;
    }
    _busy = true;
    try {
      var captureTimedOut = false;
      final capture = _capture();
      unawaited(
        capture.then((lateImage) {
          if (captureTimedOut) lateImage?.dispose();
        }),
      );
      final image = await capture.timeout(
        _captureTimeout,
        onTimeout: () {
          captureTimedOut = true;
          return null;
        },
      );
      if (!mounted) {
        image?.dispose();
        return;
      }
      if (image == null) {
        change();
        return;
      }

      _fade.duration =
          duration ??
          (transition != AppScreenTransition.crossfade
              ? AppConstants.animationSlow
              : AppConstants.animationBase);

      _fade.value = 0;

      setState(() {
        _transition = transition;
        _snapshot = image;
      });
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;

      change();
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;

      if (transition != AppScreenTransition.crossfade) {
        await Future<void>.delayed(AppConstants.themeFallbackAnimation);
        if (!mounted) return;
      }

      await _fade.forward().orCancel;
      // ignore: empty_catches
    } on TickerCanceled {
    } finally {
      _busy = false;
      final old = _snapshot;
      if (mounted) {
        setState(() => _snapshot = null);
      } else {
        _snapshot = null;
      }
      old?.dispose();
    }
  }

  @visibleForTesting
  static Future<ui.Image?> Function()? debugCapture;

  Future<ui.Image?> _capture() async {
    try {
      var boundary =
          _boundary.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return null;
      for (
        var attempt = 0;
        attempt < 3 && boundary!.debugNeedsPaint;
        attempt++
      ) {
        await WidgetsBinding.instance.endOfFrame;
        if (!mounted) return null;
        boundary =
            _boundary.currentContext?.findRenderObject()
                as RenderRepaintBoundary?;
        if (boundary == null) return null;
      }
      if (boundary == null || boundary.debugNeedsPaint) return null;
      final override = debugCapture;
      if (override != null) return await override();
      final ratio = MediaQuery.devicePixelRatioOf(context).clamp(1.0, 2.0);
      return await boundary.toImage(pixelRatio: ratio);
    } on Object {
      return null;
    }
  }

  @override
  void dispose() {
    _fadeCurve.dispose();
    _fade.dispose();
    _snapshot?.dispose();
    _snapshot = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        RepaintBoundary(key: _boundary, child: widget.child),
        if (_snapshot != null)
          Positioned.fill(
            child: AbsorbPointer(
              child: _transition != AppScreenTransition.crossfade
                  ? AnimatedBuilder(
                      animation: _fade,
                      builder: (context, child) => ClipRect(
                        clipper: _RevealClipper(
                          progress: Curves.easeInOutCubic.transform(
                            _fade.value,
                          ),
                          fromLeft:
                              _transition == AppScreenTransition.revealFromLeft,
                        ),
                        child: child,
                      ),
                      child: RawImage(image: _snapshot, fit: BoxFit.fill),
                    )
                  : FadeTransition(
                      opacity: _oldScreenOpacity,
                      child: RawImage(image: _snapshot, fit: BoxFit.fill),
                    ),
            ),
          ),
      ],
    );
  }
}

class _RevealClipper extends CustomClipper<Rect> {
  const _RevealClipper({required this.progress, required this.fromLeft});

  final double progress;
  final bool fromLeft;

  @override
  Rect getClip(Size size) => fromLeft
      ? Rect.fromLTRB(size.width * progress, 0, size.width, size.height)
      : Rect.fromLTRB(0, 0, size.width * (1 - progress), size.height);

  @override
  bool shouldReclip(_RevealClipper oldClipper) =>
      progress != oldClipper.progress || fromLeft != oldClipper.fromLeft;
}

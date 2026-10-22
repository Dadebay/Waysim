import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../constants/app_constants.dart';

enum AppScreenTransition { crossfade, revealFromLeft, revealFromRight }

/// Transitions the whole app across a change that rebuilds every screen at
/// once, such as switching the language or theme.
///
/// A new locale replaces every string in one frame, which looks like a flash.
/// There is no way to animate "all text changed" widget by widget, so this
/// does what iOS does: photograph the screen, change the language underneath,
/// and fade or wipe the photograph away over the freshly drawn result.
///
/// Sits above the navigator, below `Localizations`:
/// `AppCrossfade.of(context)?.run(() => cubit.setLocale(...))`.
class AppCrossfade extends StatefulWidget {
  const AppCrossfade({super.key, required this.child});

  final Widget child;

  /// The nearest one, or `null` outside the app (a bare test page).
  static AppCrossfadeState? of(BuildContext context) =>
      context.findAncestorStateOfType<AppCrossfadeState>();

  @override
  State<AppCrossfade> createState() => AppCrossfadeState();
}

class AppCrossfadeState extends State<AppCrossfade>
    with SingleTickerProviderStateMixin {
  final _boundary = GlobalKey();
  // Created up front: a lazily created controller would first be built inside
  // dispose() when the fade was never used.
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

  /// The tap may still be painting its pressed state. Allow that frame and
  /// the screenshot to complete before falling back to an immediate change.
  static const _captureTimeout = Duration(milliseconds: 350);

  /// Runs [change] beneath a snapshot, preserving the live screen's state.
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
      // A completed transition leaves the controller at 1. Reset BEFORE
      // mounting the next snapshot, or the old screen flashes through.
      _fade.value = 0;
      // The photograph covers the old screen while the new one is drawn.
      setState(() {
        _transition = transition;
        _snapshot = image;
      });
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;

      // Underneath, the new language or theme is drawn.
      change();
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;

      // MaterialApp also animates a theme when a screenshot cannot be taken.
      // When the screenshot is available, let that fallback finish behind it
      // before revealing the new screen.
      if (transition != AppScreenTransition.crossfade) {
        await Future<void>.delayed(AppConstants.themeFallbackAnimation);
        if (!mounted) return;
      }

      // The photograph fades or wipes away to reveal the new screen.
      await _fade.forward().orCancel;
    } on TickerCanceled {
      // The app or route containing the transition was removed.
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

  /// Tests replace the screenshot (the real one needs the real engine).
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

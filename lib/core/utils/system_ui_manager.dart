import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Keeps Android's navigation bar hidden (the status bar stays), as in the
/// other apps.
///
/// [SystemUiMode.manual] hides the bar, but a swipe from the bottom edge
/// brings it back *and leaves it there* — Android only re-hides it by
/// itself in the immersive modes, and those also take the status bar with
/// them, which the design keeps. So the bar coming back is detected and the
/// mode re-applied a few seconds later.
///
/// [SystemChrome.setSystemUIChangeCallback] is not an option here: with
/// [SystemUiMode.manual] it only fires when *every* overlay is hidden.
class SystemUiManager with WidgetsBindingObserver {
  SystemUiManager({this.hideDelay = const Duration(seconds: 3)});

  static const _androidUi = MethodChannel('com.waysim.app/system_ui');

  /// How long the bar stays visible after the user swipes it up.
  final Duration hideDelay;

  Timer? _timer;
  bool _nativeChannelAvailable = true;

  /// Applies the mode and starts watching for the bar coming back.
  Future<void> start() async {
    WidgetsBinding.instance.addObserver(this);
    await apply();
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    WidgetsBinding.instance.removeObserver(this);
  }

  /// Status bar stays, navigation bar goes. Harmless on iOS, which has no
  /// navigation bar to hide (the home indicator is not affected).
  Future<void> apply() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top],
    );
    // Android 15+ may ignore Flutter's manual mode. Ask the activity to hide
    // only its navigation bar through WindowInsetsController as well.
    if (!kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android &&
        _nativeChannelAvailable) {
      try {
        await _androidUi.invokeMethod<void>('hideNavigationBar');
      } on MissingPluginException {
        // A hot-reloaded Dart isolate may still be attached to an older APK
        // without this native channel. Keep the Flutter fallback and avoid
        // reporting a fatal error on every lifecycle/metrics callback.
        _nativeChannelAvailable = false;
      }
    }
  }

  @override
  void didChangeMetrics() {
    final view = WidgetsBinding.instance.platformDispatcher.implicitView;
    if (view == null) return;
    handleBottomPadding(view.viewPadding.bottom);
  }

  /// A bottom padding above zero means the navigation bar is on screen
  /// again. Exposed so the behaviour can be tested without a device.
  void handleBottomPadding(double bottomPadding) {
    if (bottomPadding <= 0) {
      _timer?.cancel();
      _timer = null;
      return;
    }
    // Already counting down; don't restart on every metrics tick.
    if (_timer?.isActive ?? false) return;
    _timer = Timer(hideDelay, apply);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Coming back from another app restores the system bars.
    if (state == AppLifecycleState.resumed) unawaited(apply());
  }
}

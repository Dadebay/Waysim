import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class SystemUiManager with WidgetsBindingObserver {
  SystemUiManager({this.hideDelay = const Duration(seconds: 3)});

  static const _androidUi = MethodChannel('com.waysim.app/system_ui');

  final Duration hideDelay;

  Timer? _timer;
  bool _nativeChannelAvailable = true;

  Future<void> start() async {
    WidgetsBinding.instance.addObserver(this);
    await apply();
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    WidgetsBinding.instance.removeObserver(this);
  }

  Future<void> apply() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top],
    );

    if (!kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android &&
        _nativeChannelAvailable) {
      try {
        await _androidUi.invokeMethod<void>('hideNavigationBar');
      } on MissingPluginException {
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

  void handleBottomPadding(double bottomPadding) {
    if (bottomPadding <= 0) {
      _timer?.cancel();
      _timer = null;
      return;
    }

    if (_timer?.isActive ?? false) return;
    _timer = Timer(hideDelay, apply);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(apply());
  }
}

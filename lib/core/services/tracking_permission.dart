import 'dart:io' show Platform;

import 'package:app_tracking_transparency/app_tracking_transparency.dart';

import '../utils/app_logger.dart';

/// iOS "Allow Waysim to track your activity" system prompt (ATT). Other
/// platforms have no such dialog.
abstract interface class TrackingPermission {
  Future<void> request();
}

class NoopTrackingPermission implements TrackingPermission {
  @override
  Future<void> request() async {}
}

class AttTrackingPermission implements TrackingPermission {
  @override
  Future<void> request() async {
    if (!Platform.isIOS) return;
    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    } on Object catch (e) {
      AppLogger.w('Tracking permission request failed: $e');
    }
  }
}

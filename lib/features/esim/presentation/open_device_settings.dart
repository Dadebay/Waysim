import 'dart:io';

import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/app_logger.dart';

/// Opens the system Settings app. iOS only allows the app's own settings page
/// (the user goes back to the main list from there); Android opens the root.
Future<bool> openDeviceSettings() async {
  try {
    if (Platform.isIOS) {
      return await launchUrl(Uri.parse('app-settings:'));
    }
    if (Platform.isAndroid) {
      await const MethodChannel(
        'com.waysim.app/esim',
      ).invokeMethod<void>('openSettings');
      return true;
    }
  } on Object catch (e) {
    AppLogger.w('[ESIM-INSTALL] could not open Settings: $e');
  }
  return false;
}

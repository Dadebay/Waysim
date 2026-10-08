import 'dart:io';
import 'dart:ui' show PlatformDispatcher;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../constants/app_environment.dart';
import 'crash_report.dart';

/// Reads the phone and build once, for crash reports.
Future<DeviceContext> readDeviceContext() async {
  try {
    final app = await PackageInfo.fromPlatform();
    final device = DeviceInfoPlugin();
    String platform;
    String os;
    String model;
    if (Platform.isAndroid) {
      final info = await device.androidInfo;
      platform = 'android';
      os = 'Android ${info.version.release} (API ${info.version.sdkInt})';
      model = '${info.manufacturer} ${info.model}'.trim();
    } else if (Platform.isIOS) {
      final info = await device.iosInfo;
      platform = 'ios';
      os = '${info.systemName} ${info.systemVersion}';
      model = info.utsname.machine;
    } else {
      platform = Platform.operatingSystem;
      os = Platform.operatingSystemVersion;
      model = '';
    }
    return DeviceContext(
      platform: platform,
      osVersion: os,
      model: model,
      appVersion: app.version,
      buildNumber: app.buildNumber,
      locale: PlatformDispatcher.instance.locale.toLanguageTag(),
      flavor: AppEnvironment.flavor.name,
    );
  } on Object {
    return DeviceContext.unknown;
  }
}

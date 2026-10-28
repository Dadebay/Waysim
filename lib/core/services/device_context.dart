import 'dart:io';
import 'dart:ui' show PlatformDispatcher;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:root_jailbreak_detector/root_jailbreak_detector.dart';

import '../constants/app_environment.dart';
import 'crash_report.dart';
import '../utils/formatters/device_model.dart';

Future<DeviceContext> readDeviceContext() async {
  try {
    final app = await PackageInfo.fromPlatform();
    final device = DeviceInfoPlugin();
    String platform;
    String os;
    String model;
    var isEmulator = false;
    if (Platform.isAndroid) {
      final info = await device.androidInfo;
      platform = 'android';
      os = 'Android ${info.version.release} (API ${info.version.sdkInt})';
      model = deviceModelName('${info.manufacturer} ${info.model}');
      isEmulator = !info.isPhysicalDevice;
    } else if (Platform.isIOS) {
      final info = await device.iosInfo;
      platform = 'ios';
      os = '${info.systemName} ${info.systemVersion}';
      model = info.modelName.trim().isNotEmpty
          ? info.modelName
          : deviceModelName(info.utsname.machine);
      isEmulator = !info.isPhysicalDevice;
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
      timezone: await _localTimezone(),
      isEmulator: isEmulator,
      isRooted:
          (Platform.isAndroid || Platform.isIOS) &&
          await const RootJailbreakDetector(
            treatEmulatorAsCompromised: false,
          ).isCompromisedOrElse(false),
    );
  } on Object {
    return DeviceContext.unknown;
  }
}

Future<String> _localTimezone() async {
  try {
    final identifier = (await FlutterTimezone.getLocalTimezone()).identifier;
    if (identifier.isNotEmpty) return identifier;
    // ignore: empty_catches
  } on Object {}
  return DateTime.now().timeZoneName;
}

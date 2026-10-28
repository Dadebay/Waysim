import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';

enum EsimSupport { yes, no, likely, unknown }

abstract interface class EsimCompatibility {
  Future<EsimSupport> check();

  Future<bool> supportsOneTapInstall();

  Future<String> deviceName();
}

class DeviceEsimCompatibility implements EsimCompatibility {
  DeviceEsimCompatibility({
    DeviceInfoPlugin? deviceInfo,
    MethodChannel? channel,
  }) : _deviceInfo = deviceInfo ?? DeviceInfoPlugin(),
       _channel = channel ?? const MethodChannel(channelName);

  static const channelName = 'com.waysim.app/esim';

  final DeviceInfoPlugin _deviceInfo;
  final MethodChannel _channel;

  @override
  Future<EsimSupport> check() async {
    try {
      if (Platform.isAndroid) {
        final supported = await _channel.invokeMethod<bool>('isEsimSupported');
        return switch (supported) {
          true => EsimSupport.yes,
          false => EsimSupport.no,
          null => EsimSupport.unknown,
        };
      }
      if (Platform.isIOS) {
        final info = await _deviceInfo.iosInfo;

        if (!info.isPhysicalDevice) return EsimSupport.unknown;
        return iosSupport(info.utsname.machine);
      }
      // ignore: empty_catches
    } on Object {}
    return EsimSupport.unknown;
  }

  @override
  Future<bool> supportsOneTapInstall() async {
    try {
      if (!Platform.isIOS) return false;
      final info = await _deviceInfo.iosInfo;
      return info.isPhysicalDevice &&
          iosVersionAtLeast(info.systemVersion, 17, 4);
    } on Object {
      return false;
    }
  }

  static bool iosVersionAtLeast(String version, int major, int minor) {
    final parts = version.split('.');
    final m = int.tryParse(parts.first) ?? 0;
    final n = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return m > major || (m == major && n >= minor);
  }

  EsimSupport iosSupport(String machine) {
    if (machine == 'iPhone18,4') return EsimSupport.yes;
    final match = RegExp(r'^iPhone(\d+),').firstMatch(machine);
    if (match == null) return EsimSupport.unknown;
    return int.parse(match.group(1)!) >= 11
        ? EsimSupport.likely
        : EsimSupport.no;
  }

  @override
  Future<String> deviceName() async {
    try {
      if (Platform.isAndroid) {
        final info = await _deviceInfo.androidInfo;
        return '${info.manufacturer} ${info.model}'.trim();
      }
      if (Platform.isIOS) return (await _deviceInfo.iosInfo).utsname.machine;
      // ignore: empty_catches
    } on Object {}
    return 'Unknown device';
  }
}

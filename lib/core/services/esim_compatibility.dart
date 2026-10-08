import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';

enum EsimSupport { yes, no, unknown }

/// Whether this phone can use an eSIM.
///
/// * Android asks the platform: `EuiccManager.isEnabled` through a method
///   channel (`MainActivity.kt`).
/// * iOS has no such API, so the hardware model (`iPhone14,5`) is checked
///   against a list. Every iPhone XS/XR (`iPhone11,x`) and later has eSIM; the
///   server can override the list with `supportedModels`
///   (docs/06-roadmap.md T2.6) — mainland-China models, for instance, ship
///   without it.
abstract interface class EsimCompatibility {
  Future<EsimSupport> check();

  /// iOS 17.4+ can install an eSIM straight from a link (Apple's universal
  /// link); everything else installs from the QR code or by typing the
  /// details.
  Future<bool> supportsOneTapInstall();

  /// The phone's marketing-neutral model, e.g. `iPhone14,5` or `Pixel 8`;
  /// sent when an eSIM is installed so one package binds to one device.
  Future<String> deviceName();
}

class DeviceEsimCompatibility implements EsimCompatibility {
  DeviceEsimCompatibility({
    DeviceInfoPlugin? deviceInfo,
    MethodChannel? channel,
    this.supportedIosModels = const {},
  }) : _deviceInfo = deviceInfo ?? DeviceInfoPlugin(),
       _channel = channel ?? const MethodChannel(channelName);

  static const channelName = 'com.waysim.app/esim';

  /// Model identifiers the server lists as eSIM-capable. Empty means "use the
  /// built-in rule".
  final Set<String> supportedIosModels;

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
        // A simulator reports a Mac model, which says nothing about phones.
        if (!info.isPhysicalDevice) return EsimSupport.unknown;
        return iosSupport(info.utsname.machine);
      }
    } on Object {
      // Fall through: not knowing is better than guessing wrong.
    }
    return EsimSupport.unknown;
  }

  @override
  Future<bool> supportsOneTapInstall() async {
    try {
      if (!Platform.isIOS) return false;
      final info = await _deviceInfo.iosInfo;
      return iosVersionAtLeast(info.systemVersion, 17, 4);
    } on Object {
      return false;
    }
  }

  /// `17.4.1` ≥ 17.4. Pure so it can be tested.
  static bool iosVersionAtLeast(String version, int major, int minor) {
    final parts = version.split('.');
    final m = int.tryParse(parts.first) ?? 0;
    final n = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return m > major || (m == major && n >= minor);
  }

  /// Pure so it can be tested: the verdict for an iOS model identifier.
  EsimSupport iosSupport(String machine) {
    if (supportedIosModels.isNotEmpty) {
      return supportedIosModels.contains(machine)
          ? EsimSupport.yes
          : EsimSupport.no;
    }
    final match = RegExp(r'^iPhone(\d+),').firstMatch(machine);
    if (match == null) return EsimSupport.unknown; // iPad, iPod, …
    return int.parse(match.group(1)!) >= 11 ? EsimSupport.yes : EsimSupport.no;
  }

  @override
  Future<String> deviceName() async {
    try {
      if (Platform.isAndroid) {
        final info = await _deviceInfo.androidInfo;
        return '${info.manufacturer} ${info.model}'.trim();
      }
      if (Platform.isIOS) return (await _deviceInfo.iosInfo).utsname.machine;
    } on Object {
      // Unknown device is still a valid binding label.
    }
    return 'Unknown device';
  }
}

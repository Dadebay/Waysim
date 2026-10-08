import 'package:equatable/equatable.dart';

/// Switches and numbers the server controls, fetched on launch and whenever
/// the app returns to the foreground.
class AppConfig extends Equatable {
  const AppConfig({
    this.referralEnabled = true,
    this.referralRewardCents = 300,
    this.maintenance = false,
    this.minTopUpCents = 500,
    this.maxTopUpCents = 50000,
    this.supportEmail = 'support@waysim.co',
    this.cryptoEnabled = true,
    this.paypalEnabled = true,
    this.minSupportedVersion,
    this.storeUrl = 'https://waysim.co/app',
  });

  final bool referralEnabled;
  final int referralRewardCents;

  /// Purchases and top-ups are paused (incident switch).
  final bool maintenance;
  final int minTopUpCents;
  final int maxTopUpCents;
  final String supportEmail;
  final bool cryptoEnabled;
  final bool paypalEnabled;

  /// Versions below this are blocked until updated; `null` = no limit.
  final String? minSupportedVersion;
  final String storeUrl;

  @override
  List<Object?> get props => [
    referralEnabled,
    referralRewardCents,
    maintenance,
    minTopUpCents,
    maxTopUpCents,
    supportEmail,
    cryptoEnabled,
    paypalEnabled,
    minSupportedVersion,
    storeUrl,
  ];
}

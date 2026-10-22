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
    this.supportedLocales = const ['en', 'zh', 'ru', 'es', 'fr'],
    this.defaultLocale = 'en',
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

  /// Language codes currently offered by the server.
  final List<String> supportedLocales;
  final String defaultLocale;
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
    supportedLocales,
    defaultLocale,
    cryptoEnabled,
    paypalEnabled,
    minSupportedVersion,
    storeUrl,
  ];
}

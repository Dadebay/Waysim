import 'package:equatable/equatable.dart';

/// One entry of `meta.contacts`: the text to show and where it leads.
class ContactLink extends Equatable {
  const ContactLink({required this.label, required this.url});

  final String label;
  final String url;

  @override
  List<Object?> get props => [label, url];
}

/// Switches and numbers the server controls, fetched on launch and whenever
/// the app returns to the foreground.
class AppConfig extends Equatable {
  const AppConfig({
    this.referralEnabled = true,
    this.referralRewardCents = 300,
    this.maintenance = false,
    this.minTopUpCents = 100,
    this.maxTopUpCents = 50000,
    this.supportEmail = 'support@waysim.co',
    this.contacts = const AppContacts(),
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
  final AppContacts contacts;

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
    contacts,
    supportedLocales,
    defaultLocale,
    cryptoEnabled,
    paypalEnabled,
    minSupportedVersion,
    storeUrl,
  ];
}

/// `meta.contacts`; a channel the admin left empty is `null` and not shown.
class AppContacts extends Equatable {
  const AppContacts({this.website, this.email, this.telegram, this.instagram});

  final ContactLink? website;
  final ContactLink? email;
  final ContactLink? telegram;
  final ContactLink? instagram;

  bool get isEmpty =>
      website == null && email == null && telegram == null && instagram == null;

  @override
  List<Object?> get props => [website, email, telegram, instagram];
}

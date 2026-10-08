/// Non-visual app-wide constants. Keep environment values in [AppEnvironment].
abstract final class AppConstants {
  static const appName = 'Waysim';

  /// Web home; legal documents, referral links and universal links live here.
  static const webHost = 'waysim.co';

  /// Custom URL scheme for deep links (`waysim://…`).
  static const urlScheme = 'waysim';

  // Currency — the whole app is priced in US dollars, kept as integer cents.
  static const currencyCode = 'USD';
  static const currencySymbol = r'$';

  // Top-up bounds shown as a hint; the server is the source of truth.
  static const minTopUpCents = 500;
  static const maxTopUpCents = 50000;
  static const topUpPresetsCents = [1000, 2000, 5000, 10000];

  // Timings
  static const searchDebounce = Duration(milliseconds: 150);
  static const bannerAutoScroll = Duration(seconds: 5);
  static const otpResend = Duration(seconds: 60);

  /// After this long on the "Preparing your eSIM…" screen the app stops
  /// waiting and promises a push notification instead.
  static const orderWaitLimit = Duration(seconds: 30);

  static const connectTimeout = Duration(seconds: 20);
  static const receiveTimeout = Duration(seconds: 30);

  /// Animations across the app stay inside 200–300 ms.
  static const animationFast = Duration(milliseconds: 200);
  static const animationBase = Duration(milliseconds: 250);
  static const animationSlow = Duration(milliseconds: 300);
  static const themeFallbackAnimation = Duration(milliseconds: 200);

  /// Minimum tappable size, in logical pixels (44 pt per HIG).
  static const minTapTarget = 44.0;
}

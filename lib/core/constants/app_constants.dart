/// Non-visual app-wide constants. Keep environment values in [AppEnvironment].
abstract final class AppConstants {
  static const appName = 'Waysim';

  /// Web home; legal documents, referral links and universal links live here.
  static const webHost = 'waysim.co';

  // Timings
  static const bannerAutoScroll = Duration(seconds: 5);

  /// After this long on the "Preparing your eSIM…" screen the app stops
  /// waiting and promises a push notification instead.
  static const orderWaitLimit = Duration(seconds: 30);

  static const connectTimeout = Duration(seconds: 20);
  static const receiveTimeout = Duration(seconds: 30);

  /// Animations across the app stay inside 200–300 ms.
  static const animationFast = Duration(milliseconds: 200);
  static const animationBase = Duration(milliseconds: 250);
  static const animationSlow = Duration(milliseconds: 300);
  static const themeFallbackAnimation = Duration(milliseconds: 220);
  static const themeScreenAnimation = Duration(milliseconds: 260);

  /// Minimum tappable size, in logical pixels (44 pt per HIG).
  static const minTapTarget = 44.0;
}

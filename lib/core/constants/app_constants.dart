abstract final class AppConstants {
  static const appName = 'Waysim';

  static const webHost = 'waysim.co';

  static const bannerAutoScroll = Duration(seconds: 5);

  static const orderWaitLimit = Duration(seconds: 30);

  static const connectTimeout = Duration(seconds: 20);
  static const receiveTimeout = Duration(seconds: 30);

  static const animationFast = Duration(milliseconds: 200);
  static const animationBase = Duration(milliseconds: 250);
  static const animationSlow = Duration(milliseconds: 300);
  static const themeFallbackAnimation = Duration(milliseconds: 220);
  static const themeScreenAnimation = Duration(milliseconds: 260);

  static const minTapTarget = 44.0;
}

import 'package:hugeicons/hugeicons.dart';

/// Re-exported so a widget that draws an icon imports this file only, the
/// same way it would import `material.dart` for `Icon`.
export 'package:hugeicons/hugeicons.dart' show HugeIcon;

/// Every glyph the app draws from code, named for what it means rather than
/// for the icon set it comes from. Hugeicons "stroke rounded" matches the
/// design system's line icons (24 px, 1.8–2 stroke).
///
/// Hugeicons ships glyphs as data, so an icon is an [AppIconData] passed to
/// `HugeIcon(icon: ...)`, not an `IconData` passed to `Icon(...)`.
typedef AppIconData = List<List<dynamic>>;

abstract final class AppIcons {
  // ---------------------------------------------------------------- tabs --
  static const AppIconData home = HugeIcons.strokeRoundedHome01;
  static const AppIconData myEsim = HugeIcons.strokeRoundedSimcard01;
  static const AppIconData profile = HugeIcons.strokeRoundedUser;

  // ------------------------------------------------------------- actions --
  static const AppIconData check = HugeIcons.strokeRoundedTick02;
  static const AppIconData close = HugeIcons.strokeRoundedCancel01;
  static const AppIconData add = HugeIcons.strokeRoundedAdd01;
  static const AppIconData copy = HugeIcons.strokeRoundedCopy01;
  static const AppIconData share = HugeIcons.strokeRoundedShare08;
  static const AppIconData delete = HugeIcons.strokeRoundedDelete02;
  static const AppIconData refresh = HugeIcons.strokeRoundedRefresh;
  static const AppIconData logout = HugeIcons.strokeRoundedLogout01;

  // ---------------------------------------------------------- navigation --
  static const AppIconData back = HugeIcons.strokeRoundedArrowLeft01;
  static const AppIconData chevronRight = HugeIcons.strokeRoundedArrowRight01;
  static const AppIconData arrowUpRight = HugeIcons.strokeRoundedArrowUpRight01;
  static const AppIconData chevronDown = HugeIcons.strokeRoundedArrowDown01;

  // -------------------------------------------------------------- content --
  static const AppIconData search = HugeIcons.strokeRoundedSearch01;
  static const AppIconData globe = HugeIcons.strokeRoundedGlobe02;
  static const AppIconData wallet = HugeIcons.strokeRoundedWallet01;
  static const AppIconData paypal = HugeIcons.strokeRoundedPaypal;
  static const AppIconData crypto = HugeIcons.strokeRoundedBitcoinCircle;
  static const AppIconData gift = HugeIcons.strokeRoundedGift;
  static const AppIconData qrCode = HugeIcons.strokeRoundedQrCode01;
  static const AppIconData phone = HugeIcons.strokeRoundedSmartPhone01;
  static const AppIconData document = HugeIcons.strokeRoundedLegalDocument01;

  // ------------------------------------------------------------- settings --
  static const AppIconData settings = HugeIcons.strokeRoundedSettings02;
  static const AppIconData notification = HugeIcons.strokeRoundedNotification01;
  static const AppIconData moon = HugeIcons.strokeRoundedMoon02;
  static const AppIconData sun = HugeIcons.strokeRoundedSun03;

  // -------------------------------------------------------------- support --
  static const AppIconData support = HugeIcons.strokeRoundedChat01;
  static const AppIconData aiChat = HugeIcons.strokeRoundedAiChat02;
  static const AppIconData mail = HugeIcons.strokeRoundedMail01;
  static const AppIconData sparkles = HugeIcons.strokeRoundedSparkles;
  static const AppIconData send = HugeIcons.strokeRoundedSent;

  // --------------------------------------------------------------- state --
  static const AppIconData error = HugeIcons.strokeRoundedAlertCircle;
  static const AppIconData warning = HugeIcons.strokeRoundedAlert02;
  static const AppIconData offline = HugeIcons.strokeRoundedWifiOff01;
  static const AppIconData info = HugeIcons.strokeRoundedInformationCircle;
}

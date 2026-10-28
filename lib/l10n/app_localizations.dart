import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// Brand name. Never translated.
  ///
  /// In en, this message translates to:
  /// **'Waysim'**
  String get appName;

  /// Bottom tab: home / catalog
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// Bottom tab: purchased eSIMs
  ///
  /// In en, this message translates to:
  /// **'My eSIM'**
  String get tabMyEsim;

  /// Bottom tab: account
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// Home header greeting for a signed-in user with a name
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}!'**
  String greetingNamed(String name);

  /// Home header greeting when no name is known
  ///
  /// In en, this message translates to:
  /// **'Hi!'**
  String get greeting;

  /// Guest header button / sign-in action
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Where do you need an eSIM?'**
  String get searchHint;

  /// No description provided for @supportFabLabel.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportFabLabel;

  /// No description provided for @homeLocal.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get homeLocal;

  /// No description provided for @homeRegional.
  ///
  /// In en, this message translates to:
  /// **'Regional'**
  String get homeRegional;

  /// Lowest price of a country or region, e.g. 'from $1.99'
  ///
  /// In en, this message translates to:
  /// **'from {price}'**
  String priceFrom(String price);

  /// No description provided for @myEsimTitle.
  ///
  /// In en, this message translates to:
  /// **'My eSIM'**
  String get myEsimTitle;

  /// No description provided for @myEsimCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get myEsimCurrent;

  /// No description provided for @myEsimArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get myEsimArchive;

  /// No description provided for @myEsimEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No eSIMs yet'**
  String get myEsimEmptyTitle;

  /// No description provided for @myEsimEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Buy a plan for your trip — it only takes a couple of minutes.'**
  String get myEsimEmptyBody;

  /// No description provided for @buyEsim.
  ///
  /// In en, this message translates to:
  /// **'Get an eSIM'**
  String get buyEsim;

  /// No description provided for @howEsimWorks.
  ///
  /// In en, this message translates to:
  /// **'How eSIM works'**
  String get howEsimWorks;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileGuestTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to buy eSIMs'**
  String get profileGuestTitle;

  /// No description provided for @profileGuestBody.
  ///
  /// In en, this message translates to:
  /// **'Purchases, balance and eSIMs are saved to your account.'**
  String get profileGuestBody;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'No connection'**
  String get offlineBanner;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your network and try again.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The request timed out. Please try again.'**
  String get errorTimeout;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our side. Please try again later.'**
  String get errorServer;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get errorUnauthorized;

  /// No description provided for @signedOutOnDevice.
  ///
  /// In en, this message translates to:
  /// **'You were signed out on this device. Please sign in again.'**
  String get signedOutOnDevice;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find what you were looking for.'**
  String get errorNotFound;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorUnknown;

  /// No description provided for @actionCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get actionCopy;

  /// No description provided for @toastCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get toastCopied;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get actionGotIt;

  /// No description provided for @actionLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get actionLater;

  /// No description provided for @actionPasteCode.
  ///
  /// In en, this message translates to:
  /// **'Paste code'**
  String get actionPasteCode;

  /// No description provided for @settingsGallery.
  ///
  /// In en, this message translates to:
  /// **'Design gallery (debug)'**
  String get settingsGallery;

  /// No description provided for @unitGb.
  ///
  /// In en, this message translates to:
  /// **'{value} GB'**
  String unitGb(String value);

  /// No description provided for @unitMb.
  ///
  /// In en, this message translates to:
  /// **'{value} MB'**
  String unitMb(String value);

  /// No description provided for @durationDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} day} other{{count} days}}'**
  String durationDays(int count);

  /// No description provided for @dataUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get dataUnlimited;

  /// No description provided for @dailyAllowance.
  ///
  /// In en, this message translates to:
  /// **'{size} a day'**
  String dailyAllowance(String size);

  /// No description provided for @unlimitedPlan.
  ///
  /// In en, this message translates to:
  /// **'Unlimited · {daily} · {days}'**
  String unlimitedPlan(String daily, String days);

  /// No description provided for @regionCountries.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} country} other{{count} countries}}'**
  String regionCountries(int count);

  /// No description provided for @bannerEsimTitle.
  ///
  /// In en, this message translates to:
  /// **'What is eSIM?'**
  String get bannerEsimTitle;

  /// No description provided for @bannerEsimBody.
  ///
  /// In en, this message translates to:
  /// **'A digital SIM card: set up in minutes, no plastic'**
  String get bannerEsimBody;

  /// No description provided for @bannerEsimAction.
  ///
  /// In en, this message translates to:
  /// **'How it works →'**
  String get bannerEsimAction;

  /// No description provided for @bannerInviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite a friend — get {reward}'**
  String bannerInviteTitle(String reward);

  /// No description provided for @bannerInviteAction.
  ///
  /// In en, this message translates to:
  /// **'Invite →'**
  String get bannerInviteAction;

  /// No description provided for @bannerTravelTitle.
  ///
  /// In en, this message translates to:
  /// **'Online on every trip'**
  String get bannerTravelTitle;

  /// No description provided for @bannerTravelBody.
  ///
  /// In en, this message translates to:
  /// **'Local plans for popular destinations'**
  String get bannerTravelBody;

  /// No description provided for @bannerTravelAction.
  ///
  /// In en, this message translates to:
  /// **'See countries →'**
  String get bannerTravelAction;

  /// No description provided for @catalogEmpty.
  ///
  /// In en, this message translates to:
  /// **'No destinations yet'**
  String get catalogEmpty;

  /// No description provided for @searchRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get searchRecent;

  /// No description provided for @searchClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get searchClear;

  /// No description provided for @searchCountries.
  ///
  /// In en, this message translates to:
  /// **'Countries'**
  String get searchCountries;

  /// No description provided for @searchRegions.
  ///
  /// In en, this message translates to:
  /// **'Regions'**
  String get searchRegions;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'Nothing found for “{query}”'**
  String searchNoResults(String query);

  /// No description provided for @searchNoResultsHint.
  ///
  /// In en, this message translates to:
  /// **'Try a country name or code, like “Turkey” or “US”.'**
  String get searchNoResultsHint;

  /// No description provided for @searchBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get searchBack;

  /// No description provided for @compatSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Does my phone support eSIM?'**
  String get compatSheetTitle;

  /// No description provided for @compatSheetIos.
  ///
  /// In en, this message translates to:
  /// **'Waysim cannot verify eSIM hardware on this iPhone automatically. Some regional versions use two physical SIM cards, so an eSIM plan may not work on this phone.'**
  String get compatSheetIos;

  /// No description provided for @compatSheetAndroid.
  ///
  /// In en, this message translates to:
  /// **'Waysim couldn\'t verify eSIM availability on this device. Check the manufacturer\'s specifications before buying a plan.'**
  String get compatSheetAndroid;

  /// No description provided for @compatUnverifiedRow.
  ///
  /// In en, this message translates to:
  /// **'eSIM support not verified'**
  String get compatUnverifiedRow;

  /// No description provided for @compatWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Your phone may not support eSIM'**
  String get compatWarningTitle;

  /// No description provided for @compatWarningBody.
  ///
  /// In en, this message translates to:
  /// **'You can still buy this plan, but the eSIM won’t work on a phone without eSIM support. Continue anyway?'**
  String get compatWarningBody;

  /// No description provided for @actionContinueAnyway.
  ///
  /// In en, this message translates to:
  /// **'Continue anyway'**
  String get actionContinueAnyway;

  /// No description provided for @packagesUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get packagesUnlimited;

  /// No description provided for @packagesLimited.
  ///
  /// In en, this message translates to:
  /// **'Limited'**
  String get packagesLimited;

  /// No description provided for @packagesChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose a plan'**
  String get packagesChoose;

  /// No description provided for @esimActivatingNote.
  ///
  /// In en, this message translates to:
  /// **'In some countries the eSIM activates only after you arrive and your phone finds a local network. Until then, Settings may show “Activating…”. That’s normal: don’t delete the eSIM.'**
  String get esimActivatingNote;

  /// No description provided for @packagesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No plans in this category'**
  String get packagesEmpty;

  /// No description provided for @packageDetailsLink.
  ///
  /// In en, this message translates to:
  /// **'Package details'**
  String get packageDetailsLink;

  /// No description provided for @buyFor.
  ///
  /// In en, this message translates to:
  /// **'Buy for {price}'**
  String buyFor(String price);

  /// No description provided for @purchaseDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'By placing the order you confirm that your device is eSIM-compatible and not locked to a carrier.'**
  String get purchaseDisclaimer;

  /// No description provided for @oneTimePurchase.
  ///
  /// In en, this message translates to:
  /// **'One-time purchase — no subscription or auto-renewal.'**
  String get oneTimePurchase;

  /// No description provided for @detailCoverage.
  ///
  /// In en, this message translates to:
  /// **'Coverage'**
  String get detailCoverage;

  /// No description provided for @detailData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get detailData;

  /// No description provided for @detailDataFull.
  ///
  /// In en, this message translates to:
  /// **'{size} at full speed'**
  String detailDataFull(String size);

  /// No description provided for @detailDataUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited, {size} a day at full speed'**
  String detailDataUnlimited(String size);

  /// No description provided for @detailValidity.
  ///
  /// In en, this message translates to:
  /// **'Validity'**
  String get detailValidity;

  /// No description provided for @detailValidityNote.
  ///
  /// In en, this message translates to:
  /// **'Starts from the first connection of the eSIM to a network at your destination'**
  String get detailValidityNote;

  /// No description provided for @detailNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get detailNetwork;

  /// No description provided for @detailHotspot.
  ///
  /// In en, this message translates to:
  /// **'Hotspot'**
  String get detailHotspot;

  /// No description provided for @detailTopUp.
  ///
  /// In en, this message translates to:
  /// **'Top-up'**
  String get detailTopUp;

  /// No description provided for @detailCalls.
  ///
  /// In en, this message translates to:
  /// **'Calls & SMS'**
  String get detailCalls;

  /// No description provided for @detailInstall.
  ///
  /// In en, this message translates to:
  /// **'Installation'**
  String get detailInstall;

  /// No description provided for @detailAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get detailAvailable;

  /// No description provided for @detailUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get detailUnavailable;

  /// No description provided for @detailDataOnly.
  ///
  /// In en, this message translates to:
  /// **'Data only'**
  String get detailDataOnly;

  /// No description provided for @detailCallsIncluded.
  ///
  /// In en, this message translates to:
  /// **'Included'**
  String get detailCallsIncluded;

  /// No description provided for @detailInstallWithin.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Within {count} day} other{Within {count} days}}'**
  String detailInstallWithin(int count);

  /// No description provided for @coverageCountries.
  ///
  /// In en, this message translates to:
  /// **'Countries covered'**
  String get coverageCountries;

  /// No description provided for @confirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm purchase'**
  String get confirmTitle;

  /// No description provided for @confirmPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get confirmPrice;

  /// No description provided for @confirmBalanceNow.
  ///
  /// In en, this message translates to:
  /// **'Balance now'**
  String get confirmBalanceNow;

  /// No description provided for @confirmBalanceAfter.
  ///
  /// In en, this message translates to:
  /// **'Balance after purchase'**
  String get confirmBalanceAfter;

  /// No description provided for @confirmConsent.
  ///
  /// In en, this message translates to:
  /// **'I want the eSIM issued right away and understand I can’t cancel the purchase once it is installed. One-time purchase — no subscription or auto-renewal.'**
  String get confirmConsent;

  /// No description provided for @confirmPay.
  ///
  /// In en, this message translates to:
  /// **'Pay {price}'**
  String confirmPay(String price);

  /// No description provided for @insufficientTitle.
  ///
  /// In en, this message translates to:
  /// **'Not enough balance'**
  String get insufficientTitle;

  /// No description provided for @insufficientBody.
  ///
  /// In en, this message translates to:
  /// **'You need {missing} more to buy this plan.'**
  String insufficientBody(String missing);

  /// No description provided for @insufficientAction.
  ///
  /// In en, this message translates to:
  /// **'Top up {amount}'**
  String insufficientAction(String amount);

  /// No description provided for @orderPreparing.
  ///
  /// In en, this message translates to:
  /// **'Setting up your eSIM…'**
  String get orderPreparing;

  /// No description provided for @orderPreparingHint.
  ///
  /// In en, this message translates to:
  /// **'This usually takes a few seconds.'**
  String get orderPreparingHint;

  /// No description provided for @orderSlow.
  ///
  /// In en, this message translates to:
  /// **'This is taking longer than usual. We’ll send a notification when your eSIM is ready.'**
  String get orderSlow;

  /// No description provided for @orderFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t complete the order'**
  String get orderFailedTitle;

  /// No description provided for @orderFailedBody.
  ///
  /// In en, this message translates to:
  /// **'If you were charged, the money has been returned to your balance.'**
  String get orderFailedBody;

  /// No description provided for @orderPriceChanged.
  ///
  /// In en, this message translates to:
  /// **'The price changed to {price}. Review it and try again.'**
  String orderPriceChanged(String price);

  /// No description provided for @orderBackToPlans.
  ///
  /// In en, this message translates to:
  /// **'Back to plans'**
  String get orderBackToPlans;

  /// No description provided for @actionGoToMyEsim.
  ///
  /// In en, this message translates to:
  /// **'Go to My eSIM'**
  String get actionGoToMyEsim;

  /// No description provided for @esimReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'eSIM is ready!'**
  String get esimReadyTitle;

  /// No description provided for @esimReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Install it now while you have Wi-Fi. The plan’s days only start counting once you connect at your destination.'**
  String get esimReadyBody;

  /// No description provided for @esimInstall.
  ///
  /// In en, this message translates to:
  /// **'Install eSIM'**
  String get esimInstall;

  /// No description provided for @maintenanceBanner.
  ///
  /// In en, this message translates to:
  /// **'Purchases and top-ups are temporarily paused.'**
  String get maintenanceBanner;

  /// No description provided for @errorMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Purchases are temporarily paused. Please try again later.'**
  String get errorMaintenance;

  /// No description provided for @errorPackageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This plan is no longer available.'**
  String get errorPackageUnavailable;

  /// No description provided for @errorOrderFailed.
  ///
  /// In en, this message translates to:
  /// **'The order couldn’t be completed. If you were charged, the money has been returned to your balance.'**
  String get errorOrderFailed;

  /// No description provided for @errorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please wait a moment.'**
  String get errorTooManyRequests;

  /// No description provided for @errorBoundToOtherDevice.
  ///
  /// In en, this message translates to:
  /// **'This eSIM is already linked to another device.'**
  String get errorBoundToOtherDevice;

  /// No description provided for @agoJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get agoJustNow;

  /// No description provided for @agoMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} min ago} other{{count} min ago}}'**
  String agoMinutes(int count);

  /// No description provided for @agoHours.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} h ago} other{{count} h ago}}'**
  String agoHours(int count);

  /// No description provided for @agoDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} day ago} other{{count} days ago}}'**
  String agoDays(int count);

  /// No description provided for @balanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balanceLabel;

  /// No description provided for @statusProvisioning.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get statusProvisioning;

  /// No description provided for @statusNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'Not installed'**
  String get statusNotInstalled;

  /// No description provided for @statusInstalled.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get statusInstalled;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @statusUsedUp.
  ///
  /// In en, this message translates to:
  /// **'Used up'**
  String get statusUsedUp;

  /// No description provided for @statusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get statusExpired;

  /// No description provided for @statusFailedRefunded.
  ///
  /// In en, this message translates to:
  /// **'Failed, refunded'**
  String get statusFailedRefunded;

  /// No description provided for @myEsimArchiveEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing in the archive'**
  String get myEsimArchiveEmpty;

  /// No description provided for @esimLeftOf.
  ///
  /// In en, this message translates to:
  /// **'{left} of {total} left'**
  String esimLeftOf(String left, String total);

  /// No description provided for @esimDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} day left} other{{count} days left}}'**
  String esimDaysLeft(int count);

  /// No description provided for @esimInstallBy.
  ///
  /// In en, this message translates to:
  /// **'Install by {date}'**
  String esimInstallBy(String date);

  /// No description provided for @esimValidityFromFirst.
  ///
  /// In en, this message translates to:
  /// **'Validity starts on first connection'**
  String get esimValidityFromFirst;

  /// No description provided for @esimDeviceUpdated.
  ///
  /// In en, this message translates to:
  /// **'{device} · Updated {ago}'**
  String esimDeviceUpdated(String device, String ago);

  /// No description provided for @esimUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated {ago}'**
  String esimUpdated(String ago);

  /// No description provided for @esimRegionTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} ({count, plural, one{{count} country} other{{count} countries}})'**
  String esimRegionTitle(String name, int count);

  /// No description provided for @esimPackageLine.
  ///
  /// In en, this message translates to:
  /// **'{volume} · {duration}'**
  String esimPackageLine(String volume, String duration);

  /// No description provided for @actionInstall.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get actionInstall;

  /// No description provided for @howTitle.
  ///
  /// In en, this message translates to:
  /// **'How eSIM works'**
  String get howTitle;

  /// No description provided for @howStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Choose a plan'**
  String get howStep1Title;

  /// No description provided for @howStep1Body.
  ///
  /// In en, this message translates to:
  /// **'Find your destination and pick the data and number of days you need.'**
  String get howStep1Body;

  /// No description provided for @howStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Pay from your balance'**
  String get howStep2Title;

  /// No description provided for @howStep2Body.
  ///
  /// In en, this message translates to:
  /// **'Top up your balance with PayPal or crypto and buy a plan in one tap.'**
  String get howStep2Body;

  /// No description provided for @howStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Install before you travel'**
  String get howStep3Title;

  /// No description provided for @howStep3Body.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code or install in one tap while you have Wi-Fi. Then don’t delete the eSIM.'**
  String get howStep3Body;

  /// No description provided for @howStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Turn it on when you land'**
  String get howStep4Title;

  /// No description provided for @howStep4Body.
  ///
  /// In en, this message translates to:
  /// **'Select the Waysim eSIM for mobile data and turn on data roaming for it.'**
  String get howStep4Body;

  /// No description provided for @esimDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'eSIM details'**
  String get esimDetailTitle;

  /// No description provided for @installOneTap.
  ///
  /// In en, this message translates to:
  /// **'Install in one tap'**
  String get installOneTap;

  /// No description provided for @installOneTapNote.
  ///
  /// In en, this message translates to:
  /// **'For iPhone with iOS 17.4 or later · Install by {date}'**
  String installOneTapNote(String date);

  /// No description provided for @installByQr.
  ///
  /// In en, this message translates to:
  /// **'Install by QR code'**
  String get installByQr;

  /// No description provided for @installQrNote.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code with the camera of the phone you’ll travel with: open this screen on another device or print the code.'**
  String get installQrNote;

  /// No description provided for @installQrRetryNote.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t install? Try a second time. If it still fails, wait 5 minutes and try again while we finish adding this eSIM to our system.'**
  String get installQrRetryNote;

  /// No description provided for @installArrivalNote.
  ///
  /// In en, this message translates to:
  /// **'The eSIM connects when you arrive in the destination and your phone finds a local network.'**
  String get installArrivalNote;

  /// No description provided for @installStuckNote.
  ///
  /// In en, this message translates to:
  /// **'Installer stuck on “Connecting”? Close it and check Settings → Cellular. If the eSIM isn’t there, install it manually with the details below. If it’s there and shows “Activating…”, that’s normal until you arrive: don’t delete it.'**
  String get installStuckNote;

  /// No description provided for @installLinkFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t open the installer. Use the QR code or manual installation below.'**
  String get installLinkFailed;

  /// No description provided for @installManual.
  ///
  /// In en, this message translates to:
  /// **'Manual installation'**
  String get installManual;

  /// No description provided for @esimSmdp.
  ///
  /// In en, this message translates to:
  /// **'SM-DP+ address'**
  String get esimSmdp;

  /// No description provided for @esimActivationCode.
  ///
  /// In en, this message translates to:
  /// **'Activation code'**
  String get esimActivationCode;

  /// No description provided for @esimIccid.
  ///
  /// In en, this message translates to:
  /// **'ICCID'**
  String get esimIccid;

  /// No description provided for @esimFullActivationCode.
  ///
  /// In en, this message translates to:
  /// **'Full activation code'**
  String get esimFullActivationCode;

  /// No description provided for @esimFullActivationCodeHint.
  ///
  /// In en, this message translates to:
  /// **'On Samsung/Android, choose Add eSIM → Scan QR code → Enter activation code manually, then paste the full code above, starting with LPA:1\$. Menu names may vary by phone.'**
  String get esimFullActivationCodeHint;

  /// No description provided for @installManualIosHint.
  ///
  /// In en, this message translates to:
  /// **'On iPhone, open Settings → Cellular → Add eSIM → Use QR Code → Enter Details Manually. Paste the SM-DP+ address and activation code above, and leave Confirmation Code empty.'**
  String get installManualIosHint;

  /// No description provided for @esimKeepWarning.
  ///
  /// In en, this message translates to:
  /// **'Don’t delete the eSIM from your phone while the plan is active. You can only reinstall it on this same phone.'**
  String get esimKeepWarning;

  /// No description provided for @esimRoamingWarning.
  ///
  /// In en, this message translates to:
  /// **'To avoid roaming charges from your home carrier, turn off data roaming for your main SIM.'**
  String get esimRoamingWarning;

  /// No description provided for @instructionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructionsTitle;

  /// No description provided for @tabIphone.
  ///
  /// In en, this message translates to:
  /// **'iPhone'**
  String get tabIphone;

  /// No description provided for @tabAndroid.
  ///
  /// In en, this message translates to:
  /// **'Android'**
  String get tabAndroid;

  /// No description provided for @iosStep1.
  ///
  /// In en, this message translates to:
  /// **'Connect to Wi-Fi.'**
  String get iosStep1;

  /// No description provided for @iosStep2.
  ///
  /// In en, this message translates to:
  /// **'Open Settings → Cellular → Add eSIM.'**
  String get iosStep2;

  /// No description provided for @iosStep3.
  ///
  /// In en, this message translates to:
  /// **'Choose “Use QR Code” or “Enter Details Manually”.'**
  String get iosStep3;

  /// No description provided for @iosStep4.
  ///
  /// In en, this message translates to:
  /// **'Name the line “Waysim”. Keep your main number for calls and iMessage.'**
  String get iosStep4;

  /// No description provided for @iosStep5.
  ///
  /// In en, this message translates to:
  /// **'When you land, turn on the Waysim line and Data Roaming, and select it for cellular data.'**
  String get iosStep5;

  /// No description provided for @androidStep1.
  ///
  /// In en, this message translates to:
  /// **'Connect to Wi-Fi.'**
  String get androidStep1;

  /// No description provided for @androidStep2.
  ///
  /// In en, this message translates to:
  /// **'In Settings, find SIM manager or SIMs, then choose Add eSIM (menu names vary by phone).'**
  String get androidStep2;

  /// No description provided for @androidStep3.
  ///
  /// In en, this message translates to:
  /// **'Choose “Scan QR code”. If you can’t scan it, tap the manual entry option below the scanner and paste the full activation code shown above.'**
  String get androidStep3;

  /// No description provided for @androidStep4.
  ///
  /// In en, this message translates to:
  /// **'Name the line “Waysim” and keep your main SIM for calls.'**
  String get androidStep4;

  /// No description provided for @androidStep5.
  ///
  /// In en, this message translates to:
  /// **'When you land, turn on the Waysim line and Data roaming, and use it for mobile data.'**
  String get androidStep5;

  /// No description provided for @usageTitle.
  ///
  /// In en, this message translates to:
  /// **'Data usage'**
  String get usageTitle;

  /// No description provided for @usageUnlimitedNote.
  ///
  /// In en, this message translates to:
  /// **'Unlimited plan — usage is shown by the carrier'**
  String get usageUnlimitedNote;

  /// No description provided for @topUpPackage.
  ///
  /// In en, this message translates to:
  /// **'Top up package'**
  String get topUpPackage;

  /// No description provided for @topUpPlansTitle.
  ///
  /// In en, this message translates to:
  /// **'Add data'**
  String get topUpPlansTitle;

  /// No description provided for @topUpPlansSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a plan to add to this eSIM'**
  String get topUpPlansSubtitle;

  /// No description provided for @topUpPlansEmpty.
  ///
  /// In en, this message translates to:
  /// **'No add-on plans are available for this eSIM.'**
  String get topUpPlansEmpty;

  /// No description provided for @topUpAddedTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan added'**
  String get topUpAddedTitle;

  /// No description provided for @topUpAddedBody.
  ///
  /// In en, this message translates to:
  /// **'The new data and days are now on your eSIM.'**
  String get topUpAddedBody;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in or sign up'**
  String get loginTitle;

  /// No description provided for @loginBody.
  ///
  /// In en, this message translates to:
  /// **'We’ll send a 6-digit code to your e-mail. No password needed.'**
  String get loginBody;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'E-mail'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'name@example.com'**
  String get emailHint;

  /// No description provided for @demoAccounts.
  ///
  /// In en, this message translates to:
  /// **'Test accounts'**
  String get demoAccounts;

  /// No description provided for @demoNewAccount.
  ///
  /// In en, this message translates to:
  /// **'New account'**
  String get demoNewAccount;

  /// No description provided for @demoExistingAccount.
  ///
  /// In en, this message translates to:
  /// **'Account with history'**
  String get demoExistingAccount;

  /// No description provided for @demoCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Test code: {code} (no e-mail is sent)'**
  String demoCodeHint(String code);

  /// No description provided for @inviteLabel.
  ///
  /// In en, this message translates to:
  /// **'Invite code (optional)'**
  String get inviteLabel;

  /// No description provided for @termsConsent.
  ///
  /// In en, this message translates to:
  /// **'I am 18 or older and accept the Terms of Use. How we process data is in the Privacy Policy.'**
  String get termsConsent;

  /// No description provided for @termsConsentStart.
  ///
  /// In en, this message translates to:
  /// **'I am 18 or older and accept the '**
  String get termsConsentStart;

  /// No description provided for @termsOfUseLink.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUseLink;

  /// No description provided for @termsConsentMiddle.
  ///
  /// In en, this message translates to:
  /// **'. How we process data is in the '**
  String get termsConsentMiddle;

  /// No description provided for @privacyPolicyLink.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyLink;

  /// No description provided for @termsConsentEnd.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get termsConsentEnd;

  /// No description provided for @loginErrorEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid e-mail address'**
  String get loginErrorEmail;

  /// No description provided for @loginErrorTerms.
  ///
  /// In en, this message translates to:
  /// **'Please accept the terms to continue'**
  String get loginErrorTerms;

  /// No description provided for @codeTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get codeTitle;

  /// No description provided for @codeInstructions.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code to continue.'**
  String get codeInstructions;

  /// No description provided for @codeLabel.
  ///
  /// In en, this message translates to:
  /// **'Code from the e-mail'**
  String get codeLabel;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Send again in {time}'**
  String resendIn(String time);

  /// No description provided for @resendNow.
  ///
  /// In en, this message translates to:
  /// **'Send again'**
  String get resendNow;

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change e-mail'**
  String get changeEmail;

  /// No description provided for @checkSpam.
  ///
  /// In en, this message translates to:
  /// **'No e-mail? Check your Spam folder.'**
  String get checkSpam;

  /// No description provided for @codeErrorWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong code. Try again.'**
  String get codeErrorWrong;

  /// No description provided for @codeErrorExpired.
  ///
  /// In en, this message translates to:
  /// **'This code has expired. Request a new one.'**
  String get codeErrorExpired;

  /// No description provided for @codeErrorTooMany.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later.'**
  String get codeErrorTooMany;

  /// No description provided for @nameTitle.
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get nameTitle;

  /// No description provided for @nameBody.
  ///
  /// In en, this message translates to:
  /// **'Optional — we’ll use it to greet you.'**
  String get nameBody;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get nameHint;

  /// No description provided for @actionSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get actionSkip;

  /// No description provided for @profileId.
  ///
  /// In en, this message translates to:
  /// **'ID {id}'**
  String profileId(String id);

  /// No description provided for @actionTopUp.
  ///
  /// In en, this message translates to:
  /// **'Top up'**
  String get actionTopUp;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @inviteFriends.
  ///
  /// In en, this message translates to:
  /// **'Invite friends'**
  String get inviteFriends;

  /// No description provided for @myDevices.
  ///
  /// In en, this message translates to:
  /// **'My devices'**
  String get myDevices;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutConfirmTitle;

  /// No description provided for @signOutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out of your account?'**
  String get signOutConfirmBody;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @notifEsimTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifEsimTitle;

  /// No description provided for @notifEsimBody.
  ///
  /// In en, this message translates to:
  /// **'eSIM status, balance and data usage'**
  String get notifEsimBody;

  /// No description provided for @notifNewsTitle.
  ///
  /// In en, this message translates to:
  /// **'News & offers'**
  String get notifNewsTitle;

  /// No description provided for @notifNewsBody.
  ///
  /// In en, this message translates to:
  /// **'Discounts and new countries'**
  String get notifNewsBody;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version} ({build})'**
  String aboutVersion(String version, String build);

  /// No description provided for @aboutTagline.
  ///
  /// In en, this message translates to:
  /// **'Mobile internet for travel'**
  String get aboutTagline;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About the app'**
  String get aboutApp;

  /// No description provided for @devicesTitle.
  ///
  /// In en, this message translates to:
  /// **'My devices'**
  String get devicesTitle;

  /// No description provided for @devicesNote.
  ///
  /// In en, this message translates to:
  /// **'Manage the devices signed in to your account.'**
  String get devicesNote;

  /// No description provided for @deviceRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove device'**
  String get deviceRemove;

  /// No description provided for @deviceRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this device?'**
  String get deviceRemoveTitle;

  /// No description provided for @deviceRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'Sign out of Waysim on {device}? You can sign in again on that device.'**
  String deviceRemoveBody(String device);

  /// No description provided for @deviceRemoved.
  ///
  /// In en, this message translates to:
  /// **'Device removed.'**
  String get deviceRemoved;

  /// No description provided for @deviceThis.
  ///
  /// In en, this message translates to:
  /// **'This device'**
  String get deviceThis;

  /// No description provided for @deviceLastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last active {ago}'**
  String deviceLastSeen(String ago);

  /// No description provided for @deleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteTitle;

  /// No description provided for @deleteWarnTitle.
  ///
  /// In en, this message translates to:
  /// **'This can’t be undone'**
  String get deleteWarnTitle;

  /// No description provided for @deleteBullet1.
  ///
  /// In en, this message translates to:
  /// **'Your balance ({balance}) and bonuses will be lost.'**
  String deleteBullet1(String balance);

  /// No description provided for @deleteBullet2.
  ///
  /// In en, this message translates to:
  /// **'Plans that aren’t installed yet will be cancelled without a refund.'**
  String get deleteBullet2;

  /// No description provided for @deleteBullet3.
  ///
  /// In en, this message translates to:
  /// **'eSIMs that are already installed keep working until the plan ends.'**
  String get deleteBullet3;

  /// No description provided for @deleteBullet4.
  ///
  /// In en, this message translates to:
  /// **'Personal data is anonymized within 30 days. Payment records are kept for as long as the law requires.'**
  String get deleteBullet4;

  /// No description provided for @deleteRefundNote.
  ///
  /// In en, this message translates to:
  /// **'Want a refund of an unused top-up? Contact support before deleting.'**
  String get deleteRefundNote;

  /// No description provided for @deleteSupportLink.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get deleteSupportLink;

  /// No description provided for @deleteCodeBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code we sent to {email} to confirm.'**
  String deleteCodeBody(String email);

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get deleteConfirm;

  /// No description provided for @deleteDone.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get deleteDone;

  /// No description provided for @topUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Top up balance'**
  String get topUpTitle;

  /// No description provided for @topUpCurrentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current balance'**
  String get topUpCurrentBalance;

  /// No description provided for @topUpChooseAmount.
  ///
  /// In en, this message translates to:
  /// **'Choose amount'**
  String get topUpChooseAmount;

  /// No description provided for @topUpOtherAmount.
  ///
  /// In en, this message translates to:
  /// **'Other amount'**
  String get topUpOtherAmount;

  /// No description provided for @topUpAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Amount in USD'**
  String get topUpAmountHint;

  /// No description provided for @topUpAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount from {min} to {max}'**
  String topUpAmountInvalid(String min, String max);

  /// No description provided for @topUpMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get topUpMethod;

  /// No description provided for @topUpPaypalTitle.
  ///
  /// In en, this message translates to:
  /// **'PayPal'**
  String get topUpPaypalTitle;

  /// No description provided for @topUpPaypalBody.
  ///
  /// In en, this message translates to:
  /// **'PayPal balance or card via PayPal'**
  String get topUpPaypalBody;

  /// No description provided for @topUpCryptoTitle.
  ///
  /// In en, this message translates to:
  /// **'Cryptocurrency'**
  String get topUpCryptoTitle;

  /// No description provided for @topUpCryptoBody.
  ///
  /// In en, this message translates to:
  /// **'Choose a coin and network'**
  String get topUpCryptoBody;

  /// No description provided for @topUpMinimumLabel.
  ///
  /// In en, this message translates to:
  /// **'Minimum top-up'**
  String get topUpMinimumLabel;

  /// No description provided for @topUpPaymentFeeIncluded.
  ///
  /// In en, this message translates to:
  /// **'Payment fee is included in the amount to send'**
  String get topUpPaymentFeeIncluded;

  /// No description provided for @topUpNote.
  ///
  /// In en, this message translates to:
  /// **'Your balance is spent only on eSIM plans and can’t be withdrawn. An unused top-up can be refunded under the Refund Policy. The payment service may charge a fee.'**
  String get topUpNote;

  /// No description provided for @topUpButton.
  ///
  /// In en, this message translates to:
  /// **'Top up {amount}'**
  String topUpButton(String amount);

  /// No description provided for @topUpPaypalWaitingTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting for PayPal'**
  String get topUpPaypalWaitingTitle;

  /// No description provided for @topUpPaypalWaitingBody.
  ///
  /// In en, this message translates to:
  /// **'Complete the payment in the PayPal window. This screen updates by itself.'**
  String get topUpPaypalWaitingBody;

  /// No description provided for @topUpReopenPaypal.
  ///
  /// In en, this message translates to:
  /// **'Open PayPal again'**
  String get topUpReopenPaypal;

  /// No description provided for @cryptoTitle.
  ///
  /// In en, this message translates to:
  /// **'Pay with crypto'**
  String get cryptoTitle;

  /// No description provided for @cryptoCoin.
  ///
  /// In en, this message translates to:
  /// **'Coin'**
  String get cryptoCoin;

  /// No description provided for @cryptoNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get cryptoNetwork;

  /// No description provided for @cryptoWaitingPayment.
  ///
  /// In en, this message translates to:
  /// **'Waiting for payment'**
  String get cryptoWaitingPayment;

  /// No description provided for @cryptoStepWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get cryptoStepWaiting;

  /// No description provided for @cryptoStepConfirmations.
  ///
  /// In en, this message translates to:
  /// **'Confirmations'**
  String get cryptoStepConfirmations;

  /// No description provided for @cryptoStepCredited.
  ///
  /// In en, this message translates to:
  /// **'Credited'**
  String get cryptoStepCredited;

  /// No description provided for @cryptoConfirmationsOf.
  ///
  /// In en, this message translates to:
  /// **'{n} of {m}'**
  String cryptoConfirmationsOf(int n, int m);

  /// No description provided for @cryptoSendExactly.
  ///
  /// In en, this message translates to:
  /// **'Send exactly'**
  String get cryptoSendExactly;

  /// No description provided for @cryptoToAddress.
  ///
  /// In en, this message translates to:
  /// **'To address'**
  String get cryptoToAddress;

  /// No description provided for @cryptoRateLocked.
  ///
  /// In en, this message translates to:
  /// **'Rate locked: {rate} · Top-up of {amount}'**
  String cryptoRateLocked(String rate, String amount);

  /// No description provided for @cryptoFeeOnTop.
  ///
  /// In en, this message translates to:
  /// **'{amount} + {fee} fee = {total}'**
  String cryptoFeeOnTop(String amount, String fee, String total);

  /// No description provided for @contactsTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get contactsTitle;

  /// No description provided for @cryptoWarning.
  ///
  /// In en, this message translates to:
  /// **'Send only {coin} on the {network} network, the exact amount in one transaction. Add the wallet fee on top — the full amount must reach us.'**
  String cryptoWarning(String coin, String network);

  /// No description provided for @cryptoCloseNote.
  ///
  /// In en, this message translates to:
  /// **'You can close this screen — we’ll send a notification when the payment is credited.'**
  String get cryptoCloseNote;

  /// No description provided for @cryptoChangeAmountAction.
  ///
  /// In en, this message translates to:
  /// **'Change amount'**
  String get cryptoChangeAmountAction;

  /// No description provided for @cryptoChangeAmountTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a different amount?'**
  String get cryptoChangeAmountTitle;

  /// No description provided for @cryptoChangeAmountBody.
  ///
  /// In en, this message translates to:
  /// **'This payment request stays active until its timer ends. If you already sent crypto, wait for this payment to finish. Otherwise, you can create a new payment request with a different amount.'**
  String get cryptoChangeAmountBody;

  /// No description provided for @cryptoChangeCurrencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Change coin or network?'**
  String get cryptoChangeCurrencyTitle;

  /// No description provided for @cryptoChangeCurrencyBody.
  ///
  /// In en, this message translates to:
  /// **'A different coin or network needs a new payment address. The current payment request remains active until it expires. If you already sent crypto, wait for this payment to finish.'**
  String get cryptoChangeCurrencyBody;

  /// No description provided for @cryptoChangeCurrencyAction.
  ///
  /// In en, this message translates to:
  /// **'Create new payment'**
  String get cryptoChangeCurrencyAction;

  /// No description provided for @topUpDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Balance topped up'**
  String get topUpDoneTitle;

  /// No description provided for @topUpDoneBody.
  ///
  /// In en, this message translates to:
  /// **'{amount} was added to your balance.'**
  String topUpDoneBody(String amount);

  /// No description provided for @actionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// No description provided for @topUpExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment expired'**
  String get topUpExpiredTitle;

  /// No description provided for @topUpExpiredBody.
  ///
  /// In en, this message translates to:
  /// **'If you already sent the money, it will be credited after a check. Otherwise start again.'**
  String get topUpExpiredBody;

  /// No description provided for @actionTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get actionTryAgain;

  /// No description provided for @ordersTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersTitle;

  /// No description provided for @ordersTabPurchases.
  ///
  /// In en, this message translates to:
  /// **'Purchases'**
  String get ordersTabPurchases;

  /// No description provided for @ordersTabTopUps.
  ///
  /// In en, this message translates to:
  /// **'Top-ups'**
  String get ordersTabTopUps;

  /// No description provided for @ordersTabActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get ordersTabActivity;

  /// No description provided for @ordersEmptyPurchases.
  ///
  /// In en, this message translates to:
  /// **'No purchases yet'**
  String get ordersEmptyPurchases;

  /// No description provided for @ordersEmptyTopUps.
  ///
  /// In en, this message translates to:
  /// **'No top-ups yet'**
  String get ordersEmptyTopUps;

  /// No description provided for @ordersEmptyActivity.
  ///
  /// In en, this message translates to:
  /// **'No balance activity yet'**
  String get ordersEmptyActivity;

  /// No description provided for @paymentDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment details'**
  String get paymentDetailTitle;

  /// No description provided for @paymentDetailBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Payment breakdown'**
  String get paymentDetailBreakdown;

  /// No description provided for @paymentDetailTransaction.
  ///
  /// In en, this message translates to:
  /// **'Transaction details'**
  String get paymentDetailTransaction;

  /// No description provided for @orderDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Order details'**
  String get orderDetailTitle;

  /// No description provided for @activityDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity details'**
  String get activityDetailTitle;

  /// No description provided for @detailOrderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order number'**
  String get detailOrderNumber;

  /// No description provided for @detailStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get detailStatus;

  /// No description provided for @detailPackage.
  ///
  /// In en, this message translates to:
  /// **'Package'**
  String get detailPackage;

  /// No description provided for @detailFailureReason.
  ///
  /// In en, this message translates to:
  /// **'Failure reason'**
  String get detailFailureReason;

  /// No description provided for @detailCompletedAt.
  ///
  /// In en, this message translates to:
  /// **'Completed at'**
  String get detailCompletedAt;

  /// No description provided for @detailEsimId.
  ///
  /// In en, this message translates to:
  /// **'eSIM ID'**
  String get detailEsimId;

  /// No description provided for @detailOrderId.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get detailOrderId;

  /// No description provided for @detailViewEsim.
  ///
  /// In en, this message translates to:
  /// **'View eSIM'**
  String get detailViewEsim;

  /// No description provided for @detailType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get detailType;

  /// No description provided for @detailNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get detailNote;

  /// No description provided for @detailBalanceAfter.
  ///
  /// In en, this message translates to:
  /// **'Balance after'**
  String get detailBalanceAfter;

  /// No description provided for @detailReference.
  ///
  /// In en, this message translates to:
  /// **'Related record'**
  String get detailReference;

  /// No description provided for @detailEntryId.
  ///
  /// In en, this message translates to:
  /// **'Activity ID'**
  String get detailEntryId;

  /// No description provided for @detailViewReference.
  ///
  /// In en, this message translates to:
  /// **'View related details'**
  String get detailViewReference;

  /// No description provided for @paymentDetailTopUpAmount.
  ///
  /// In en, this message translates to:
  /// **'Top-up amount'**
  String get paymentDetailTopUpAmount;

  /// No description provided for @paymentDetailNumber.
  ///
  /// In en, this message translates to:
  /// **'Payment number'**
  String get paymentDetailNumber;

  /// No description provided for @paymentDetailDate.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get paymentDetailDate;

  /// No description provided for @paymentDetailCurrency.
  ///
  /// In en, this message translates to:
  /// **'Coin and network'**
  String get paymentDetailCurrency;

  /// No description provided for @paymentDetailExpected.
  ///
  /// In en, this message translates to:
  /// **'Amount requested'**
  String get paymentDetailExpected;

  /// No description provided for @paymentDetailReceived.
  ///
  /// In en, this message translates to:
  /// **'Amount received'**
  String get paymentDetailReceived;

  /// No description provided for @paymentDetailFee.
  ///
  /// In en, this message translates to:
  /// **'Payment fee'**
  String get paymentDetailFee;

  /// No description provided for @paymentDetailTotal.
  ///
  /// In en, this message translates to:
  /// **'Total in USD'**
  String get paymentDetailTotal;

  /// No description provided for @paymentDetailProviderStatus.
  ///
  /// In en, this message translates to:
  /// **'Provider status'**
  String get paymentDetailProviderStatus;

  /// No description provided for @paymentDetailTransactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get paymentDetailTransactionId;

  /// No description provided for @paymentDetailCredited.
  ///
  /// In en, this message translates to:
  /// **'Added to balance'**
  String get paymentDetailCredited;

  /// No description provided for @paymentDetailCreditedAt.
  ///
  /// In en, this message translates to:
  /// **'Credited'**
  String get paymentDetailCreditedAt;

  /// No description provided for @paymentDetailId.
  ///
  /// In en, this message translates to:
  /// **'Payment ID'**
  String get paymentDetailId;

  /// No description provided for @paymentDetailContinue.
  ///
  /// In en, this message translates to:
  /// **'View payment instructions'**
  String get paymentDetailContinue;

  /// No description provided for @paymentDetailReview.
  ///
  /// In en, this message translates to:
  /// **'This payment needs a manual review before the balance can be updated.'**
  String get paymentDetailReview;

  /// No description provided for @paymentDetailOverpaid.
  ///
  /// In en, this message translates to:
  /// **'The payment provider received more than requested. Support will review the payment before updating your balance.'**
  String get paymentDetailOverpaid;

  /// No description provided for @paymentDetailUnderpaid.
  ///
  /// In en, this message translates to:
  /// **'The payment provider received less than requested. Support will review the payment before updating your balance.'**
  String get paymentDetailUnderpaid;

  /// No description provided for @paymentDetailLate.
  ///
  /// In en, this message translates to:
  /// **'The payment arrived after the payment window ended. Support will review it before updating your balance.'**
  String get paymentDetailLate;

  /// No description provided for @orderNumberDate.
  ///
  /// In en, this message translates to:
  /// **'Order {number} · {date}'**
  String orderNumberDate(String number, String date);

  /// No description provided for @orderCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get orderCompleted;

  /// No description provided for @orderPurchaseTitle.
  ///
  /// In en, this message translates to:
  /// **'{place} · {plan}'**
  String orderPurchaseTitle(String place, String plan);

  /// No description provided for @orderAddOnTitle.
  ///
  /// In en, this message translates to:
  /// **'Package top-up · {place} +{plan}'**
  String orderAddOnTitle(String place, String plan);

  /// No description provided for @orderTopUpPaypal.
  ///
  /// In en, this message translates to:
  /// **'Balance top-up · PayPal'**
  String get orderTopUpPaypal;

  /// No description provided for @orderTopUpCrypto.
  ///
  /// In en, this message translates to:
  /// **'Balance top-up · Crypto'**
  String get orderTopUpCrypto;

  /// No description provided for @referralTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite friends'**
  String get referralTitle;

  /// No description provided for @referralHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Get {reward} for every friend'**
  String referralHeroTitle(String reward);

  /// No description provided for @referralHeroBody.
  ///
  /// In en, this message translates to:
  /// **'A friend signs up with your code — you get {reward} added to your balance.'**
  String referralHeroBody(String reward);

  /// No description provided for @referralYourCode.
  ///
  /// In en, this message translates to:
  /// **'Your code'**
  String get referralYourCode;

  /// No description provided for @referralShare.
  ///
  /// In en, this message translates to:
  /// **'Share invite'**
  String get referralShare;

  /// No description provided for @referralShareText.
  ///
  /// In en, this message translates to:
  /// **'Traveling soon? Explore eSIM plans with Waysim. Use my invite code when you sign up:\n{code}'**
  String referralShareText(String code);

  /// No description provided for @referralShareLinkText.
  ///
  /// In en, this message translates to:
  /// **'Traveling soon? Explore eSIM plans with Waysim. Sign up using my invite link:\n{link}\n\nInvite code: {code}'**
  String referralShareLinkText(String link, String code);

  /// No description provided for @referralStatInvited.
  ///
  /// In en, this message translates to:
  /// **'Invited'**
  String get referralStatInvited;

  /// No description provided for @referralStatCredited.
  ///
  /// In en, this message translates to:
  /// **'Credited'**
  String get referralStatCredited;

  /// No description provided for @referralStatPending.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get referralStatPending;

  /// No description provided for @referralStatRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get referralStatRejected;

  /// No description provided for @referralRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get referralRulesTitle;

  /// No description provided for @referralRule1.
  ///
  /// In en, this message translates to:
  /// **'The bonus can only be spent on eSIM plans and can’t be withdrawn.'**
  String get referralRule1;

  /// No description provided for @referralRule2.
  ///
  /// In en, this message translates to:
  /// **'Only new Waysim users count — one bonus per device.'**
  String get referralRule2;

  /// No description provided for @referralRule3.
  ///
  /// In en, this message translates to:
  /// **'No more than 10 bonuses a month.'**
  String get referralRule3;

  /// No description provided for @referralRule4.
  ///
  /// In en, this message translates to:
  /// **'Invitations are checked automatically. Inviting yourself and fake accounts are rejected.'**
  String get referralRule4;

  /// No description provided for @referralRule5.
  ///
  /// In en, this message translates to:
  /// **'The bonus amount is fixed when your friend signs up.'**
  String get referralRule5;

  /// No description provided for @referralFullTerms.
  ///
  /// In en, this message translates to:
  /// **'Full terms'**
  String get referralFullTerms;

  /// No description provided for @referralYourInvites.
  ///
  /// In en, this message translates to:
  /// **'Your invites'**
  String get referralYourInvites;

  /// No description provided for @referralInviteCredited.
  ///
  /// In en, this message translates to:
  /// **'+{reward} credited'**
  String referralInviteCredited(String reward);

  /// No description provided for @referralInviteSignedUp.
  ///
  /// In en, this message translates to:
  /// **'Signed up: {date}'**
  String referralInviteSignedUp(String date);

  /// No description provided for @referralEmpty.
  ///
  /// In en, this message translates to:
  /// **'No invitations yet'**
  String get referralEmpty;

  /// No description provided for @supportSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'How can we help?'**
  String get supportSheetTitle;

  /// No description provided for @supportAiTitle.
  ///
  /// In en, this message translates to:
  /// **'Online AI chat'**
  String get supportAiTitle;

  /// No description provided for @supportAiBody.
  ///
  /// In en, this message translates to:
  /// **'Instant answers 24/7'**
  String get supportAiBody;

  /// No description provided for @supportMailTitle.
  ///
  /// In en, this message translates to:
  /// **'Write to us'**
  String get supportMailTitle;

  /// No description provided for @supportMailBody.
  ///
  /// In en, this message translates to:
  /// **'A person will reply by e-mail'**
  String get supportMailBody;

  /// No description provided for @supportMailSubject.
  ///
  /// In en, this message translates to:
  /// **'Waysim — request, ID {id}'**
  String supportMailSubject(String id);

  /// No description provided for @supportMailTemplate.
  ///
  /// In en, this message translates to:
  /// **'Describe your question here.\n\n— Technical details —\nID: {id}\nApp: {app}\nSystem: {system}'**
  String supportMailTemplate(String id, String app, String system);

  /// No description provided for @supportMailFallback.
  ///
  /// In en, this message translates to:
  /// **'No mail app found. Our address is {email}.'**
  String supportMailFallback(String email);

  /// No description provided for @actionCopyAddress.
  ///
  /// In en, this message translates to:
  /// **'Copy address'**
  String get actionCopyAddress;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Waysim assistant'**
  String get chatTitle;

  /// No description provided for @chatBadge.
  ///
  /// In en, this message translates to:
  /// **'AI-powered'**
  String get chatBadge;

  /// No description provided for @chatDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'AI can make mistakes. It can’t see your payments or change your balance. Don’t send passwords or card details.'**
  String get chatDisclaimer;

  /// No description provided for @chatGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi! I’m the Waysim AI assistant. Ask me about choosing a plan, installing an eSIM or connecting abroad.'**
  String get chatGreeting;

  /// No description provided for @chatChipInstall.
  ///
  /// In en, this message translates to:
  /// **'How do I install an eSIM?'**
  String get chatChipInstall;

  /// No description provided for @chatChipChoose.
  ///
  /// In en, this message translates to:
  /// **'Which plan should I choose?'**
  String get chatChipChoose;

  /// No description provided for @chatChipNetwork.
  ///
  /// In en, this message translates to:
  /// **'My eSIM won’t connect'**
  String get chatChipNetwork;

  /// No description provided for @chatNotHelped.
  ///
  /// In en, this message translates to:
  /// **'Didn’t help?'**
  String get chatNotHelped;

  /// No description provided for @chatContactHuman.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get chatContactHuman;

  /// No description provided for @chatInputHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message'**
  String get chatInputHint;

  /// No description provided for @chatHistoryNote.
  ///
  /// In en, this message translates to:
  /// **'Chat history is kept for 30 days'**
  String get chatHistoryNote;

  /// No description provided for @updateRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Please update the app'**
  String get updateRequiredTitle;

  /// No description provided for @updateRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'This version is no longer supported. Update Waysim to keep buying and using your eSIMs.'**
  String get updateRequiredBody;

  /// No description provided for @updateRequiredAction.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateRequiredAction;

  /// No description provided for @integrityWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'This device can’t earn referral bonuses'**
  String get integrityWarningTitle;

  /// No description provided for @integrityWarningBody.
  ///
  /// In en, this message translates to:
  /// **'Your phone looks modified (root, jailbreak or emulator). Everything else works as usual.'**
  String get integrityWarningBody;

  /// No description provided for @noConnectionTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get noConnectionTitle;

  /// No description provided for @noConnectionBody.
  ///
  /// In en, this message translates to:
  /// **'Waysim needs the internet to load plans and your eSIMs. Check Wi‑Fi or mobile data and try again.'**
  String get noConnectionBody;

  /// No description provided for @noConnectionWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for a connection…'**
  String get noConnectionWaiting;

  /// No description provided for @noConnectionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue offline'**
  String get noConnectionContinue;

  /// No description provided for @statusSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get statusSuspended;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusRevoked.
  ///
  /// In en, this message translates to:
  /// **'Revoked'**
  String get statusRevoked;

  /// No description provided for @statusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statusFailed;

  /// No description provided for @paymentReview.
  ///
  /// In en, this message translates to:
  /// **'Payment under review'**
  String get paymentReview;

  /// No description provided for @paymentPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get paymentPending;

  /// No description provided for @paymentMemo.
  ///
  /// In en, this message translates to:
  /// **'Memo / destination tag'**
  String get paymentMemo;

  /// No description provided for @supportTeam.
  ///
  /// In en, this message translates to:
  /// **'Support team'**
  String get supportTeam;

  /// No description provided for @supportLiveDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Your messages go to the Waysim support team.'**
  String get supportLiveDisclaimer;

  /// No description provided for @supportLiveGreeting.
  ///
  /// In en, this message translates to:
  /// **'Send us your question about Waysim or your eSIM.'**
  String get supportLiveGreeting;

  /// No description provided for @inviteCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid invitation code. Check it and try again.'**
  String get inviteCodeInvalid;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment not completed'**
  String get paymentFailed;

  /// No description provided for @paymentFailedBody.
  ///
  /// In en, this message translates to:
  /// **'This payment did not complete. Contact support if you already sent funds.'**
  String get paymentFailedBody;

  /// No description provided for @activationOnInstall.
  ///
  /// In en, this message translates to:
  /// **'Starts when the eSIM is installed.'**
  String get activationOnInstall;

  /// Title of the pre-permission card shown before the system notification dialog
  ///
  /// In en, this message translates to:
  /// **'Allow notifications for the best Waysim experience'**
  String get notifPromptTitle;

  /// Notification pre-permission card text
  ///
  /// In en, this message translates to:
  /// **'Get alerts like low data warnings. We\'ll also send occasional deals and offers — you can change your notification preferences anytime from your profile.'**
  String get notifPromptBody;

  /// Notification pre-permission card text
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get notifPromptLater;

  /// Notification pre-permission card text
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get notifPromptEnable;

  /// Unsupported-device card and sheet text
  ///
  /// In en, this message translates to:
  /// **'Your device doesn\'t support eSIMs'**
  String get compatNoRow;

  /// Unsupported-device card and sheet text
  ///
  /// In en, this message translates to:
  /// **'Check your device'**
  String get compatNoSheetTitle;

  /// Unsupported-device card and sheet text
  ///
  /// In en, this message translates to:
  /// **'You might not be able to use Waysim on this device.'**
  String get compatNoBody;

  /// Unsupported-device card and sheet text
  ///
  /// In en, this message translates to:
  /// **'If you\'re buying for another device, just '**
  String get compatNoOtherLead;

  /// Unsupported-device card and sheet text
  ///
  /// In en, this message translates to:
  /// **'make sure it supports eSIMs and is not locked to a carrier or network.'**
  String get compatNoOtherBold;

  /// Supported-device card and sheet text
  ///
  /// In en, this message translates to:
  /// **'Your device supports eSIMs'**
  String get compatYesRow;

  /// Supported-device card and sheet text
  ///
  /// In en, this message translates to:
  /// **'Great! If you got your device through a mobile provider, '**
  String get compatYesLead;

  /// Supported-device card and sheet text
  ///
  /// In en, this message translates to:
  /// **'make sure it’s not locked to a carrier or network.'**
  String get compatYesBold;

  /// Supported-device card and sheet text
  ///
  /// In en, this message translates to:
  /// **'How to check if your device is locked to a carrier or network'**
  String get compatLockTitle;

  /// Supported-device card and sheet text
  ///
  /// In en, this message translates to:
  /// **'Open Settings → General → About. Carrier Lock should say “No SIM restrictions”. A carrier lock can prevent a travel eSIM from working.'**
  String get compatLockIos;

  /// Supported-device card and sheet text
  ///
  /// In en, this message translates to:
  /// **'Open your device settings and look for SIM, carrier, or network lock (for example Settings → Connections → SIM manager). If it shows no lock or restrictions, you’re good to go!'**
  String get compatLockAndroid;

  /// Supported-device card and sheet text
  ///
  /// In en, this message translates to:
  /// **'If it shows a lock or restrictions, you may need to contact your mobile provider.'**
  String get compatLockTip;

  /// Unsupported-device card and sheet text
  ///
  /// In en, this message translates to:
  /// **'Check supported devices'**
  String get compatNoCheckDevices;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr', 'ru', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

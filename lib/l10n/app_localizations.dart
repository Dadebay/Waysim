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

abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ru'),
    Locale('zh'),
  ];

  String get appName;

  String get tabHome;

  String get tabMyEsim;

  String get tabProfile;

  String greetingNamed(String name);

  String get greeting;

  String get signIn;

  String get searchHint;

  String get supportFabLabel;

  String get homeLocal;

  String get homeRegional;

  String priceFrom(String price);

  String get myEsimTitle;

  String get myEsimCurrent;

  String get myEsimArchive;

  String get myEsimEmptyTitle;

  String get myEsimEmptyBody;

  String get buyEsim;

  String get howEsimWorks;

  String get profileTitle;

  String get profileGuestTitle;

  String get profileGuestBody;

  String get signUp;

  String get settings;

  String get more;

  String get settingsLanguage;

  String get settingsTheme;

  String get themeLight;

  String get themeDark;

  String get actionRetry;

  String get offlineBanner;

  String get errorNetwork;

  String get errorTimeout;

  String get errorServer;

  String get errorUnauthorized;

  String get signedOutOnDevice;

  String get errorNotFound;

  String get errorUnknown;

  String get actionCopy;

  String get toastCopied;

  String get actionContinue;

  String get actionCancel;

  String get actionClose;

  String get actionGotIt;

  String get actionLater;

  String get actionPasteCode;

  String get settingsGallery;

  String unitGb(String value);

  String unitMb(String value);

  String durationDays(int count);

  String get dataUnlimited;

  String dailyAllowance(String size);

  String unlimitedPlan(String daily, String days);

  String regionCountries(int count);

  String get bannerEsimTitle;

  String get bannerEsimBody;

  String get bannerEsimAction;

  String bannerInviteTitle(String reward);

  String get bannerInviteAction;

  String get bannerTravelTitle;

  String get bannerTravelBody;

  String get bannerTravelAction;

  String get catalogEmpty;

  String get searchRecent;

  String get searchClear;

  String get searchCountries;

  String get searchRegions;

  String searchNoResults(String query);

  String get searchNoResultsHint;

  String get searchBack;

  String get compatSheetTitle;

  String get compatSheetIos;

  String get compatSheetAndroid;

  String get compatUnverifiedRow;

  String get compatWarningTitle;

  String get compatWarningBody;

  String get actionContinueAnyway;

  String get packagesUnlimited;

  String get packagesLimited;

  String get packagesChoose;

  String get esimActivatingNote;

  String get packagesEmpty;

  String get packageDetailsLink;

  String buyFor(String price);

  String get purchaseDisclaimer;

  String get oneTimePurchase;

  String get detailCoverage;

  String get detailData;

  String detailDataFull(String size);

  String detailDataUnlimited(String size);

  String get detailValidity;

  String get detailValidityNote;

  String get detailNetwork;

  String get detailHotspot;

  String get detailTopUp;

  String get detailCalls;

  String get detailInstall;

  String get detailAvailable;

  String get detailUnavailable;

  String get detailDataOnly;

  String get detailCallsIncluded;

  String detailInstallWithin(int count);

  String get coverageCountries;

  String get confirmTitle;

  String get confirmPrice;

  String get confirmBalanceNow;

  String get confirmBalanceAfter;

  String get confirmConsent;

  String confirmPay(String price);

  String get insufficientTitle;

  String insufficientBody(String missing);

  String insufficientAction(String amount);

  String get orderPreparing;

  String get orderPreparingHint;

  String get orderSlow;

  String get orderFailedTitle;

  String get orderFailedBody;

  String orderPriceChanged(String price);

  String get orderBackToPlans;

  String get actionGoToMyEsim;

  String get esimReadyTitle;

  String get esimReadyBody;

  String get esimInstall;

  String get maintenanceBanner;

  String get errorMaintenance;

  String get errorPackageUnavailable;

  String get errorOrderFailed;

  String get errorTooManyRequests;

  String get errorBoundToOtherDevice;

  String get agoJustNow;

  String agoMinutes(int count);

  String agoHours(int count);

  String agoDays(int count);

  String get balanceLabel;

  String get statusProvisioning;

  String get statusNotInstalled;

  String get statusInstalled;

  String get statusActive;

  String get statusUsedUp;

  String get statusExpired;

  String get statusFailedRefunded;

  String get myEsimArchiveEmpty;

  String esimLeftOf(String left, String total);

  String esimDaysLeft(int count);

  String esimInstallBy(String date);

  String get esimValidityFromFirst;

  String esimDeviceUpdated(String device, String ago);

  String esimUpdated(String ago);

  String esimRegionTitle(String name, int count);

  String esimPackageLine(String volume, String duration);

  String get actionInstall;

  String get howTitle;

  String get howStep1Title;

  String get howStep1Body;

  String get howStep2Title;

  String get howStep2Body;

  String get howStep3Title;

  String get howStep3Body;

  String get howStep4Title;

  String get howStep4Body;

  String get esimDetailTitle;

  String get installOneTap;

  String installOneTapNote(String date);

  String get installByQr;

  String get installQrNote;

  String get installQrRetryNote;

  String get installArrivalNote;

  String get installStuckNote;

  String get installLinkFailed;

  String get installManual;

  String get esimSmdp;

  String get esimActivationCode;

  String get esimIccid;

  String get esimFullActivationCode;

  String get esimFullActivationCodeHint;

  String get installManualIosHint;

  String get esimKeepWarning;

  String get esimRoamingWarning;

  String get instructionsTitle;

  String get tabIphone;

  String get tabAndroid;

  String get iosStep1;

  String get iosStep2;

  String get iosStep3;

  String get iosStep4;

  String get iosStep5;

  String get androidStep1;

  String get androidStep2;

  String get androidStep3;

  String get androidStep4;

  String get androidStep5;

  String get usageTitle;

  String get usageUnlimitedNote;

  String get topUpPackage;

  String get topUpPlansTitle;

  String get topUpPlansSubtitle;

  String get topUpPlansEmpty;

  String get topUpAddedTitle;

  String get topUpAddedBody;

  String get loginTitle;

  String get loginBody;

  String get emailLabel;

  String get emailHint;

  String get demoAccounts;

  String get demoNewAccount;

  String get demoExistingAccount;

  String demoCodeHint(String code);

  String get inviteLabel;

  String get termsConsent;

  String get termsConsentStart;

  String get termsOfUseLink;

  String get termsConsentMiddle;

  String get privacyPolicyLink;

  String get termsConsentEnd;

  String get loginErrorEmail;

  String get loginErrorTerms;

  String get codeTitle;

  String get codeInstructions;

  String get codeLabel;

  String resendIn(String time);

  String get resendNow;

  String get changeEmail;

  String get checkSpam;

  String get codeErrorWrong;

  String get codeErrorExpired;

  String get codeErrorTooMany;

  String get nameTitle;

  String get nameBody;

  String get nameHint;

  String get actionSkip;

  String profileId(String id);

  String get actionTopUp;

  String get orders;

  String get inviteFriends;

  String get myDevices;

  String get deleteAccount;

  String get signOut;

  String get signOutConfirmTitle;

  String get signOutConfirmBody;

  String get settingsNotifications;

  String get notifEsimTitle;

  String get notifEsimBody;

  String get notifNewsTitle;

  String get notifNewsBody;

  String aboutVersion(String version, String build);

  String get aboutTagline;

  String get aboutApp;

  String get devicesTitle;

  String get devicesNote;

  String get deviceRemove;

  String get deviceRemoveTitle;

  String deviceRemoveBody(String device);

  String get deviceRemoved;

  String get deviceThis;

  String deviceLastSeen(String ago);

  String get deleteTitle;

  String get deleteWarnTitle;

  String deleteBullet1(String balance);

  String get deleteBullet2;

  String get deleteBullet3;

  String get deleteBullet4;

  String get deleteRefundNote;

  String get deleteSupportLink;

  String deleteCodeBody(String email);

  String get deleteConfirm;

  String get deleteDone;

  String get topUpTitle;

  String get topUpCurrentBalance;

  String get topUpChooseAmount;

  String get topUpOtherAmount;

  String get topUpAmountHint;

  String topUpAmountInvalid(String min, String max);

  String get topUpMethod;

  String get topUpPaypalTitle;

  String get topUpPaypalBody;

  String get topUpCryptoTitle;

  String get topUpCryptoBody;

  String get topUpMinimumLabel;

  String get topUpPaymentFeeIncluded;

  String get topUpNote;

  String topUpButton(String amount);

  String get topUpPaypalWaitingTitle;

  String get topUpPaypalWaitingBody;

  String get topUpReopenPaypal;

  String get cryptoTitle;

  String get cryptoCoin;

  String get cryptoNetwork;

  String get cryptoWaitingPayment;

  String get cryptoStepWaiting;

  String get cryptoStepConfirmations;

  String get cryptoStepCredited;

  String cryptoConfirmationsOf(int n, int m);

  String get cryptoSendExactly;

  String get cryptoToAddress;

  String cryptoRateLocked(String rate, String amount);

  String cryptoFeeOnTop(String amount, String fee, String total);

  String get contactsTitle;

  String cryptoWarning(String coin, String network);

  String get cryptoCloseNote;

  String get cryptoChangeAmountAction;

  String get cryptoChangeAmountTitle;

  String get cryptoChangeAmountBody;

  String get cryptoChangeCurrencyTitle;

  String get cryptoChangeCurrencyBody;

  String get cryptoChangeCurrencyAction;

  String get topUpDoneTitle;

  String topUpDoneBody(String amount);

  String get actionDone;

  String get topUpExpiredTitle;

  String get topUpExpiredBody;

  String get actionTryAgain;

  String get ordersTitle;

  String get ordersTabPurchases;

  String get ordersTabTopUps;

  String get ordersTabActivity;

  String get ordersEmptyPurchases;

  String get ordersEmptyTopUps;

  String get ordersEmptyActivity;

  String get paymentDetailTitle;

  String get paymentDetailBreakdown;

  String get paymentDetailTransaction;

  String get orderDetailTitle;

  String get activityDetailTitle;

  String get detailOrderNumber;

  String get detailStatus;

  String get detailPackage;

  String get detailFailureReason;

  String get detailCompletedAt;

  String get detailEsimId;

  String get detailOrderId;

  String get detailViewEsim;

  String get detailType;

  String get detailNote;

  String get detailBalanceAfter;

  String get detailReference;

  String get detailEntryId;

  String get detailViewReference;

  String get paymentDetailTopUpAmount;

  String get paymentDetailNumber;

  String get paymentDetailDate;

  String get paymentDetailCurrency;

  String get paymentDetailExpected;

  String get paymentDetailReceived;

  String get paymentDetailFee;

  String get paymentDetailTotal;

  String get paymentDetailProviderStatus;

  String get paymentDetailTransactionId;

  String get paymentDetailCredited;

  String get paymentDetailCreditedAt;

  String get paymentDetailId;

  String get paymentDetailContinue;

  String get paymentDetailReview;

  String get paymentDetailOverpaid;

  String get paymentDetailUnderpaid;

  String get paymentDetailLate;

  String orderNumberDate(String number, String date);

  String get orderCompleted;

  String orderPurchaseTitle(String place, String plan);

  String orderAddOnTitle(String place, String plan);

  String get orderTopUpPaypal;

  String get orderTopUpCrypto;

  String get referralTitle;

  String referralHeroTitle(String reward);

  String referralHeroBody(String reward);

  String get referralYourCode;

  String get referralShare;

  String referralShareText(String code);

  String referralShareLinkText(String link, String code);

  String get referralStatInvited;

  String get referralStatCredited;

  String get referralStatPending;

  String get referralStatRejected;

  String get referralRulesTitle;

  String get referralRule1;

  String get referralRule2;

  String get referralRule3;

  String get referralRule4;

  String get referralRule5;

  String get referralFullTerms;

  String get referralYourInvites;

  String referralInviteCredited(String reward);

  String referralInviteSignedUp(String date);

  String get referralEmpty;

  String get supportSheetTitle;

  String get supportAiTitle;

  String get supportAiBody;

  String get supportMailTitle;

  String get supportMailBody;

  String supportMailSubject(String id);

  String supportMailTemplate(String id, String app, String system);

  String supportMailFallback(String email);

  String get actionCopyAddress;

  String get chatTitle;

  String get chatBadge;

  String get chatDisclaimer;

  String get chatGreeting;

  String get chatChipInstall;

  String get chatChipChoose;

  String get chatChipNetwork;

  String get chatNotHelped;

  String get chatContactHuman;

  String get chatInputHint;

  String get chatHistoryNote;

  String get updateRequiredTitle;

  String get updateRequiredBody;

  String get updateRequiredAction;

  String get integrityWarningTitle;

  String get integrityWarningBody;

  String get noConnectionTitle;

  String get noConnectionBody;

  String get noConnectionWaiting;

  String get noConnectionContinue;

  String get statusSuspended;

  String get statusCancelled;

  String get statusRevoked;

  String get statusFailed;

  String get paymentReview;

  String get paymentPending;

  String get paymentMemo;

  String get supportTeam;

  String get supportLiveDisclaimer;

  String get supportLiveGreeting;

  String get inviteCodeInvalid;

  String get paymentFailed;

  String get paymentFailedBody;

  String get activationOnInstall;

  String get notifPromptTitle;

  String get notifPromptBody;

  String get notifPromptLater;

  String get notifPromptEnable;

  String get compatNoRow;

  String get compatNoSheetTitle;

  String get compatNoBody;

  String get compatNoOtherLead;

  String get compatNoOtherBold;

  String get compatYesRow;

  String get compatYesLead;

  String get compatYesBold;

  String get compatLockTitle;

  String get compatLockIos;

  String get compatLockAndroid;

  String get compatLockTip;

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

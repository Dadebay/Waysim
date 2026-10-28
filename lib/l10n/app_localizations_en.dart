// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Waysim';

  @override
  String get tabHome => 'Home';

  @override
  String get tabMyEsim => 'My eSIM';

  @override
  String get tabProfile => 'Profile';

  @override
  String greetingNamed(String name) {
    return 'Hi, $name!';
  }

  @override
  String get greeting => 'Hi!';

  @override
  String get signIn => 'Sign in';

  @override
  String get searchHint => 'Where do you need an eSIM?';

  @override
  String get supportFabLabel => 'Support';

  @override
  String get homeLocal => 'Local';

  @override
  String get homeRegional => 'Regional';

  @override
  String priceFrom(String price) {
    return 'from $price';
  }

  @override
  String get myEsimTitle => 'My eSIM';

  @override
  String get myEsimCurrent => 'Current';

  @override
  String get myEsimArchive => 'Archive';

  @override
  String get myEsimEmptyTitle => 'No eSIMs yet';

  @override
  String get myEsimEmptyBody =>
      'Buy a plan for your trip — it only takes a couple of minutes.';

  @override
  String get buyEsim => 'Get an eSIM';

  @override
  String get howEsimWorks => 'How eSIM works';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileGuestTitle => 'Sign in to buy eSIMs';

  @override
  String get profileGuestBody =>
      'Purchases, balance and eSIMs are saved to your account.';

  @override
  String get signUp => 'Sign up';

  @override
  String get settings => 'Settings';

  @override
  String get more => 'More';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get actionRetry => 'Retry';

  @override
  String get offlineBanner => 'No connection';

  @override
  String get errorNetwork =>
      'No internet connection. Check your network and try again.';

  @override
  String get errorTimeout => 'The request timed out. Please try again.';

  @override
  String get errorServer =>
      'Something went wrong on our side. Please try again later.';

  @override
  String get errorUnauthorized =>
      'Your session has expired. Please sign in again.';

  @override
  String get signedOutOnDevice =>
      'You were signed out on this device. Please sign in again.';

  @override
  String get errorNotFound => 'We couldn\'t find what you were looking for.';

  @override
  String get errorUnknown => 'Something went wrong. Please try again.';

  @override
  String get actionCopy => 'Copy';

  @override
  String get toastCopied => 'Copied';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionClose => 'Close';

  @override
  String get actionGotIt => 'Got it';

  @override
  String get actionLater => 'Later';

  @override
  String get actionPasteCode => 'Paste code';

  @override
  String get settingsGallery => 'Design gallery (debug)';

  @override
  String unitGb(String value) {
    return '$value GB';
  }

  @override
  String unitMb(String value) {
    return '$value MB';
  }

  @override
  String durationDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '$count day',
    );
    return '$_temp0';
  }

  @override
  String get dataUnlimited => 'Unlimited';

  @override
  String dailyAllowance(String size) {
    return '$size a day';
  }

  @override
  String unlimitedPlan(String daily, String days) {
    return 'Unlimited · $daily · $days';
  }

  @override
  String regionCountries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count countries',
      one: '$count country',
    );
    return '$_temp0';
  }

  @override
  String get bannerEsimTitle => 'What is eSIM?';

  @override
  String get bannerEsimBody =>
      'A digital SIM card: set up in minutes, no plastic';

  @override
  String get bannerEsimAction => 'How it works →';

  @override
  String bannerInviteTitle(String reward) {
    return 'Invite a friend — get $reward';
  }

  @override
  String get bannerInviteAction => 'Invite →';

  @override
  String get bannerTravelTitle => 'Online on every trip';

  @override
  String get bannerTravelBody => 'Local plans for popular destinations';

  @override
  String get bannerTravelAction => 'See countries →';

  @override
  String get catalogEmpty => 'No destinations yet';

  @override
  String get searchRecent => 'Recent searches';

  @override
  String get searchClear => 'Clear';

  @override
  String get searchCountries => 'Countries';

  @override
  String get searchRegions => 'Regions';

  @override
  String searchNoResults(String query) {
    return 'Nothing found for “$query”';
  }

  @override
  String get searchNoResultsHint =>
      'Try a country name or code, like “Turkey” or “US”.';

  @override
  String get searchBack => 'Back';

  @override
  String get compatSheetTitle => 'Does my phone support eSIM?';

  @override
  String get compatSheetIos =>
      'Waysim cannot verify eSIM hardware on this iPhone automatically. Some regional versions use two physical SIM cards, so an eSIM plan may not work on this phone.';

  @override
  String get compatSheetAndroid =>
      'Waysim couldn\'t verify eSIM availability on this device. Check the manufacturer\'s specifications before buying a plan.';

  @override
  String get compatUnverifiedRow => 'eSIM support not verified';

  @override
  String get compatWarningTitle => 'Your phone may not support eSIM';

  @override
  String get compatWarningBody =>
      'You can still buy this plan, but the eSIM won’t work on a phone without eSIM support. Continue anyway?';

  @override
  String get actionContinueAnyway => 'Continue anyway';

  @override
  String get packagesUnlimited => 'Unlimited';

  @override
  String get packagesLimited => 'Limited';

  @override
  String get packagesChoose => 'Choose a plan';

  @override
  String get esimActivatingNote =>
      'In some countries the eSIM activates only after you arrive and your phone finds a local network. Until then, Settings may show “Activating…”. That’s normal: don’t delete the eSIM.';

  @override
  String get packagesEmpty => 'No plans in this category';

  @override
  String get packageDetailsLink => 'Package details';

  @override
  String buyFor(String price) {
    return 'Buy for $price';
  }

  @override
  String get purchaseDisclaimer =>
      'By placing the order you confirm that your device is eSIM-compatible and not locked to a carrier.';

  @override
  String get oneTimePurchase =>
      'One-time purchase — no subscription or auto-renewal.';

  @override
  String get detailCoverage => 'Coverage';

  @override
  String get detailData => 'Data';

  @override
  String detailDataFull(String size) {
    return '$size at full speed';
  }

  @override
  String detailDataUnlimited(String size) {
    return 'Unlimited, $size a day at full speed';
  }

  @override
  String get detailValidity => 'Validity';

  @override
  String get detailValidityNote =>
      'Starts from the first connection of the eSIM to a network at your destination';

  @override
  String get detailNetwork => 'Network';

  @override
  String get detailHotspot => 'Hotspot';

  @override
  String get detailTopUp => 'Top-up';

  @override
  String get detailCalls => 'Calls & SMS';

  @override
  String get detailInstall => 'Installation';

  @override
  String get detailAvailable => 'Available';

  @override
  String get detailUnavailable => 'Not available';

  @override
  String get detailDataOnly => 'Data only';

  @override
  String get detailCallsIncluded => 'Included';

  @override
  String detailInstallWithin(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Within $count days',
      one: 'Within $count day',
    );
    return '$_temp0';
  }

  @override
  String get coverageCountries => 'Countries covered';

  @override
  String get confirmTitle => 'Confirm purchase';

  @override
  String get confirmPrice => 'Price';

  @override
  String get confirmBalanceNow => 'Balance now';

  @override
  String get confirmBalanceAfter => 'Balance after purchase';

  @override
  String get confirmConsent =>
      'I want the eSIM issued right away and understand I can’t cancel the purchase once it is installed. One-time purchase — no subscription or auto-renewal.';

  @override
  String confirmPay(String price) {
    return 'Pay $price';
  }

  @override
  String get insufficientTitle => 'Not enough balance';

  @override
  String insufficientBody(String missing) {
    return 'You need $missing more to buy this plan.';
  }

  @override
  String insufficientAction(String amount) {
    return 'Top up $amount';
  }

  @override
  String get orderPreparing => 'Setting up your eSIM…';

  @override
  String get orderPreparingHint => 'This usually takes a few seconds.';

  @override
  String get orderSlow =>
      'This is taking longer than usual. We’ll send a notification when your eSIM is ready.';

  @override
  String get orderFailedTitle => 'Couldn’t complete the order';

  @override
  String get orderFailedBody =>
      'If you were charged, the money has been returned to your balance.';

  @override
  String orderPriceChanged(String price) {
    return 'The price changed to $price. Review it and try again.';
  }

  @override
  String get orderBackToPlans => 'Back to plans';

  @override
  String get actionGoToMyEsim => 'Go to My eSIM';

  @override
  String get esimReadyTitle => 'eSIM is ready!';

  @override
  String get esimReadyBody =>
      'Install it now while you have Wi-Fi. The plan’s days only start counting once you connect at your destination.';

  @override
  String get esimInstall => 'Install eSIM';

  @override
  String get maintenanceBanner =>
      'Purchases and top-ups are temporarily paused.';

  @override
  String get errorMaintenance =>
      'Purchases are temporarily paused. Please try again later.';

  @override
  String get errorPackageUnavailable => 'This plan is no longer available.';

  @override
  String get errorOrderFailed =>
      'The order couldn’t be completed. If you were charged, the money has been returned to your balance.';

  @override
  String get errorTooManyRequests => 'Too many requests. Please wait a moment.';

  @override
  String get errorBoundToOtherDevice =>
      'This eSIM is already linked to another device.';

  @override
  String get agoJustNow => 'just now';

  @override
  String agoMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count min ago',
      one: '$count min ago',
    );
    return '$_temp0';
  }

  @override
  String agoHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count h ago',
      one: '$count h ago',
    );
    return '$_temp0';
  }

  @override
  String agoDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '$count day ago',
    );
    return '$_temp0';
  }

  @override
  String get balanceLabel => 'Balance';

  @override
  String get statusProvisioning => 'Processing';

  @override
  String get statusNotInstalled => 'Not installed';

  @override
  String get statusInstalled => 'Installed';

  @override
  String get statusActive => 'Active';

  @override
  String get statusUsedUp => 'Used up';

  @override
  String get statusExpired => 'Expired';

  @override
  String get statusFailedRefunded => 'Failed, refunded';

  @override
  String get myEsimArchiveEmpty => 'Nothing in the archive';

  @override
  String esimLeftOf(String left, String total) {
    return '$left of $total left';
  }

  @override
  String esimDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left',
      one: '$count day left',
    );
    return '$_temp0';
  }

  @override
  String esimInstallBy(String date) {
    return 'Install by $date';
  }

  @override
  String get esimValidityFromFirst => 'Validity starts on first connection';

  @override
  String esimDeviceUpdated(String device, String ago) {
    return '$device · Updated $ago';
  }

  @override
  String esimUpdated(String ago) {
    return 'Updated $ago';
  }

  @override
  String esimRegionTitle(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count countries',
      one: '$count country',
    );
    return '$name ($_temp0)';
  }

  @override
  String esimPackageLine(String volume, String duration) {
    return '$volume · $duration';
  }

  @override
  String get actionInstall => 'Install';

  @override
  String get howTitle => 'How eSIM works';

  @override
  String get howStep1Title => 'Choose a plan';

  @override
  String get howStep1Body =>
      'Find your destination and pick the data and number of days you need.';

  @override
  String get howStep2Title => 'Pay from your balance';

  @override
  String get howStep2Body =>
      'Top up your balance with PayPal or crypto and buy a plan in one tap.';

  @override
  String get howStep3Title => 'Install before you travel';

  @override
  String get howStep3Body =>
      'Scan the QR code or install in one tap while you have Wi-Fi. Then don’t delete the eSIM.';

  @override
  String get howStep4Title => 'Turn it on when you land';

  @override
  String get howStep4Body =>
      'Select the Waysim eSIM for mobile data and turn on data roaming for it.';

  @override
  String get esimDetailTitle => 'eSIM details';

  @override
  String get installOneTap => 'Install in one tap';

  @override
  String installOneTapNote(String date) {
    return 'For iPhone with iOS 17.4 or later · Install by $date';
  }

  @override
  String get installByQr => 'Install by QR code';

  @override
  String get installQrNote =>
      'Scan the QR code with the camera of the phone you’ll travel with: open this screen on another device or print the code.';

  @override
  String get installQrRetryNote =>
      'Didn\'t install? Try a second time. If it still fails, wait 5 minutes and try again while we finish adding this eSIM to our system.';

  @override
  String get installArrivalNote =>
      'The eSIM connects when you arrive in the destination and your phone finds a local network.';

  @override
  String get installStuckNote =>
      'Installer stuck on “Connecting”? Close it and check Settings → Cellular. If the eSIM isn’t there, install it manually with the details below. If it’s there and shows “Activating…”, that’s normal until you arrive: don’t delete it.';

  @override
  String get installLinkFailed =>
      'Couldn’t open the installer. Use the QR code or manual installation below.';

  @override
  String get installManual => 'Manual installation';

  @override
  String get esimSmdp => 'SM-DP+ address';

  @override
  String get esimActivationCode => 'Activation code';

  @override
  String get esimIccid => 'ICCID';

  @override
  String get esimFullActivationCode => 'Full activation code';

  @override
  String get esimFullActivationCodeHint =>
      'On Samsung/Android, choose Add eSIM → Scan QR code → Enter activation code manually, then paste the full code above, starting with LPA:1\$. Menu names may vary by phone.';

  @override
  String get installManualIosHint =>
      'On iPhone, open Settings → Cellular → Add eSIM → Use QR Code → Enter Details Manually. Paste the SM-DP+ address and activation code above, and leave Confirmation Code empty.';

  @override
  String get esimKeepWarning =>
      'Don’t delete the eSIM from your phone while the plan is active. You can only reinstall it on this same phone.';

  @override
  String get esimRoamingWarning =>
      'To avoid roaming charges from your home carrier, turn off data roaming for your main SIM.';

  @override
  String get instructionsTitle => 'Instructions';

  @override
  String get tabIphone => 'iPhone';

  @override
  String get tabAndroid => 'Android';

  @override
  String get iosStep1 => 'Connect to Wi-Fi.';

  @override
  String get iosStep2 => 'Open Settings → Cellular → Add eSIM.';

  @override
  String get iosStep3 => 'Choose “Use QR Code” or “Enter Details Manually”.';

  @override
  String get iosStep4 =>
      'Name the line “Waysim”. Keep your main number for calls and iMessage.';

  @override
  String get iosStep5 =>
      'When you land, turn on the Waysim line and Data Roaming, and select it for cellular data.';

  @override
  String get androidStep1 => 'Connect to Wi-Fi.';

  @override
  String get androidStep2 =>
      'In Settings, find SIM manager or SIMs, then choose Add eSIM (menu names vary by phone).';

  @override
  String get androidStep3 =>
      'Choose “Scan QR code”. If you can’t scan it, tap the manual entry option below the scanner and paste the full activation code shown above.';

  @override
  String get androidStep4 =>
      'Name the line “Waysim” and keep your main SIM for calls.';

  @override
  String get androidStep5 =>
      'When you land, turn on the Waysim line and Data roaming, and use it for mobile data.';

  @override
  String get usageTitle => 'Data usage';

  @override
  String get usageUnlimitedNote =>
      'Unlimited plan — usage is shown by the carrier';

  @override
  String get topUpPackage => 'Top up package';

  @override
  String get topUpPlansTitle => 'Add data';

  @override
  String get topUpPlansSubtitle => 'Choose a plan to add to this eSIM';

  @override
  String get topUpPlansEmpty => 'No add-on plans are available for this eSIM.';

  @override
  String get topUpAddedTitle => 'Plan added';

  @override
  String get topUpAddedBody => 'The new data and days are now on your eSIM.';

  @override
  String get loginTitle => 'Sign in or sign up';

  @override
  String get loginBody =>
      'We’ll send a 6-digit code to your e-mail. No password needed.';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get emailHint => 'name@example.com';

  @override
  String get demoAccounts => 'Test accounts';

  @override
  String get demoNewAccount => 'New account';

  @override
  String get demoExistingAccount => 'Account with history';

  @override
  String demoCodeHint(String code) {
    return 'Test code: $code (no e-mail is sent)';
  }

  @override
  String get inviteLabel => 'Invite code (optional)';

  @override
  String get termsConsent =>
      'I am 18 or older and accept the Terms of Use. How we process data is in the Privacy Policy.';

  @override
  String get termsConsentStart => 'I am 18 or older and accept the ';

  @override
  String get termsOfUseLink => 'Terms of Use';

  @override
  String get termsConsentMiddle => '. How we process data is in the ';

  @override
  String get privacyPolicyLink => 'Privacy Policy';

  @override
  String get termsConsentEnd => '.';

  @override
  String get loginErrorEmail => 'Enter a valid e-mail address';

  @override
  String get loginErrorTerms => 'Please accept the terms to continue';

  @override
  String get codeTitle => 'Enter the code';

  @override
  String get codeInstructions => 'Enter the 6-digit code to continue.';

  @override
  String get codeLabel => 'Code from the e-mail';

  @override
  String resendIn(String time) {
    return 'Send again in $time';
  }

  @override
  String get resendNow => 'Send again';

  @override
  String get changeEmail => 'Change e-mail';

  @override
  String get checkSpam => 'No e-mail? Check your Spam folder.';

  @override
  String get codeErrorWrong => 'Wrong code. Try again.';

  @override
  String get codeErrorExpired => 'This code has expired. Request a new one.';

  @override
  String get codeErrorTooMany => 'Too many attempts. Please try again later.';

  @override
  String get nameTitle => 'What should we call you?';

  @override
  String get nameBody => 'Optional — we’ll use it to greet you.';

  @override
  String get nameHint => 'Your name';

  @override
  String get actionSkip => 'Skip';

  @override
  String profileId(String id) {
    return 'ID $id';
  }

  @override
  String get actionTopUp => 'Top up';

  @override
  String get orders => 'Orders';

  @override
  String get inviteFriends => 'Invite friends';

  @override
  String get myDevices => 'My devices';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutConfirmTitle => 'Sign out?';

  @override
  String get signOutConfirmBody =>
      'Are you sure you want to sign out of your account?';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get notifEsimTitle => 'Notifications';

  @override
  String get notifEsimBody => 'eSIM status, balance and data usage';

  @override
  String get notifNewsTitle => 'News & offers';

  @override
  String get notifNewsBody => 'Discounts and new countries';

  @override
  String aboutVersion(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String get aboutTagline => 'Mobile internet for travel';

  @override
  String get aboutApp => 'About the app';

  @override
  String get devicesTitle => 'My devices';

  @override
  String get devicesNote => 'Manage the devices signed in to your account.';

  @override
  String get deviceRemove => 'Remove device';

  @override
  String get deviceRemoveTitle => 'Remove this device?';

  @override
  String deviceRemoveBody(String device) {
    return 'Sign out of Waysim on $device? You can sign in again on that device.';
  }

  @override
  String get deviceRemoved => 'Device removed.';

  @override
  String get deviceThis => 'This device';

  @override
  String deviceLastSeen(String ago) {
    return 'Last active $ago';
  }

  @override
  String get deleteTitle => 'Delete account';

  @override
  String get deleteWarnTitle => 'This can’t be undone';

  @override
  String deleteBullet1(String balance) {
    return 'Your balance ($balance) and bonuses will be lost.';
  }

  @override
  String get deleteBullet2 =>
      'Plans that aren’t installed yet will be cancelled without a refund.';

  @override
  String get deleteBullet3 =>
      'eSIMs that are already installed keep working until the plan ends.';

  @override
  String get deleteBullet4 =>
      'Personal data is anonymized within 30 days. Payment records are kept for as long as the law requires.';

  @override
  String get deleteRefundNote =>
      'Want a refund of an unused top-up? Contact support before deleting.';

  @override
  String get deleteSupportLink => 'Contact support';

  @override
  String deleteCodeBody(String email) {
    return 'Enter the 6-digit code we sent to $email to confirm.';
  }

  @override
  String get deleteConfirm => 'Delete my account';

  @override
  String get deleteDone => 'Account deleted';

  @override
  String get topUpTitle => 'Top up balance';

  @override
  String get topUpCurrentBalance => 'Current balance';

  @override
  String get topUpChooseAmount => 'Choose amount';

  @override
  String get topUpOtherAmount => 'Other amount';

  @override
  String get topUpAmountHint => 'Amount in USD';

  @override
  String topUpAmountInvalid(String min, String max) {
    return 'Enter an amount from $min to $max';
  }

  @override
  String get topUpMethod => 'Payment method';

  @override
  String get topUpPaypalTitle => 'PayPal';

  @override
  String get topUpPaypalBody => 'PayPal balance or card via PayPal';

  @override
  String get topUpCryptoTitle => 'Cryptocurrency';

  @override
  String get topUpCryptoBody => 'Choose a coin and network';

  @override
  String get topUpMinimumLabel => 'Minimum top-up';

  @override
  String get topUpPaymentFeeIncluded =>
      'Payment fee is included in the amount to send';

  @override
  String get topUpNote =>
      'Your balance is spent only on eSIM plans and can’t be withdrawn. An unused top-up can be refunded under the Refund Policy. The payment service may charge a fee.';

  @override
  String topUpButton(String amount) {
    return 'Top up $amount';
  }

  @override
  String get topUpPaypalWaitingTitle => 'Waiting for PayPal';

  @override
  String get topUpPaypalWaitingBody =>
      'Complete the payment in the PayPal window. This screen updates by itself.';

  @override
  String get topUpReopenPaypal => 'Open PayPal again';

  @override
  String get cryptoTitle => 'Pay with crypto';

  @override
  String get cryptoCoin => 'Coin';

  @override
  String get cryptoNetwork => 'Network';

  @override
  String get cryptoWaitingPayment => 'Waiting for payment';

  @override
  String get cryptoStepWaiting => 'Waiting';

  @override
  String get cryptoStepConfirmations => 'Confirmations';

  @override
  String get cryptoStepCredited => 'Credited';

  @override
  String cryptoConfirmationsOf(int n, int m) {
    return '$n of $m';
  }

  @override
  String get cryptoSendExactly => 'Send exactly';

  @override
  String get cryptoToAddress => 'To address';

  @override
  String cryptoRateLocked(String rate, String amount) {
    return 'Rate locked: $rate · Top-up of $amount';
  }

  @override
  String cryptoFeeOnTop(String amount, String fee, String total) {
    return '$amount + $fee fee = $total';
  }

  @override
  String get contactsTitle => 'Contact us';

  @override
  String cryptoWarning(String coin, String network) {
    return 'Send only $coin on the $network network, the exact amount in one transaction. Add the wallet fee on top — the full amount must reach us.';
  }

  @override
  String get cryptoCloseNote =>
      'You can close this screen — we’ll send a notification when the payment is credited.';

  @override
  String get cryptoChangeAmountAction => 'Change amount';

  @override
  String get cryptoChangeAmountTitle => 'Choose a different amount?';

  @override
  String get cryptoChangeAmountBody =>
      'This payment request stays active until its timer ends. If you already sent crypto, wait for this payment to finish. Otherwise, you can create a new payment request with a different amount.';

  @override
  String get cryptoChangeCurrencyTitle => 'Change coin or network?';

  @override
  String get cryptoChangeCurrencyBody =>
      'A different coin or network needs a new payment address. The current payment request remains active until it expires. If you already sent crypto, wait for this payment to finish.';

  @override
  String get cryptoChangeCurrencyAction => 'Create new payment';

  @override
  String get topUpDoneTitle => 'Balance topped up';

  @override
  String topUpDoneBody(String amount) {
    return '$amount was added to your balance.';
  }

  @override
  String get actionDone => 'Done';

  @override
  String get topUpExpiredTitle => 'Payment expired';

  @override
  String get topUpExpiredBody =>
      'If you already sent the money, it will be credited after a check. Otherwise start again.';

  @override
  String get actionTryAgain => 'Try again';

  @override
  String get ordersTitle => 'Orders';

  @override
  String get ordersTabPurchases => 'Purchases';

  @override
  String get ordersTabTopUps => 'Top-ups';

  @override
  String get ordersTabActivity => 'Activity';

  @override
  String get ordersEmptyPurchases => 'No purchases yet';

  @override
  String get ordersEmptyTopUps => 'No top-ups yet';

  @override
  String get ordersEmptyActivity => 'No balance activity yet';

  @override
  String get paymentDetailTitle => 'Payment details';

  @override
  String get paymentDetailBreakdown => 'Payment breakdown';

  @override
  String get paymentDetailTransaction => 'Transaction details';

  @override
  String get orderDetailTitle => 'Order details';

  @override
  String get activityDetailTitle => 'Activity details';

  @override
  String get detailOrderNumber => 'Order number';

  @override
  String get detailStatus => 'Status';

  @override
  String get detailPackage => 'Package';

  @override
  String get detailFailureReason => 'Failure reason';

  @override
  String get detailCompletedAt => 'Completed at';

  @override
  String get detailEsimId => 'eSIM ID';

  @override
  String get detailOrderId => 'Order ID';

  @override
  String get detailViewEsim => 'View eSIM';

  @override
  String get detailType => 'Type';

  @override
  String get detailNote => 'Note';

  @override
  String get detailBalanceAfter => 'Balance after';

  @override
  String get detailReference => 'Related record';

  @override
  String get detailEntryId => 'Activity ID';

  @override
  String get detailViewReference => 'View related details';

  @override
  String get paymentDetailTopUpAmount => 'Top-up amount';

  @override
  String get paymentDetailNumber => 'Payment number';

  @override
  String get paymentDetailDate => 'Created';

  @override
  String get paymentDetailCurrency => 'Coin and network';

  @override
  String get paymentDetailExpected => 'Amount requested';

  @override
  String get paymentDetailReceived => 'Amount received';

  @override
  String get paymentDetailFee => 'Payment fee';

  @override
  String get paymentDetailTotal => 'Total in USD';

  @override
  String get paymentDetailProviderStatus => 'Provider status';

  @override
  String get paymentDetailTransactionId => 'Transaction ID';

  @override
  String get paymentDetailCredited => 'Added to balance';

  @override
  String get paymentDetailCreditedAt => 'Credited';

  @override
  String get paymentDetailId => 'Payment ID';

  @override
  String get paymentDetailContinue => 'View payment instructions';

  @override
  String get paymentDetailReview =>
      'This payment needs a manual review before the balance can be updated.';

  @override
  String get paymentDetailOverpaid =>
      'The payment provider received more than requested. Support will review the payment before updating your balance.';

  @override
  String get paymentDetailUnderpaid =>
      'The payment provider received less than requested. Support will review the payment before updating your balance.';

  @override
  String get paymentDetailLate =>
      'The payment arrived after the payment window ended. Support will review it before updating your balance.';

  @override
  String orderNumberDate(String number, String date) {
    return 'Order $number · $date';
  }

  @override
  String get orderCompleted => 'Completed';

  @override
  String orderPurchaseTitle(String place, String plan) {
    return '$place · $plan';
  }

  @override
  String orderAddOnTitle(String place, String plan) {
    return 'Package top-up · $place +$plan';
  }

  @override
  String get orderTopUpPaypal => 'Balance top-up · PayPal';

  @override
  String get orderTopUpCrypto => 'Balance top-up · Crypto';

  @override
  String get referralTitle => 'Invite friends';

  @override
  String referralHeroTitle(String reward) {
    return 'Get $reward for every friend';
  }

  @override
  String referralHeroBody(String reward) {
    return 'A friend signs up with your code — you get $reward added to your balance.';
  }

  @override
  String get referralYourCode => 'Your code';

  @override
  String get referralShare => 'Share invite';

  @override
  String referralShareText(String code) {
    return 'Traveling soon? Explore eSIM plans with Waysim. Use my invite code when you sign up:\n$code';
  }

  @override
  String referralShareLinkText(String link, String code) {
    return 'Traveling soon? Explore eSIM plans with Waysim. Sign up using my invite link:\n$link\n\nInvite code: $code';
  }

  @override
  String get referralStatInvited => 'Invited';

  @override
  String get referralStatCredited => 'Credited';

  @override
  String get referralStatPending => 'Under review';

  @override
  String get referralStatRejected => 'Rejected';

  @override
  String get referralRulesTitle => 'Rules';

  @override
  String get referralRule1 =>
      'The bonus can only be spent on eSIM plans and can’t be withdrawn.';

  @override
  String get referralRule2 =>
      'Only new Waysim users count — one bonus per device.';

  @override
  String get referralRule3 => 'No more than 10 bonuses a month.';

  @override
  String get referralRule4 =>
      'Invitations are checked automatically. Inviting yourself and fake accounts are rejected.';

  @override
  String get referralRule5 =>
      'The bonus amount is fixed when your friend signs up.';

  @override
  String get referralFullTerms => 'Full terms';

  @override
  String get referralYourInvites => 'Your invites';

  @override
  String referralInviteCredited(String reward) {
    return '+$reward credited';
  }

  @override
  String referralInviteSignedUp(String date) {
    return 'Signed up: $date';
  }

  @override
  String get referralEmpty => 'No invitations yet';

  @override
  String get supportSheetTitle => 'How can we help?';

  @override
  String get supportAiTitle => 'Online AI chat';

  @override
  String get supportAiBody => 'Instant answers 24/7';

  @override
  String get supportMailTitle => 'Write to us';

  @override
  String get supportMailBody => 'A person will reply by e-mail';

  @override
  String supportMailSubject(String id) {
    return 'Waysim — request, ID $id';
  }

  @override
  String supportMailTemplate(String id, String app, String system) {
    return 'Describe your question here.\n\n— Technical details —\nID: $id\nApp: $app\nSystem: $system';
  }

  @override
  String supportMailFallback(String email) {
    return 'No mail app found. Our address is $email.';
  }

  @override
  String get actionCopyAddress => 'Copy address';

  @override
  String get chatTitle => 'Waysim assistant';

  @override
  String get chatBadge => 'AI-powered';

  @override
  String get chatDisclaimer =>
      'AI can make mistakes. It can’t see your payments or change your balance. Don’t send passwords or card details.';

  @override
  String get chatGreeting =>
      'Hi! I’m the Waysim AI assistant. Ask me about choosing a plan, installing an eSIM or connecting abroad.';

  @override
  String get chatChipInstall => 'How do I install an eSIM?';

  @override
  String get chatChipChoose => 'Which plan should I choose?';

  @override
  String get chatChipNetwork => 'My eSIM won’t connect';

  @override
  String get chatNotHelped => 'Didn’t help?';

  @override
  String get chatContactHuman => 'Contact support';

  @override
  String get chatInputHint => 'Type a message';

  @override
  String get chatHistoryNote => 'Chat history is kept for 30 days';

  @override
  String get updateRequiredTitle => 'Please update the app';

  @override
  String get updateRequiredBody =>
      'This version is no longer supported. Update Waysim to keep buying and using your eSIMs.';

  @override
  String get updateRequiredAction => 'Update';

  @override
  String get integrityWarningTitle => 'This device can’t earn referral bonuses';

  @override
  String get integrityWarningBody =>
      'Your phone looks modified (root, jailbreak or emulator). Everything else works as usual.';

  @override
  String get noConnectionTitle => 'You\'re offline';

  @override
  String get noConnectionBody =>
      'Waysim needs the internet to load plans and your eSIMs. Check Wi‑Fi or mobile data and try again.';

  @override
  String get noConnectionWaiting => 'Waiting for a connection…';

  @override
  String get noConnectionContinue => 'Continue offline';

  @override
  String get statusSuspended => 'Suspended';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusRevoked => 'Revoked';

  @override
  String get statusFailed => 'Failed';

  @override
  String get paymentReview => 'Payment under review';

  @override
  String get paymentPending => 'Pending';

  @override
  String get paymentMemo => 'Memo / destination tag';

  @override
  String get supportTeam => 'Support team';

  @override
  String get supportLiveDisclaimer =>
      'Your messages go to the Waysim support team.';

  @override
  String get supportLiveGreeting =>
      'Send us your question about Waysim or your eSIM.';

  @override
  String get inviteCodeInvalid =>
      'Invalid invitation code. Check it and try again.';

  @override
  String get paymentFailed => 'Payment not completed';

  @override
  String get paymentFailedBody =>
      'This payment did not complete. Contact support if you already sent funds.';

  @override
  String get activationOnInstall => 'Starts when the eSIM is installed.';

  @override
  String get notifPromptTitle =>
      'Allow notifications for the best Waysim experience';

  @override
  String get notifPromptBody =>
      'Get alerts like low data warnings. We\'ll also send occasional deals and offers — you can change your notification preferences anytime from your profile.';

  @override
  String get notifPromptLater => 'Maybe later';

  @override
  String get notifPromptEnable => 'Turn on';

  @override
  String get compatNoRow => 'Your device doesn\'t support eSIMs';

  @override
  String get compatNoSheetTitle => 'Check your device';

  @override
  String get compatNoBody =>
      'You might not be able to use Waysim on this device.';

  @override
  String get compatNoOtherLead => 'If you\'re buying for another device, just ';

  @override
  String get compatNoOtherBold =>
      'make sure it supports eSIMs and is not locked to a carrier or network.';

  @override
  String get compatYesRow => 'Your device supports eSIMs';

  @override
  String get compatYesLead =>
      'Great! If you got your device through a mobile provider, ';

  @override
  String get compatYesBold =>
      'make sure it’s not locked to a carrier or network.';

  @override
  String get compatLockTitle =>
      'How to check if your device is locked to a carrier or network';

  @override
  String get compatLockIos =>
      'Open Settings → General → About. Carrier Lock should say “No SIM restrictions”. A carrier lock can prevent a travel eSIM from working.';

  @override
  String get compatLockAndroid =>
      'Open your device settings and look for SIM, carrier, or network lock (for example Settings → Connections → SIM manager). If it shows no lock or restrictions, you’re good to go!';

  @override
  String get compatLockTip =>
      'If it shows a lock or restrictions, you may need to contact your mobile provider.';

  @override
  String get compatNoCheckDevices => 'Check supported devices';
}

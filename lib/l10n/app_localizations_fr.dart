// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Waysim';

  @override
  String get tabHome => 'Accueil';

  @override
  String get tabMyEsim => 'Mes eSIM';

  @override
  String get tabProfile => 'Profil';

  @override
  String greetingNamed(String name) {
    return 'Bonjour, $name !';
  }

  @override
  String get greeting => 'Bonjour !';

  @override
  String get signIn => 'Se connecter';

  @override
  String get searchHint => 'Où avez-vous besoin d’une eSIM ?';

  @override
  String get supportFabLabel => 'Aide';

  @override
  String get homeLocal => 'Locales';

  @override
  String get homeRegional => 'Régionales';

  @override
  String priceFrom(String price) {
    return 'dès $price';
  }

  @override
  String get myEsimTitle => 'Mes eSIM';

  @override
  String get myEsimCurrent => 'Actuelles';

  @override
  String get myEsimArchive => 'Archives';

  @override
  String get myEsimEmptyTitle => 'Aucune eSIM pour l’instant';

  @override
  String get myEsimEmptyBody =>
      'Achetez un forfait pour votre voyage : cela ne prend que quelques minutes.';

  @override
  String get buyEsim => 'Obtenir une eSIM';

  @override
  String get howEsimWorks => 'Comment fonctionne l’eSIM';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileGuestTitle => 'Connectez-vous pour acheter des eSIM';

  @override
  String get profileGuestBody =>
      'Vos achats, votre solde et vos eSIM sont enregistrés dans votre compte.';

  @override
  String get signUp => 'S’inscrire';

  @override
  String get settings => 'Réglages';

  @override
  String get more => 'Plus';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get actionRetry => 'Réessayer';

  @override
  String get offlineBanner => 'Pas de connexion';

  @override
  String get errorNetwork =>
      'Pas de connexion internet. Vérifiez votre réseau et réessayez.';

  @override
  String get errorTimeout => 'Délai dépassé. Veuillez réessayer.';

  @override
  String get errorServer =>
      'Un problème est survenu de notre côté. Réessayez plus tard.';

  @override
  String get errorUnauthorized => 'Votre session a expiré. Reconnectez-vous.';

  @override
  String get signedOutOnDevice =>
      'Votre session a été fermée sur cet appareil. Reconnectez-vous.';

  @override
  String get errorNotFound => 'Nous n’avons pas trouvé ce que vous cherchiez.';

  @override
  String get errorUnknown => 'Une erreur s’est produite. Veuillez réessayer.';

  @override
  String get actionCopy => 'Copier';

  @override
  String get toastCopied => 'Copié';

  @override
  String get actionContinue => 'Continuer';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionClose => 'Fermer';

  @override
  String get actionGotIt => 'Compris';

  @override
  String get actionLater => 'Plus tard';

  @override
  String get actionPasteCode => 'Coller le code';

  @override
  String get settingsGallery => 'Galerie de design (debug)';

  @override
  String unitGb(String value) {
    return '$value Go';
  }

  @override
  String unitMb(String value) {
    return '$value Mo';
  }

  @override
  String durationDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours',
      one: '$count jour',
    );
    return '$_temp0';
  }

  @override
  String get dataUnlimited => 'Illimité';

  @override
  String dailyAllowance(String size) {
    return '$size par jour';
  }

  @override
  String unlimitedPlan(String daily, String days) {
    return 'Illimité · $daily · $days';
  }

  @override
  String regionCountries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pays',
      one: '$count pays',
    );
    return '$_temp0';
  }

  @override
  String get bannerEsimTitle => 'Qu’est-ce que l’eSIM ?';

  @override
  String get bannerEsimBody =>
      'Une SIM numérique : activée en quelques minutes, sans plastique';

  @override
  String get bannerEsimAction => 'Comment ça marche →';

  @override
  String bannerInviteTitle(String reward) {
    return 'Invitez un ami et recevez $reward';
  }

  @override
  String get bannerInviteAction => 'Inviter →';

  @override
  String get bannerTravelTitle => 'Internet à chaque voyage';

  @override
  String get bannerTravelBody =>
      'Forfaits locaux pour les destinations populaires';

  @override
  String get bannerTravelAction => 'Voir les pays →';

  @override
  String get catalogEmpty => 'Aucune destination pour l’instant';

  @override
  String get searchRecent => 'Recherches récentes';

  @override
  String get searchClear => 'Effacer';

  @override
  String get searchCountries => 'Pays';

  @override
  String get searchRegions => 'Régions';

  @override
  String searchNoResults(String query) {
    return 'Aucun résultat pour « $query »';
  }

  @override
  String get searchNoResultsHint =>
      'Essayez un nom ou un code de pays : « Turquie », « US ».';

  @override
  String get searchBack => 'Retour';

  @override
  String get compatLabel => 'L’appareil est compatible eSIM :';

  @override
  String get compatYes => 'Oui';

  @override
  String get compatNo => 'Non';

  @override
  String get compatUnknown => 'Inconnu';

  @override
  String get compatHowToCheck => 'Comment vérifier';

  @override
  String get compatSheetTitle => 'Mon téléphone est-il compatible eSIM ?';

  @override
  String get compatSheetIos =>
      'Les iPhone XS, XR et plus récents sont compatibles eSIM. Vérifiez dans Réglages → Général → Informations : cherchez « SIM numérique » ou un numéro EID. Le téléphone doit aussi être désimlocké.';

  @override
  String get compatSheetAndroid =>
      'Ouvrez le clavier et saisissez *#06#. Si un numéro EID s’affiche, votre téléphone est compatible eSIM. Vous pouvez aussi vérifier Paramètres → Connexions → Gestionnaire de SIM. Le téléphone doit être désimlocké.';

  @override
  String get compatWarningTitle =>
      'Votre téléphone n’est peut-être pas compatible eSIM';

  @override
  String get compatWarningBody =>
      'Vous pouvez quand même acheter ce forfait, mais l’eSIM ne fonctionnera pas sur un téléphone non compatible. Continuer malgré tout ?';

  @override
  String get actionContinueAnyway => 'Continuer malgré tout';

  @override
  String get packagesUnlimited => 'Illimités';

  @override
  String get packagesLimited => 'Limités';

  @override
  String get packagesChoose => 'Choisissez un forfait';

  @override
  String get packagesEmpty => 'Aucun forfait dans cette catégorie';

  @override
  String get packageDetailsLink => 'Détails du forfait';

  @override
  String buyFor(String price) {
    return 'Acheter pour $price';
  }

  @override
  String get purchaseDisclaimer =>
      'En passant commande, vous confirmez que votre appareil est compatible eSIM et n’est pas verrouillé par un opérateur.';

  @override
  String get oneTimePurchase =>
      'Achat unique : sans abonnement ni renouvellement automatique.';

  @override
  String get detailCoverage => 'Couverture';

  @override
  String get detailData => 'Données';

  @override
  String detailDataFull(String size) {
    return '$size à pleine vitesse';
  }

  @override
  String detailDataUnlimited(String size) {
    return 'Illimité, $size par jour à pleine vitesse';
  }

  @override
  String get detailValidity => 'Validité';

  @override
  String get detailValidityNote =>
      'Démarre à la première connexion de l’eSIM à un réseau sur place';

  @override
  String get detailNetwork => 'Réseau';

  @override
  String get detailHotspot => 'Partage de connexion';

  @override
  String get detailTopUp => 'Recharge';

  @override
  String get detailCalls => 'Appels et SMS';

  @override
  String get detailInstall => 'Installation';

  @override
  String get detailAvailable => 'Disponible';

  @override
  String get detailUnavailable => 'Non disponible';

  @override
  String get detailDataOnly => 'Données uniquement';

  @override
  String get detailCallsIncluded => 'Inclus';

  @override
  String detailInstallWithin(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sous $count jours',
      one: 'Sous $count jour',
    );
    return '$_temp0';
  }

  @override
  String get coverageCountries => 'Pays couverts';

  @override
  String get confirmTitle => 'Confirmer l’achat';

  @override
  String get confirmPrice => 'Prix';

  @override
  String get confirmBalanceNow => 'Solde actuel';

  @override
  String get confirmBalanceAfter => 'Solde après l’achat';

  @override
  String get confirmConsent =>
      'Je souhaite que l’eSIM soit émise immédiatement et je comprends que je ne pourrai pas annuler l’achat une fois installée. Achat unique : sans abonnement ni renouvellement automatique.';

  @override
  String confirmPay(String price) {
    return 'Payer $price';
  }

  @override
  String get insufficientTitle => 'Solde insuffisant';

  @override
  String insufficientBody(String missing) {
    return 'Il vous manque $missing pour acheter ce forfait.';
  }

  @override
  String insufficientAction(String amount) {
    return 'Recharger $amount';
  }

  @override
  String get orderPreparing => 'Préparation de votre eSIM…';

  @override
  String get orderPreparingHint => 'Cela prend généralement quelques secondes.';

  @override
  String get orderSlow =>
      'Cela prend plus de temps que d’habitude. Nous vous enverrons une notification dès que votre eSIM sera prête.';

  @override
  String get orderFailedTitle => 'La commande n’a pas pu aboutir';

  @override
  String get orderFailedBody =>
      'Si vous avez été débité, la somme a été remboursée sur votre solde.';

  @override
  String orderPriceChanged(String price) {
    return 'Le prix est passé à $price. Vérifiez et réessayez.';
  }

  @override
  String get orderBackToPlans => 'Retour aux forfaits';

  @override
  String get actionGoToMyEsim => 'Aller à Mes eSIM';

  @override
  String get esimReadyTitle => 'Votre eSIM est prête !';

  @override
  String get esimReadyBody =>
      'Installez-la maintenant, tant que vous avez le Wi-Fi. Les jours du forfait ne comptent qu’à la connexion sur place.';

  @override
  String get esimInstall => 'Installer l’eSIM';

  @override
  String get maintenanceBanner =>
      'Les achats et recharges sont temporairement suspendus.';

  @override
  String get errorMaintenance =>
      'Les achats sont temporairement suspendus. Réessayez plus tard.';

  @override
  String get errorPackageUnavailable => 'Ce forfait n’est plus disponible.';

  @override
  String get errorOrderFailed =>
      'La commande n’a pas pu aboutir. Si vous avez été débité, la somme a été remboursée sur votre solde.';

  @override
  String get errorTooManyRequests =>
      'Trop de requêtes. Veuillez patienter un instant.';

  @override
  String get errorBoundToOtherDevice =>
      'Cette eSIM est déjà liée à un autre appareil.';

  @override
  String get agoJustNow => 'à l’instant';

  @override
  String agoMinutes(int count) {
    return 'il y a $count min';
  }

  @override
  String agoHours(int count) {
    return 'il y a $count h';
  }

  @override
  String agoDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count jours',
      one: 'il y a $count jour',
    );
    return '$_temp0';
  }

  @override
  String get balanceLabel => 'Solde';

  @override
  String get statusProvisioning => 'En cours';

  @override
  String get statusNotInstalled => 'Non installée';

  @override
  String get statusInstalled => 'Installée';

  @override
  String get statusActive => 'Active';

  @override
  String get statusUsedUp => 'Épuisée';

  @override
  String get statusExpired => 'Expirée';

  @override
  String get statusFailedRefunded => 'Échec, remboursé';

  @override
  String get myEsimArchiveEmpty => 'Aucun élément archivé';

  @override
  String esimLeftOf(String left, String total) {
    return '$left restants sur $total';
  }

  @override
  String esimDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours restants',
      one: '$count jour restant',
    );
    return '$_temp0';
  }

  @override
  String esimInstallBy(String date) {
    return 'Installer avant le $date';
  }

  @override
  String get esimValidityFromFirst =>
      'La validité démarre à la première connexion';

  @override
  String esimDeviceUpdated(String device, String ago) {
    return '$device · Mis à jour $ago';
  }

  @override
  String esimUpdated(String ago) {
    return 'Mis à jour $ago';
  }

  @override
  String esimRegionTitle(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pays',
      one: '$count pays',
    );
    return '$name ($_temp0)';
  }

  @override
  String esimPackageLine(String volume, String duration) {
    return '$volume · $duration';
  }

  @override
  String get actionInstall => 'Installer';

  @override
  String get howTitle => 'Comment fonctionne l’eSIM';

  @override
  String get howStep1Title => 'Choisissez un forfait';

  @override
  String get howStep1Body =>
      'Trouvez votre destination et choisissez les données et le nombre de jours.';

  @override
  String get howStep2Title => 'Payez avec votre solde';

  @override
  String get howStep2Body =>
      'Rechargez votre solde via PayPal ou en crypto et achetez un forfait en un geste.';

  @override
  String get howStep3Title => 'Installez avant de partir';

  @override
  String get howStep3Body =>
      'Scannez le code QR ou installez en un geste tant que vous avez le Wi-Fi. Ne supprimez pas l’eSIM ensuite.';

  @override
  String get howStep4Title => 'Activez-la à l’arrivée';

  @override
  String get howStep4Body =>
      'Choisissez l’eSIM Waysim pour les données mobiles et activez l’itinérance des données.';

  @override
  String get esimDetailTitle => 'Détails de l’eSIM';

  @override
  String get installOneTap => 'Installer en un geste';

  @override
  String installOneTapNote(String date) {
    return 'Pour iPhone sous iOS 17.4 ou plus · Installer avant le $date';
  }

  @override
  String get installByQr => 'Installation par code QR';

  @override
  String get installQrNote =>
      'Scannez le code QR avec l’appareil photo du téléphone que vous emporterez : ouvrez cet écran sur un autre appareil ou imprimez le code.';

  @override
  String get installQrRetryNote =>
      'L’installation a échoué ? Essayez une deuxième fois. Si cela ne fonctionne toujours pas, attendez 5 minutes puis réessayez pendant que nous terminons l’ajout de cette eSIM à notre système.';

  @override
  String get installManual => 'Installation manuelle';

  @override
  String get esimSmdp => 'Adresse SM-DP+';

  @override
  String get esimActivationCode => 'Code d’activation';

  @override
  String get esimIccid => 'ICCID';

  @override
  String get esimFullActivationCode => 'Code d’activation complet';

  @override
  String get esimFullActivationCodeHint =>
      'Sur Samsung/Android, choisissez Ajouter une eSIM → Scanner un code QR → Saisir le code d’activation manuellement, puis collez le code complet ci-dessus, en commençant par LPA:1\$. Les intitulés peuvent varier selon le téléphone.';

  @override
  String get esimKeepWarning =>
      'Ne supprimez pas l’eSIM du téléphone tant que le forfait est actif. Vous ne pourrez la réinstaller que sur ce même téléphone.';

  @override
  String get esimRoamingWarning =>
      'Pour éviter des frais d’itinérance de votre opérateur, désactivez l’itinérance des données de votre SIM principale.';

  @override
  String get instructionsTitle => 'Instructions';

  @override
  String get tabIphone => 'iPhone';

  @override
  String get tabAndroid => 'Android';

  @override
  String get iosStep1 => 'Connectez-vous au Wi-Fi.';

  @override
  String get iosStep2 =>
      'Ouvrez Réglages → Données mobiles → Ajouter une eSIM.';

  @override
  String get iosStep3 =>
      'Choisissez « Utiliser un code QR » ou « Saisir les informations manuellement ».';

  @override
  String get iosStep4 =>
      'Nommez la ligne « Waysim ». Gardez votre numéro principal pour les appels et iMessage.';

  @override
  String get iosStep5 =>
      'À l’arrivée, activez la ligne Waysim et l’itinérance des données, puis choisissez-la pour les données mobiles.';

  @override
  String get androidStep1 => 'Connectez-vous au Wi-Fi.';

  @override
  String get androidStep2 =>
      'Dans Paramètres, ouvrez le gestionnaire de SIM ou SIM, puis choisissez Ajouter une eSIM (les intitulés varient selon le téléphone).';

  @override
  String get androidStep3 =>
      'Choisissez « Scanner le code QR ». Si vous ne pouvez pas le scanner, touchez la saisie manuelle sous le scanner et collez le code d’activation complet ci-dessus.';

  @override
  String get androidStep4 =>
      'Nommez la ligne « Waysim » et gardez votre SIM principale pour les appels.';

  @override
  String get androidStep5 =>
      'À l’arrivée, activez la ligne Waysim et l’itinérance des données, et utilisez-la pour les données mobiles.';

  @override
  String get usageTitle => 'Consommation de données';

  @override
  String get usageUnlimitedNote =>
      'Forfait illimité : la consommation est indiquée par l’opérateur';

  @override
  String get topUpPackage => 'Recharger le forfait';

  @override
  String get topUpPlansTitle => 'Ajouter des données';

  @override
  String get topUpPlansSubtitle =>
      'Choisissez un forfait à ajouter à cette eSIM';

  @override
  String get topUpPlansEmpty =>
      'Aucun forfait complémentaire n’est disponible pour cette eSIM.';

  @override
  String get topUpAddedTitle => 'Forfait ajouté';

  @override
  String get topUpAddedBody =>
      'Les nouvelles données et jours sont maintenant sur votre eSIM.';

  @override
  String get loginTitle => 'Connexion ou inscription';

  @override
  String get loginBody =>
      'Nous enverrons un code à 6 chiffres par e-mail. Aucun mot de passe nécessaire.';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get emailHint => 'nom@exemple.com';

  @override
  String get demoAccounts => 'Comptes de test';

  @override
  String get demoNewAccount => 'Nouveau compte';

  @override
  String get demoExistingAccount => 'Compte avec historique';

  @override
  String demoCodeHint(String code) {
    return 'Code de test : $code (aucun e-mail n’est envoyé)';
  }

  @override
  String get inviteLabel => 'Code d’invitation (facultatif)';

  @override
  String get termsConsent =>
      'J’ai 18 ans ou plus et j’accepte les Conditions d’utilisation. Le traitement des données est décrit dans la Politique de confidentialité.';

  @override
  String get termsConsentStart => 'J’ai 18 ans ou plus et j’accepte les ';

  @override
  String get termsOfUseLink => 'Conditions d’utilisation';

  @override
  String get termsConsentMiddle =>
      '. Le traitement des données est décrit dans la ';

  @override
  String get privacyPolicyLink => 'Politique de confidentialité';

  @override
  String get termsConsentEnd => '.';

  @override
  String get loginErrorEmail => 'Saisissez une adresse e-mail valide';

  @override
  String get loginErrorTerms => 'Acceptez les conditions pour continuer';

  @override
  String get codeTitle => 'Saisissez le code';

  @override
  String get codeInstructions =>
      'Saisissez le code à 6 chiffres pour continuer.';

  @override
  String get codeLabel => 'Code reçu par e-mail';

  @override
  String resendIn(String time) {
    return 'Renvoyer dans $time';
  }

  @override
  String get resendNow => 'Renvoyer';

  @override
  String get changeEmail => 'Modifier l’e-mail';

  @override
  String get checkSpam => 'Pas d’e-mail ? Vérifiez vos courriers indésirables.';

  @override
  String get codeErrorWrong => 'Code incorrect. Réessayez.';

  @override
  String get codeErrorExpired => 'Ce code a expiré. Demandez-en un nouveau.';

  @override
  String get codeErrorTooMany => 'Trop de tentatives. Réessayez plus tard.';

  @override
  String get nameTitle => 'Comment doit-on vous appeler ?';

  @override
  String get nameBody => 'Facultatif : nous l’utiliserons pour vous saluer.';

  @override
  String get nameHint => 'Votre prénom';

  @override
  String get actionSkip => 'Passer';

  @override
  String profileId(String id) {
    return 'ID $id';
  }

  @override
  String get actionTopUp => 'Recharger';

  @override
  String get orders => 'Commandes';

  @override
  String get inviteFriends => 'Inviter des amis';

  @override
  String get myDevices => 'Mes appareils';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get signOutConfirmTitle => 'Se déconnecter ?';

  @override
  String get signOutConfirmBody =>
      'Voulez-vous vraiment vous déconnecter de votre compte ?';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get notifEsimTitle => 'Notifications';

  @override
  String get notifEsimBody =>
      'Statut de l’eSIM, solde et consommation de données';

  @override
  String get notifNewsTitle => 'Actualités et offres';

  @override
  String get notifNewsBody => 'Réductions et nouveaux pays';

  @override
  String aboutVersion(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String get aboutTagline => 'Internet mobile en voyage';

  @override
  String get aboutApp => 'À propos de l’app';

  @override
  String get devicesTitle => 'Mes appareils';

  @override
  String get devicesNote => 'Gérez les appareils connectés à votre compte.';

  @override
  String get deviceRemove => 'Retirer l’appareil';

  @override
  String get deviceRemoveTitle => 'Retirer cet appareil ?';

  @override
  String deviceRemoveBody(String device) {
    return 'Se déconnecter de Waysim sur $device ? Vous pourrez vous reconnecter sur cet appareil.';
  }

  @override
  String get deviceRemoved => 'Appareil retiré.';

  @override
  String get deviceThis => 'Cet appareil';

  @override
  String deviceLastSeen(String ago) {
    return 'Dernière activité $ago';
  }

  @override
  String get deleteTitle => 'Suppression du compte';

  @override
  String get deleteWarnTitle => 'Cette action est irréversible';

  @override
  String deleteBullet1(String balance) {
    return 'Votre solde ($balance) et vos bonus seront perdus.';
  }

  @override
  String get deleteBullet2 =>
      'Les forfaits non installés seront annulés sans remboursement.';

  @override
  String get deleteBullet3 =>
      'Les eSIM déjà installées fonctionnent jusqu’à la fin du forfait.';

  @override
  String get deleteBullet4 =>
      'Les données personnelles sont anonymisées sous 30 jours. Les justificatifs de paiement sont conservés aussi longtemps que la loi l’exige.';

  @override
  String get deleteRefundNote =>
      'Vous souhaitez le remboursement d’une recharge non utilisée ? Contactez le support avant la suppression.';

  @override
  String get deleteSupportLink => 'Contactez le support';

  @override
  String deleteCodeBody(String email) {
    return 'Saisissez le code à 6 chiffres envoyé à $email pour confirmer.';
  }

  @override
  String get deleteConfirm => 'Supprimer mon compte';

  @override
  String get deleteDone => 'Compte supprimé';

  @override
  String get topUpTitle => 'Recharger le solde';

  @override
  String get topUpCurrentBalance => 'Solde actuel';

  @override
  String get topUpChooseAmount => 'Choisissez le montant';

  @override
  String get topUpOtherAmount => 'Autre montant';

  @override
  String get topUpAmountHint => 'Montant en USD';

  @override
  String topUpAmountInvalid(String min, String max) {
    return 'Saisissez un montant de $min à $max';
  }

  @override
  String get topUpMethod => 'Moyen de paiement';

  @override
  String get topUpPaypalTitle => 'PayPal';

  @override
  String get topUpPaypalBody => 'Solde PayPal ou carte via PayPal';

  @override
  String get topUpCryptoTitle => 'Cryptomonnaie';

  @override
  String get topUpCryptoBody => 'Choisissez la devise et le réseau';

  @override
  String get topUpMinimumLabel => 'Recharge minimale';

  @override
  String get topUpPaymentFeeIncluded =>
      'Les frais sont inclus dans le montant à envoyer';

  @override
  String get topUpNote =>
      'Le solde ne sert qu’à acheter des forfaits eSIM et ne peut pas être retiré. Une recharge non utilisée peut être remboursée selon la Politique de remboursement. Le service de paiement peut prélever des frais.';

  @override
  String topUpButton(String amount) {
    return 'Recharger $amount';
  }

  @override
  String get topUpPaypalWaitingTitle => 'En attente de PayPal';

  @override
  String get topUpPaypalWaitingBody =>
      'Terminez le paiement dans la fenêtre PayPal. Cet écran se met à jour tout seul.';

  @override
  String get topUpReopenPaypal => 'Rouvrir PayPal';

  @override
  String get cryptoTitle => 'Paiement en crypto';

  @override
  String get cryptoCoin => 'Devise';

  @override
  String get cryptoNetwork => 'Réseau';

  @override
  String get cryptoWaitingPayment => 'En attente du paiement';

  @override
  String get cryptoStepWaiting => 'Attente';

  @override
  String get cryptoStepConfirmations => 'Confirmations';

  @override
  String get cryptoStepCredited => 'Crédité';

  @override
  String cryptoConfirmationsOf(int n, int m) {
    return '$n sur $m';
  }

  @override
  String get cryptoSendExactly => 'Envoyez exactement';

  @override
  String get cryptoToAddress => 'À l’adresse';

  @override
  String cryptoRateLocked(String rate, String amount) {
    return 'Taux verrouillé : $rate · Recharge de $amount';
  }

  @override
  String cryptoFeeOnTop(String amount, String fee, String total) {
    return '$amount + frais $fee = $total';
  }

  @override
  String get contactsTitle => 'Nous contacter';

  @override
  String cryptoWarning(String coin, String network) {
    return 'Envoyez uniquement des $coin sur le réseau $network, le montant exact en une seule transaction. Ajoutez les frais du portefeuille en plus : le montant total doit nous parvenir.';
  }

  @override
  String get cryptoCloseNote =>
      'Vous pouvez fermer cet écran : nous vous enverrons une notification dès que le paiement sera crédité.';

  @override
  String get cryptoChangeAmountAction => 'Changer le montant';

  @override
  String get cryptoChangeAmountTitle => 'Choisir un autre montant ?';

  @override
  String get cryptoChangeAmountBody =>
      'Cette demande de paiement reste active jusqu\'à la fin du compte à rebours. Si vous avez déjà envoyé les fonds, attendez la fin du paiement. Sinon, vous pouvez créer une nouvelle demande avec un autre montant.';

  @override
  String get cryptoChangeCurrencyTitle =>
      'Changer de cryptomonnaie ou de réseau ?';

  @override
  String get cryptoChangeCurrencyBody =>
      'Une autre cryptomonnaie ou un autre réseau nécessite une nouvelle adresse de paiement. La demande actuelle reste active jusqu\'à son expiration. Si vous avez déjà envoyé les fonds, attendez la fin du paiement.';

  @override
  String get cryptoChangeCurrencyAction => 'Créer un nouveau paiement';

  @override
  String get topUpDoneTitle => 'Solde rechargé';

  @override
  String topUpDoneBody(String amount) {
    return '$amount ont été ajoutés à votre solde.';
  }

  @override
  String get actionDone => 'Terminé';

  @override
  String get topUpExpiredTitle => 'Le paiement a expiré';

  @override
  String get topUpExpiredBody =>
      'Si vous avez déjà envoyé les fonds, ils seront crédités après vérification. Sinon, recommencez.';

  @override
  String get actionTryAgain => 'Réessayer';

  @override
  String get ordersTitle => 'Commandes';

  @override
  String get ordersTabPurchases => 'Achats';

  @override
  String get ordersTabTopUps => 'Recharges';

  @override
  String get ordersTabActivity => 'Activité';

  @override
  String get ordersEmptyPurchases => 'Aucun achat pour l’instant';

  @override
  String get ordersEmptyTopUps => 'Aucune recharge pour l’instant';

  @override
  String get ordersEmptyActivity => 'Aucun mouvement de solde pour l’instant';

  @override
  String get paymentDetailTitle => 'Détails du paiement';

  @override
  String get paymentDetailBreakdown => 'Détail du paiement';

  @override
  String get paymentDetailTransaction => 'Détails de la transaction';

  @override
  String get orderDetailTitle => 'Détails de la commande';

  @override
  String get activityDetailTitle => 'Détails de l’activité';

  @override
  String get detailOrderNumber => 'Numéro de commande';

  @override
  String get detailStatus => 'Statut';

  @override
  String get detailPackage => 'Forfait';

  @override
  String get detailFailureReason => 'Motif de l’échec';

  @override
  String get detailCompletedAt => 'Terminé le';

  @override
  String get detailEsimId => 'ID eSIM';

  @override
  String get detailOrderId => 'ID de commande';

  @override
  String get detailViewEsim => 'Voir l’eSIM';

  @override
  String get detailType => 'Type';

  @override
  String get detailNote => 'Note';

  @override
  String get detailBalanceAfter => 'Solde après';

  @override
  String get detailReference => 'Élément associé';

  @override
  String get detailEntryId => 'ID du mouvement';

  @override
  String get detailViewReference => 'Voir les détails associés';

  @override
  String get paymentDetailTopUpAmount => 'Montant de la recharge';

  @override
  String get paymentDetailNumber => 'Numéro de paiement';

  @override
  String get paymentDetailDate => 'Créé le';

  @override
  String get paymentDetailCurrency => 'Cryptomonnaie et réseau';

  @override
  String get paymentDetailExpected => 'Montant demandé';

  @override
  String get paymentDetailReceived => 'Montant reçu';

  @override
  String get paymentDetailFee => 'Frais de paiement';

  @override
  String get paymentDetailTotal => 'Total en USD';

  @override
  String get paymentDetailProviderStatus => 'Statut du prestataire';

  @override
  String get paymentDetailTransactionId => 'ID de transaction';

  @override
  String get paymentDetailCredited => 'Ajouté au solde';

  @override
  String get paymentDetailCreditedAt => 'Date de crédit';

  @override
  String get paymentDetailId => 'ID du paiement';

  @override
  String get paymentDetailContinue => 'Voir les instructions de paiement';

  @override
  String get paymentDetailReview =>
      'Ce paiement doit être vérifié manuellement avant la mise à jour du solde.';

  @override
  String get paymentDetailOverpaid =>
      'Le prestataire a reçu plus que le montant demandé. L’assistance vérifiera le paiement avant de mettre à jour votre solde.';

  @override
  String get paymentDetailUnderpaid =>
      'Le prestataire a reçu moins que le montant demandé. L’assistance vérifiera le paiement avant de mettre à jour votre solde.';

  @override
  String get paymentDetailLate =>
      'Le paiement est arrivé après la fin du délai. L’assistance le vérifiera avant de mettre à jour votre solde.';

  @override
  String orderNumberDate(String number, String date) {
    return 'Commande $number · $date';
  }

  @override
  String get orderCompleted => 'Terminée';

  @override
  String orderPurchaseTitle(String place, String plan) {
    return '$place · $plan';
  }

  @override
  String orderAddOnTitle(String place, String plan) {
    return 'Recharge de forfait · $place +$plan';
  }

  @override
  String get orderTopUpPaypal => 'Recharge du solde · PayPal';

  @override
  String get orderTopUpCrypto => 'Recharge du solde · Crypto';

  @override
  String get referralTitle => 'Inviter des amis';

  @override
  String referralHeroTitle(String reward) {
    return 'Recevez $reward pour chaque ami';
  }

  @override
  String referralHeroBody(String reward) {
    return 'Un ami s’inscrit avec votre code et vous recevez $reward sur votre solde.';
  }

  @override
  String get referralYourCode => 'Votre code';

  @override
  String get referralShare => 'Partager l’invitation';

  @override
  String referralShareText(String code) {
    return 'Vous partez bientôt ? Découvrez les forfaits eSIM de Waysim. Utilisez mon code d’invitation lors de votre inscription :\n$code';
  }

  @override
  String referralShareLinkText(String link, String code) {
    return 'Vous partez bientôt ? Découvrez les forfaits eSIM de Waysim. Inscrivez-vous avec mon lien d’invitation :\n$link\n\nCode d’invitation : $code';
  }

  @override
  String get referralStatInvited => 'Invités';

  @override
  String get referralStatCredited => 'Crédité';

  @override
  String get referralStatPending => 'En vérification';

  @override
  String get referralStatRejected => 'Refusés';

  @override
  String get referralRulesTitle => 'Règles';

  @override
  String get referralRule1 =>
      'Le bonus ne peut servir qu’à acheter des forfaits eSIM et ne peut pas être retiré.';

  @override
  String get referralRule2 =>
      'Seuls les nouveaux utilisateurs Waysim comptent : un bonus par appareil.';

  @override
  String get referralRule3 => 'Pas plus de 10 bonus par mois.';

  @override
  String get referralRule4 =>
      'Les invitations sont vérifiées automatiquement. Les auto-invitations et faux comptes sont refusés.';

  @override
  String get referralRule5 =>
      'Le montant du bonus est fixé à l’inscription de votre ami.';

  @override
  String get referralFullTerms => 'Conditions complètes';

  @override
  String get referralYourInvites => 'Vos invitations';

  @override
  String referralInviteCredited(String reward) {
    return '+$reward crédité';
  }

  @override
  String referralInviteSignedUp(String date) {
    return 'Inscription : $date';
  }

  @override
  String get referralEmpty => 'Aucune invitation pour l’instant';

  @override
  String get supportSheetTitle => 'Comment pouvons-nous aider ?';

  @override
  String get supportAiTitle => 'Chat IA en ligne';

  @override
  String get supportAiBody => 'Réponses instantanées 24h/24';

  @override
  String get supportMailTitle => 'Écrivez-nous';

  @override
  String get supportMailBody => 'Un conseiller vous répondra par e-mail';

  @override
  String supportMailSubject(String id) {
    return 'Waysim — demande, ID $id';
  }

  @override
  String supportMailTemplate(String id, String app, String system) {
    return 'Décrivez votre question ici.\n\n— Informations techniques —\nID : $id\nApp : $app\nSystème : $system';
  }

  @override
  String supportMailFallback(String email) {
    return 'Aucune application de messagerie trouvée. Notre adresse : $email.';
  }

  @override
  String get actionCopyAddress => 'Copier l’adresse';

  @override
  String get chatTitle => 'Assistant Waysim';

  @override
  String get chatBadge => 'Réponse par IA';

  @override
  String get chatDisclaimer =>
      'L’IA peut se tromper. Elle ne voit pas vos paiements et ne modifie pas votre solde. N’envoyez ni mots de passe ni données de carte.';

  @override
  String get chatGreeting =>
      'Bonjour ! Je suis l’assistant IA de Waysim. Posez-moi vos questions sur le choix d’un forfait, l’installation d’une eSIM ou la connexion à l’étranger.';

  @override
  String get chatChipInstall => 'Comment installer une eSIM ?';

  @override
  String get chatChipChoose => 'Quel forfait choisir ?';

  @override
  String get chatChipNetwork => 'Mon eSIM ne se connecte pas';

  @override
  String get chatNotHelped => 'Ça ne vous a pas aidé ?';

  @override
  String get chatContactHuman => 'Écrire à un conseiller';

  @override
  String get chatInputHint => 'Écrivez un message';

  @override
  String get chatHistoryNote => 'L’historique du chat est conservé 30 jours';

  @override
  String get updateRequiredTitle => 'Veuillez mettre à jour l’application';

  @override
  String get updateRequiredBody =>
      'Cette version n’est plus prise en charge. Mettez Waysim à jour pour continuer à acheter et utiliser vos eSIM.';

  @override
  String get updateRequiredAction => 'Mettre à jour';

  @override
  String get integrityWarningTitle =>
      'Cet appareil ne peut pas obtenir de bonus de parrainage';

  @override
  String get integrityWarningBody =>
      'Votre téléphone semble modifié (root, jailbreak ou émulateur). Tout le reste fonctionne normalement.';

  @override
  String get noConnectionTitle => 'Pas de connexion';

  @override
  String get noConnectionBody =>
      'Waysim a besoin d’internet pour charger les forfaits et vos eSIM. Vérifiez le Wi‑Fi ou les données mobiles puis réessayez.';

  @override
  String get noConnectionWaiting => 'En attente de connexion…';

  @override
  String get noConnectionContinue => 'Continuer hors ligne';

  @override
  String get statusSuspended => 'Suspendue';

  @override
  String get statusCancelled => 'Annulée';

  @override
  String get statusRevoked => 'Révoquée';

  @override
  String get statusFailed => 'Échec';

  @override
  String get paymentReview => 'Paiement en cours de vérification';

  @override
  String get paymentPending => 'En attente';

  @override
  String get paymentMemo => 'Mémo / tag de destination';

  @override
  String get supportTeam => 'Équipe d’assistance';

  @override
  String get supportLiveDisclaimer =>
      'Vos messages sont transmis à l’équipe d’assistance Waysim.';

  @override
  String get supportLiveGreeting =>
      'Posez votre question sur Waysim ou votre eSIM.';

  @override
  String get inviteCodeInvalid =>
      'Code d’invitation invalide. Vérifiez-le et réessayez.';

  @override
  String get paymentFailed => 'Paiement non effectué';

  @override
  String get paymentFailedBody =>
      'Le paiement n’a pas abouti. Contactez l’assistance si vous avez déjà envoyé les fonds.';

  @override
  String get activationOnInstall => 'Commence à l’installation de l’eSIM.';
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Waysim';

  @override
  String get tabHome => 'Inicio';

  @override
  String get tabMyEsim => 'Mis eSIM';

  @override
  String get tabProfile => 'Perfil';

  @override
  String greetingNamed(String name) {
    return '¡Hola, $name!';
  }

  @override
  String get greeting => '¡Hola!';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get searchHint => '¿Dónde necesitas una eSIM?';

  @override
  String get supportFabLabel => 'Ayuda';

  @override
  String get homeLocal => 'Locales';

  @override
  String get homeRegional => 'Regionales';

  @override
  String priceFrom(String price) {
    return 'desde $price';
  }

  @override
  String get myEsimTitle => 'Mis eSIM';

  @override
  String get myEsimCurrent => 'Actuales';

  @override
  String get myEsimArchive => 'Archivo';

  @override
  String get myEsimEmptyTitle => 'Aún no tienes eSIM';

  @override
  String get myEsimEmptyBody =>
      'Compra un plan para tu viaje: solo lleva un par de minutos.';

  @override
  String get buyEsim => 'Obtener una eSIM';

  @override
  String get howEsimWorks => 'Cómo funciona la eSIM';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileGuestTitle => 'Inicia sesión para comprar eSIM';

  @override
  String get profileGuestBody =>
      'Tus compras, saldo y eSIM se guardan en tu cuenta.';

  @override
  String get signUp => 'Registrarse';

  @override
  String get settings => 'Ajustes';

  @override
  String get more => 'Más';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get actionRetry => 'Reintentar';

  @override
  String get offlineBanner => 'Sin conexión';

  @override
  String get errorNetwork =>
      'Sin conexión a internet. Revisa tu red e inténtalo de nuevo.';

  @override
  String get errorTimeout =>
      'Se agotó el tiempo de espera. Inténtalo de nuevo.';

  @override
  String get errorServer =>
      'Algo falló por nuestra parte. Inténtalo más tarde.';

  @override
  String get errorUnauthorized =>
      'Tu sesión ha caducado. Inicia sesión de nuevo.';

  @override
  String get signedOutOnDevice =>
      'Se cerró tu sesión en este dispositivo. Vuelve a iniciar sesión.';

  @override
  String get errorNotFound => 'No encontramos lo que buscabas.';

  @override
  String get errorUnknown => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get comingSoon => 'Próximamente';

  @override
  String get actionCopy => 'Copiar';

  @override
  String get toastCopied => 'Copiado';

  @override
  String get actionContinue => 'Continuar';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionClose => 'Cerrar';

  @override
  String get actionGotIt => 'Entendido';

  @override
  String get actionLater => 'Más tarde';

  @override
  String get actionPasteCode => 'Pegar código';

  @override
  String get settingsGallery => 'Galería de diseño (debug)';

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
      other: '$count días',
      one: '$count día',
    );
    return '$_temp0';
  }

  @override
  String get dataUnlimited => 'Ilimitado';

  @override
  String dailyAllowance(String size) {
    return '$size al día';
  }

  @override
  String unlimitedPlan(String daily, String days) {
    return 'Ilimitado · $daily · $days';
  }

  @override
  String regionCountries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count países',
      one: '$count país',
    );
    return '$_temp0';
  }

  @override
  String get bannerEsimTitle => '¿Qué es eSIM?';

  @override
  String get bannerEsimBody =>
      'Una SIM digital: se configura en minutos, sin plástico';

  @override
  String get bannerEsimAction => 'Cómo funciona →';

  @override
  String bannerInviteTitle(String reward) {
    return 'Invita a un amigo y recibe $reward';
  }

  @override
  String get bannerInviteAction => 'Invitar →';

  @override
  String get bannerTravelTitle => 'Conexión en cada viaje';

  @override
  String get bannerTravelBody => 'Planes locales para destinos populares';

  @override
  String get bannerTravelAction => 'Ver países →';

  @override
  String get catalogEmpty => 'Aún no hay destinos';

  @override
  String get searchRecent => 'Búsquedas recientes';

  @override
  String get searchClear => 'Borrar';

  @override
  String get searchCountries => 'Países';

  @override
  String get searchRegions => 'Regiones';

  @override
  String searchNoResults(String query) {
    return 'Sin resultados para «$query»';
  }

  @override
  String get searchNoResultsHint =>
      'Prueba con el nombre o el código de un país: «Turquía», «US».';

  @override
  String get searchBack => 'Atrás';

  @override
  String get compatLabel => 'El dispositivo admite eSIM:';

  @override
  String get compatYes => 'Sí';

  @override
  String get compatNo => 'No';

  @override
  String get compatUnknown => 'Desconocido';

  @override
  String get compatHowToCheck => 'Cómo comprobar';

  @override
  String get compatSheetTitle => '¿Mi teléfono admite eSIM?';

  @override
  String get compatSheetIos =>
      'iPhone XS, XR y posteriores admiten eSIM. Compruébalo en Ajustes → General → Información: busca «SIM digital» o un número EID. El teléfono también debe estar libre de operador.';

  @override
  String get compatSheetAndroid =>
      'Abre el teclado de llamadas e introduce *#06#. Si ves un número EID, tu teléfono admite eSIM. También puedes mirar Ajustes → Conexiones → Administrador de SIM. El teléfono debe estar libre de operador.';

  @override
  String get compatWarningTitle => 'Tu teléfono podría no admitir eSIM';

  @override
  String get compatWarningBody =>
      'Aún puedes comprar este plan, pero la eSIM no funcionará en un teléfono sin compatibilidad. ¿Continuar de todos modos?';

  @override
  String get actionContinueAnyway => 'Continuar de todos modos';

  @override
  String get packagesUnlimited => 'Ilimitados';

  @override
  String get packagesLimited => 'Limitados';

  @override
  String get packagesChoose => 'Elige un plan';

  @override
  String get packagesEmpty => 'No hay planes en esta categoría';

  @override
  String get packageDetailsLink => 'Detalles del plan';

  @override
  String buyFor(String price) {
    return 'Comprar por $price';
  }

  @override
  String get purchaseDisclaimer =>
      'Al hacer el pedido confirmas que tu dispositivo es compatible con eSIM y no está bloqueado por un operador.';

  @override
  String get oneTimePurchase =>
      'Compra única: sin suscripción ni renovación automática.';

  @override
  String get detailCoverage => 'Cobertura';

  @override
  String get detailData => 'Datos';

  @override
  String detailDataFull(String size) {
    return '$size a máxima velocidad';
  }

  @override
  String detailDataUnlimited(String size) {
    return 'Ilimitado, $size al día a máxima velocidad';
  }

  @override
  String get detailValidity => 'Validez';

  @override
  String get detailValidityNote =>
      'Empieza con la primera conexión de la eSIM a una red en tu destino';

  @override
  String get detailNetwork => 'Red';

  @override
  String get detailHotspot => 'Punto de acceso';

  @override
  String get detailTopUp => 'Recarga';

  @override
  String get detailCalls => 'Llamadas y SMS';

  @override
  String get detailInstall => 'Instalación';

  @override
  String get detailAvailable => 'Disponible';

  @override
  String get detailUnavailable => 'No disponible';

  @override
  String get detailDataOnly => 'Solo datos';

  @override
  String get detailCallsIncluded => 'Incluidos';

  @override
  String detailInstallWithin(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'En $count días',
      one: 'En $count día',
    );
    return '$_temp0';
  }

  @override
  String get coverageCountries => 'Países incluidos';

  @override
  String get confirmTitle => 'Confirma la compra';

  @override
  String get confirmPrice => 'Precio';

  @override
  String get confirmBalanceNow => 'Saldo actual';

  @override
  String get confirmBalanceAfter => 'Saldo tras la compra';

  @override
  String get confirmConsent =>
      'Quiero que la eSIM se emita de inmediato y entiendo que no podré cancelar la compra una vez instalada. Compra única: sin suscripción ni renovación automática.';

  @override
  String confirmPay(String price) {
    return 'Pagar $price';
  }

  @override
  String get insufficientTitle => 'Saldo insuficiente';

  @override
  String insufficientBody(String missing) {
    return 'Te faltan $missing para comprar este plan.';
  }

  @override
  String insufficientAction(String amount) {
    return 'Recargar $amount';
  }

  @override
  String get orderPreparing => 'Preparando tu eSIM…';

  @override
  String get orderPreparingHint => 'Suele tardar unos segundos.';

  @override
  String get orderSlow =>
      'Está tardando más de lo normal. Te avisaremos con una notificación cuando tu eSIM esté lista.';

  @override
  String get orderFailedTitle => 'No se pudo completar el pedido';

  @override
  String get orderFailedBody =>
      'Si se te cobró, el dinero se ha devuelto a tu saldo.';

  @override
  String orderPriceChanged(String price) {
    return 'El precio cambió a $price. Revísalo e inténtalo de nuevo.';
  }

  @override
  String get orderBackToPlans => 'Volver a los planes';

  @override
  String get actionGoToMyEsim => 'Ir a Mis eSIM';

  @override
  String get esimReadyTitle => '¡Tu eSIM está lista!';

  @override
  String get esimReadyBody =>
      'Instálala ahora mientras tengas Wi-Fi. Los días del plan solo empiezan a contar cuando te conectes en tu destino.';

  @override
  String get esimInstall => 'Instalar eSIM';

  @override
  String get maintenanceBanner =>
      'Las compras y recargas están pausadas temporalmente.';

  @override
  String get errorMaintenance =>
      'Las compras están pausadas temporalmente. Inténtalo más tarde.';

  @override
  String get errorPackageUnavailable => 'Este plan ya no está disponible.';

  @override
  String get errorOrderFailed =>
      'No se pudo completar el pedido. Si se te cobró, el dinero se ha devuelto a tu saldo.';

  @override
  String get errorTooManyRequests =>
      'Demasiadas solicitudes. Espera un momento.';

  @override
  String get errorBoundToOtherDevice =>
      'Esta eSIM ya está vinculada a otro dispositivo.';

  @override
  String get agoJustNow => 'ahora mismo';

  @override
  String agoMinutes(int count) {
    return 'hace $count min';
  }

  @override
  String agoHours(int count) {
    return 'hace $count h';
  }

  @override
  String agoDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count días',
      one: 'hace $count día',
    );
    return '$_temp0';
  }

  @override
  String get balanceLabel => 'Saldo';

  @override
  String get statusProvisioning => 'En proceso';

  @override
  String get statusNotInstalled => 'Sin instalar';

  @override
  String get statusInstalled => 'Instalada';

  @override
  String get statusActive => 'Activa';

  @override
  String get statusUsedUp => 'Agotada';

  @override
  String get statusExpired => 'Caducada';

  @override
  String get statusFailedRefunded => 'Fallido, reembolsado';

  @override
  String get myEsimArchiveEmpty => 'El archivo está vacío';

  @override
  String esimLeftOf(String left, String total) {
    return 'Quedan $left de $total';
  }

  @override
  String esimDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Quedan $count días',
      one: 'Queda $count día',
    );
    return '$_temp0';
  }

  @override
  String esimInstallBy(String date) {
    return 'Instalar antes del $date';
  }

  @override
  String get esimValidityFromFirst =>
      'La validez empieza con la primera conexión';

  @override
  String esimDeviceUpdated(String device, String ago) {
    return '$device · Actualizado $ago';
  }

  @override
  String esimUpdated(String ago) {
    return 'Actualizado $ago';
  }

  @override
  String esimRegionTitle(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count países',
      one: '$count país',
    );
    return '$name ($_temp0)';
  }

  @override
  String esimPackageLine(String volume, String duration) {
    return '$volume · $duration';
  }

  @override
  String get actionInstall => 'Instalar';

  @override
  String get howTitle => 'Cómo funciona la eSIM';

  @override
  String get howStep1Title => 'Elige un plan';

  @override
  String get howStep1Body =>
      'Busca tu destino y elige los datos y los días que necesitas.';

  @override
  String get howStep2Title => 'Paga con tu saldo';

  @override
  String get howStep2Body =>
      'Recarga tu saldo con PayPal o criptomonedas y compra un plan con un toque.';

  @override
  String get howStep3Title => 'Instala antes de viajar';

  @override
  String get howStep3Body =>
      'Escanea el código QR o instala con un toque mientras tengas Wi-Fi. Después no borres la eSIM.';

  @override
  String get howStep4Title => 'Actívala al llegar';

  @override
  String get howStep4Body =>
      'Elige la eSIM de Waysim para datos móviles y activa la itinerancia de datos.';

  @override
  String get esimDetailTitle => 'Datos de la eSIM';

  @override
  String get installOneTap => 'Instalar con un toque';

  @override
  String installOneTapNote(String date) {
    return 'Para iPhone con iOS 17.4 o posterior · Instalar antes del $date';
  }

  @override
  String get installByQr => 'Instalar con código QR';

  @override
  String get installQrNote =>
      'Escanea el código QR con la cámara del teléfono con el que viajarás: abre esta pantalla en otro dispositivo o imprime el código.';

  @override
  String get installManual => 'Instalación manual';

  @override
  String get esimSmdp => 'Dirección SM-DP+';

  @override
  String get esimActivationCode => 'Código de activación';

  @override
  String get esimIccid => 'ICCID';

  @override
  String get esimKeepWarning =>
      'No borres la eSIM del teléfono mientras el plan esté activo. Solo podrás reinstalarla en este mismo teléfono.';

  @override
  String get esimRoamingWarning =>
      'Para evitar cargos de itinerancia de tu operador, desactiva la itinerancia de datos de tu SIM principal.';

  @override
  String get instructionsTitle => 'Instrucciones';

  @override
  String get tabIphone => 'iPhone';

  @override
  String get tabAndroid => 'Android';

  @override
  String get iosStep1 => 'Conéctate al Wi-Fi.';

  @override
  String get iosStep2 => 'Abre Ajustes → Datos móviles → Añadir eSIM.';

  @override
  String get iosStep3 =>
      'Elige «Usar código QR» o «Introducir datos manualmente».';

  @override
  String get iosStep4 =>
      'Llama a la línea «Waysim». Deja tu número principal para llamadas e iMessage.';

  @override
  String get iosStep5 =>
      'Al llegar, activa la línea Waysim y la itinerancia de datos, y elígela para datos móviles.';

  @override
  String get androidStep1 => 'Conéctate al Wi-Fi.';

  @override
  String get androidStep2 =>
      'Abre Ajustes → Red e internet → SIM → Añadir eSIM (los nombres varían según el teléfono).';

  @override
  String get androidStep3 =>
      'Elige «Escanear código QR» o introduce los datos manualmente.';

  @override
  String get androidStep4 =>
      'Llama a la línea «Waysim» y deja tu SIM principal para llamadas.';

  @override
  String get androidStep5 =>
      'Al llegar, activa la línea Waysim y la itinerancia de datos, y úsala para datos móviles.';

  @override
  String get usageTitle => 'Consumo de datos';

  @override
  String get usageUnlimitedNote =>
      'Plan ilimitado: el consumo lo muestra el operador';

  @override
  String get topUpPackage => 'Ampliar plan';

  @override
  String get topUpPlansTitle => 'Añadir datos';

  @override
  String get topUpPlansSubtitle => 'Elige un plan para añadir a esta eSIM';

  @override
  String get topUpPlansEmpty => 'No hay planes de ampliación para esta eSIM.';

  @override
  String get topUpAddedTitle => 'Plan añadido';

  @override
  String get topUpAddedBody => 'Los nuevos datos y días ya están en tu eSIM.';

  @override
  String get loginTitle => 'Inicia sesión o regístrate';

  @override
  String get loginBody =>
      'Te enviaremos un código de 6 dígitos por correo. No necesitas contraseña.';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get emailHint => 'nombre@ejemplo.com';

  @override
  String get demoAccounts => 'Cuentas de prueba';

  @override
  String get demoNewAccount => 'Cuenta nueva';

  @override
  String get demoExistingAccount => 'Cuenta con historial';

  @override
  String demoCodeHint(String code) {
    return 'Código de prueba: $code (no se envía ningún correo)';
  }

  @override
  String get inviteLabel => 'Código de invitación (opcional)';

  @override
  String get termsConsent =>
      'Tengo 18 años o más y acepto los Términos de uso. Cómo tratamos los datos, en la Política de privacidad.';

  @override
  String get termsConsentStart => 'Tengo 18 años o más y acepto los ';

  @override
  String get termsOfUseLink => 'Términos de uso';

  @override
  String get termsConsentMiddle => '. Cómo tratamos los datos, en la ';

  @override
  String get privacyPolicyLink => 'Política de privacidad';

  @override
  String get termsConsentEnd => '.';

  @override
  String get loginErrorEmail => 'Introduce un correo válido';

  @override
  String get loginErrorTerms => 'Acepta los términos para continuar';

  @override
  String get codeTitle => 'Introduce el código';

  @override
  String get codeInstructions =>
      'Introduce el código de 6 dígitos para continuar.';

  @override
  String codeBody(String email) {
    return 'Hemos enviado un código de 6 dígitos a $email';
  }

  @override
  String get codeLabel => 'Código del correo';

  @override
  String resendIn(String time) {
    return 'Reenviar en $time';
  }

  @override
  String get resendNow => 'Reenviar';

  @override
  String get changeEmail => 'Cambiar correo';

  @override
  String get checkSpam => '¿No llega? Revisa la carpeta de spam.';

  @override
  String get codeErrorWrong => 'Código incorrecto. Inténtalo de nuevo.';

  @override
  String get codeErrorExpired => 'El código ha caducado. Solicita uno nuevo.';

  @override
  String get codeErrorTooMany => 'Demasiados intentos. Inténtalo más tarde.';

  @override
  String get nameTitle => '¿Cómo te llamamos?';

  @override
  String get nameBody => 'Opcional: lo usaremos para saludarte.';

  @override
  String get nameHint => 'Tu nombre';

  @override
  String get actionSkip => 'Omitir';

  @override
  String profileId(String id) {
    return 'ID $id';
  }

  @override
  String get actionTopUp => 'Recargar';

  @override
  String get orders => 'Pedidos';

  @override
  String get inviteFriends => 'Invitar amigos';

  @override
  String get myDevices => 'Mis dispositivos';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get signOutConfirmTitle => '¿Cerrar sesión?';

  @override
  String get signOutConfirmBody =>
      '¿Seguro que quieres cerrar la sesión de tu cuenta?';

  @override
  String get settingsNotifications => 'Notificaciones';

  @override
  String get notifEsimTitle => 'Notificaciones';

  @override
  String get notifEsimBody => 'Estado de la eSIM, saldo y consumo de datos';

  @override
  String get notifNewsTitle => 'Novedades y ofertas';

  @override
  String get notifNewsBody => 'Descuentos y nuevos países';

  @override
  String aboutVersion(String version, String build) {
    return 'Versión $version ($build)';
  }

  @override
  String get aboutTagline => 'Internet móvil para viajar';

  @override
  String get aboutApp => 'Acerca de la app';

  @override
  String get devicesTitle => 'Mis dispositivos';

  @override
  String get devicesNote => 'Gestiona los dispositivos conectados a tu cuenta.';

  @override
  String get deviceRemove => 'Eliminar dispositivo';

  @override
  String get deviceRemoveTitle => '¿Eliminar este dispositivo?';

  @override
  String deviceRemoveBody(String device) {
    return '¿Cerrar sesión de Waysim en $device? Podrás volver a iniciar sesión en ese dispositivo.';
  }

  @override
  String get deviceRemoved => 'Dispositivo eliminado.';

  @override
  String get deviceThis => 'Este dispositivo';

  @override
  String deviceLastSeen(String ago) {
    return 'Última actividad $ago';
  }

  @override
  String get deleteTitle => 'Eliminar cuenta';

  @override
  String get deleteWarnTitle => 'Esta acción no se puede deshacer';

  @override
  String deleteBullet1(String balance) {
    return 'Tu saldo ($balance) y tus bonos se perderán.';
  }

  @override
  String get deleteBullet2 =>
      'Los planes sin instalar se cancelarán sin reembolso.';

  @override
  String get deleteBullet3 =>
      'Las eSIM ya instaladas seguirán funcionando hasta el fin del plan.';

  @override
  String get deleteBullet4 =>
      'Los datos personales se anonimizan en 30 días. Los registros de pago se conservan el tiempo que exija la ley.';

  @override
  String get deleteRefundNote =>
      '¿Quieres que te reembolsen una recarga sin usar? Escribe a soporte antes de eliminar.';

  @override
  String get deleteSupportLink => 'Escribe a soporte';

  @override
  String deleteCodeBody(String email) {
    return 'Introduce el código de 6 dígitos que enviamos a $email para confirmar.';
  }

  @override
  String get deleteConfirm => 'Eliminar mi cuenta';

  @override
  String get deleteDone => 'Cuenta eliminada';

  @override
  String get topUpTitle => 'Recargar saldo';

  @override
  String get topUpCurrentBalance => 'Saldo actual';

  @override
  String get topUpChooseAmount => 'Elige el importe';

  @override
  String get topUpOtherAmount => 'Otro importe';

  @override
  String get topUpAmountHint => 'Importe en USD';

  @override
  String topUpAmountRange(String min, String max) {
    return 'De $min a $max';
  }

  @override
  String topUpAmountInvalid(String min, String max) {
    return 'Introduce un importe de $min a $max';
  }

  @override
  String get topUpMethod => 'Método de pago';

  @override
  String get topUpPaypalTitle => 'PayPal';

  @override
  String get topUpPaypalBody => 'Saldo de PayPal o tarjeta mediante PayPal';

  @override
  String get topUpCryptoTitle => 'Criptomoneda';

  @override
  String get topUpCryptoBody => 'Elige la moneda y la red';

  @override
  String get topUpMinimumLabel => 'Recarga mínima';

  @override
  String get topUpPaymentFeeIncluded =>
      'La comisión está incluida en el importe a enviar';

  @override
  String get topUpNote =>
      'El saldo solo se gasta en planes eSIM y no se puede retirar. Una recarga sin usar puede reembolsarse según la Política de reembolsos. El servicio de pago puede cobrar una comisión.';

  @override
  String topUpButton(String amount) {
    return 'Recargar $amount';
  }

  @override
  String get topUpPaypalWaitingTitle => 'Esperando a PayPal';

  @override
  String get topUpPaypalWaitingBody =>
      'Completa el pago en la ventana de PayPal. Esta pantalla se actualiza sola.';

  @override
  String get topUpReopenPaypal => 'Abrir PayPal de nuevo';

  @override
  String get cryptoTitle => 'Pago con criptomonedas';

  @override
  String get cryptoCoin => 'Moneda';

  @override
  String get cryptoNetwork => 'Red';

  @override
  String get cryptoWaitingPayment => 'Esperando el pago';

  @override
  String get cryptoStepWaiting => 'Espera';

  @override
  String get cryptoStepConfirmations => 'Confirmaciones';

  @override
  String get cryptoStepCredited => 'Acreditado';

  @override
  String cryptoConfirmationsOf(int n, int m) {
    return '$n de $m';
  }

  @override
  String get cryptoSendExactly => 'Envía exactamente';

  @override
  String get cryptoToAddress => 'A la dirección';

  @override
  String cryptoRateLocked(String rate, String amount) {
    return 'Tipo de cambio fijado: $rate · Recarga de $amount';
  }

  @override
  String cryptoWarning(String coin, String network) {
    return 'Envía solo $coin en la red $network, el importe exacto en una sola transacción. Añade la comisión del monedero aparte: debe llegarnos el importe completo.';
  }

  @override
  String get cryptoCloseNote =>
      'Puedes cerrar esta pantalla: te avisaremos cuando se acredite el pago.';

  @override
  String get cryptoChangeAmountAction => 'Cambiar importe';

  @override
  String get cryptoChangeAmountTitle => '¿Elegir otro importe?';

  @override
  String get cryptoChangeAmountBody =>
      'Esta solicitud de pago seguirá activa hasta que termine el temporizador. Si ya enviaste criptomonedas, espera a que termine el pago. Si no, puedes crear otra solicitud con un importe diferente.';

  @override
  String get cryptoChangeCurrencyTitle => '¿Cambiar moneda o red?';

  @override
  String get cryptoChangeCurrencyBody =>
      'Otra moneda o red necesita una nueva dirección de pago. La solicitud actual sigue activa hasta que caduque. Si ya enviaste criptomonedas, espera a que termine el pago.';

  @override
  String get cryptoChangeCurrencyAction => 'Crear nuevo pago';

  @override
  String cryptoExpiresIn(String time) {
    return 'Caduca en $time';
  }

  @override
  String get topUpDoneTitle => 'Saldo recargado';

  @override
  String topUpDoneBody(String amount) {
    return 'Se han añadido $amount a tu saldo.';
  }

  @override
  String get actionDone => 'Listo';

  @override
  String get topUpExpiredTitle => 'El pago ha caducado';

  @override
  String get topUpExpiredBody =>
      'Si ya enviaste el dinero, se acreditará tras una revisión. Si no, empieza de nuevo.';

  @override
  String get actionTryAgain => 'Intentar de nuevo';

  @override
  String get ordersTitle => 'Pedidos';

  @override
  String get ordersTabPurchases => 'Compras';

  @override
  String get ordersTabTopUps => 'Recargas';

  @override
  String get ordersTabActivity => 'Actividad';

  @override
  String get ordersEmptyPurchases => 'Aún no hay compras';

  @override
  String get ordersEmptyTopUps => 'Aún no hay recargas';

  @override
  String get ordersEmptyActivity => 'Aún no hay movimientos de saldo';

  @override
  String get paymentDetailTitle => 'Detalles del pago';

  @override
  String get paymentDetailBreakdown => 'Desglose del pago';

  @override
  String get paymentDetailTransaction => 'Detalles de la transacción';

  @override
  String get orderDetailTitle => 'Detalles del pedido';

  @override
  String get activityDetailTitle => 'Detalles del movimiento';

  @override
  String get detailOrderNumber => 'Número de pedido';

  @override
  String get detailStatus => 'Estado';

  @override
  String get detailPackage => 'Paquete';

  @override
  String get detailFailureReason => 'Motivo del fallo';

  @override
  String get detailCompletedAt => 'Completado el';

  @override
  String get detailEsimId => 'ID de eSIM';

  @override
  String get detailOrderId => 'ID del pedido';

  @override
  String get detailViewEsim => 'Ver eSIM';

  @override
  String get detailType => 'Tipo';

  @override
  String get detailNote => 'Nota';

  @override
  String get detailBalanceAfter => 'Saldo posterior';

  @override
  String get detailReference => 'Registro relacionado';

  @override
  String get detailEntryId => 'ID del movimiento';

  @override
  String get detailViewReference => 'Ver detalles relacionados';

  @override
  String get paymentDetailTopUpAmount => 'Importe de la recarga';

  @override
  String get paymentDetailNumber => 'Número de pago';

  @override
  String get paymentDetailDate => 'Creado';

  @override
  String get paymentDetailCurrency => 'Moneda y red';

  @override
  String get paymentDetailExpected => 'Importe solicitado';

  @override
  String get paymentDetailReceived => 'Importe recibido';

  @override
  String get paymentDetailFee => 'Comisión de pago';

  @override
  String get paymentDetailTotal => 'Total en USD';

  @override
  String get paymentDetailProviderStatus => 'Estado del proveedor';

  @override
  String get paymentDetailTransactionId => 'ID de transacción';

  @override
  String get paymentDetailCredited => 'Añadido al saldo';

  @override
  String get paymentDetailCreditedAt => 'Fecha de abono';

  @override
  String get paymentDetailId => 'ID de pago';

  @override
  String get paymentDetailContinue => 'Ver instrucciones de pago';

  @override
  String get paymentDetailReview =>
      'Este pago requiere una revisión manual antes de actualizar el saldo.';

  @override
  String get paymentDetailOverpaid =>
      'El proveedor recibió más de lo solicitado. Soporte revisará el pago antes de actualizar tu saldo.';

  @override
  String get paymentDetailUnderpaid =>
      'El proveedor recibió menos de lo solicitado. Soporte revisará el pago antes de actualizar tu saldo.';

  @override
  String get paymentDetailLate =>
      'El pago llegó después de que terminara el plazo. Soporte lo revisará antes de actualizar tu saldo.';

  @override
  String orderNumberDate(String number, String date) {
    return 'Pedido $number · $date';
  }

  @override
  String get orderCompleted => 'Completado';

  @override
  String orderPurchaseTitle(String place, String plan) {
    return '$place · $plan';
  }

  @override
  String orderAddOnTitle(String place, String plan) {
    return 'Ampliación de plan · $place +$plan';
  }

  @override
  String get orderTopUpPaypal => 'Recarga de saldo · PayPal';

  @override
  String get orderTopUpCrypto => 'Recarga de saldo · Cripto';

  @override
  String get referralTitle => 'Invitar amigos';

  @override
  String referralHeroTitle(String reward) {
    return 'Recibe $reward por cada amigo';
  }

  @override
  String referralHeroBody(String reward) {
    return 'Un amigo se registra con tu código y tú recibes $reward en tu saldo.';
  }

  @override
  String get referralYourCode => 'Tu código';

  @override
  String get referralShare => 'Compartir invitación';

  @override
  String referralShareText(String code) {
    return '¿Viajas pronto? Descubre los planes eSIM de Waysim. Usa mi código de invitación al registrarte:\n$code';
  }

  @override
  String referralShareLinkText(String link, String code) {
    return '¿Viajas pronto? Descubre los planes eSIM de Waysim. Regístrate con mi enlace de invitación:\n$link\n\nCódigo de invitación: $code';
  }

  @override
  String get referralStatInvited => 'Invitados';

  @override
  String get referralStatCredited => 'Acreditado';

  @override
  String get referralStatPending => 'En revisión';

  @override
  String get referralStatRejected => 'Rechazados';

  @override
  String get referralRulesTitle => 'Reglas';

  @override
  String get referralRule1 =>
      'El bono solo se gasta en planes eSIM y no se puede retirar.';

  @override
  String get referralRule2 =>
      'Solo cuentan los usuarios nuevos de Waysim: un bono por dispositivo.';

  @override
  String get referralRule3 => 'No más de 10 bonos al mes.';

  @override
  String get referralRule4 =>
      'Las invitaciones se comprueban automáticamente. Se rechazan las autoinvitaciones y las cuentas falsas.';

  @override
  String get referralRule5 =>
      'El importe del bono se fija cuando tu amigo se registra.';

  @override
  String get referralFullTerms => 'Condiciones completas';

  @override
  String get referralYourInvites => 'Tus invitaciones';

  @override
  String referralInviteCredited(String reward) {
    return '+$reward acreditado';
  }

  @override
  String referralInviteSignedUp(String date) {
    return 'Registro: $date';
  }

  @override
  String get referralEmpty => 'Aún no hay invitaciones';

  @override
  String get supportSheetTitle => '¿En qué podemos ayudarte?';

  @override
  String get supportAiTitle => 'Chat de IA en línea';

  @override
  String get supportAiBody => 'Respuestas al instante 24/7';

  @override
  String get supportMailTitle => 'Escríbenos';

  @override
  String get supportMailBody => 'Te responderá una persona por correo';

  @override
  String supportMailSubject(String id) {
    return 'Waysim — consulta, ID $id';
  }

  @override
  String supportMailTemplate(String id, String app, String system) {
    return 'Describe tu consulta aquí.\n\n— Datos técnicos —\nID: $id\nApp: $app\nSistema: $system';
  }

  @override
  String supportMailFallback(String email) {
    return 'No se encontró ninguna app de correo. Nuestra dirección es $email.';
  }

  @override
  String get actionCopyAddress => 'Copiar dirección';

  @override
  String get chatTitle => 'Asistente de Waysim';

  @override
  String get chatBadge => 'Responde la IA';

  @override
  String get chatDisclaimer =>
      'La IA puede equivocarse. No ve tus pagos ni cambia tu saldo. No envíes contraseñas ni datos de tarjeta.';

  @override
  String get chatGreeting =>
      '¡Hola! Soy el asistente de IA de Waysim. Pregúntame sobre cómo elegir un plan, instalar una eSIM o conectarte en el extranjero.';

  @override
  String get chatChipInstall => '¿Cómo instalo una eSIM?';

  @override
  String get chatChipChoose => '¿Qué plan elijo?';

  @override
  String get chatChipNetwork => 'Mi eSIM no se conecta';

  @override
  String get chatNotHelped => '¿No te ha servido?';

  @override
  String get chatContactHuman => 'Escribir a una persona';

  @override
  String get chatInputHint => 'Escribe un mensaje';

  @override
  String get chatHistoryNote => 'El historial del chat se guarda 30 días';

  @override
  String get legalSectionTitle => 'Documentos';

  @override
  String get updateRequiredTitle => 'Actualiza la aplicación';

  @override
  String get updateRequiredBody =>
      'Esta versión ya no es compatible. Actualiza Waysim para seguir comprando y usando tus eSIM.';

  @override
  String get updateRequiredAction => 'Actualizar';

  @override
  String get integrityWarningTitle =>
      'Este dispositivo no puede obtener bonos por invitar';

  @override
  String get integrityWarningBody =>
      'Tu teléfono parece modificado (root, jailbreak o emulador). Todo lo demás funciona con normalidad.';

  @override
  String get noConnectionTitle => 'Sin conexión';

  @override
  String get noConnectionBody =>
      'Waysim necesita internet para cargar los planes y tus eSIM. Revisa el Wi‑Fi o los datos móviles e inténtalo de nuevo.';

  @override
  String get noConnectionWaiting => 'Esperando conexión…';

  @override
  String get noConnectionContinue => 'Continuar sin conexión';

  @override
  String get statusSuspended => 'Suspendida';

  @override
  String get statusCancelled => 'Cancelada';

  @override
  String get statusRevoked => 'Revocada';

  @override
  String get statusFailed => 'Fallido';

  @override
  String get paymentReview => 'Pago en revisión';

  @override
  String get paymentPending => 'Pendiente';

  @override
  String get paymentMemo => 'Memo / etiqueta de destino';

  @override
  String get supportTeam => 'Equipo de soporte';

  @override
  String get supportLiveDisclaimer =>
      'Tus mensajes llegan al equipo de soporte de Waysim.';

  @override
  String get supportLiveGreeting =>
      'Envíanos tu pregunta sobre Waysim o tu eSIM.';

  @override
  String get inviteCodeInvalid =>
      'Código de invitación no válido. Revísalo e inténtalo de nuevo.';

  @override
  String get paymentFailed => 'Pago no completado';

  @override
  String get paymentFailedBody =>
      'El pago no se completó. Contacta con soporte si ya enviaste los fondos.';

  @override
  String get activationOnInstall => 'Comienza al instalar la eSIM.';
}

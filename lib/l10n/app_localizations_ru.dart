// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Waysim';

  @override
  String get tabHome => 'Главное';

  @override
  String get tabMyEsim => 'Мои eSIM';

  @override
  String get tabProfile => 'Профиль';

  @override
  String greetingNamed(String name) {
    return 'Привет, $name!';
  }

  @override
  String get greeting => 'Привет!';

  @override
  String get signIn => 'Войти';

  @override
  String get searchHint => 'Где вам нужен eSIM?';

  @override
  String get supportFabLabel => 'Поддержка';

  @override
  String get homeLocal => 'Местные';

  @override
  String get homeRegional => 'Региональные';

  @override
  String priceFrom(String price) {
    return 'от $price';
  }

  @override
  String get myEsimTitle => 'Мои eSIM';

  @override
  String get myEsimCurrent => 'Текущие';

  @override
  String get myEsimArchive => 'Архив';

  @override
  String get myEsimEmptyTitle => 'Пока нет eSIM';

  @override
  String get myEsimEmptyBody =>
      'Купите пакет для поездки — это займёт пару минут.';

  @override
  String get buyEsim => 'Приобрести eSIM';

  @override
  String get howEsimWorks => 'Принцип работы eSIM';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileGuestTitle => 'Войдите, чтобы покупать eSIM';

  @override
  String get profileGuestBody =>
      'Покупки, баланс и eSIM сохранятся в аккаунте.';

  @override
  String get signUp => 'Зарегистрироваться';

  @override
  String get settings => 'Настройки';

  @override
  String get more => 'Подробнее';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get actionRetry => 'Повторить';

  @override
  String get offlineBanner => 'Нет подключения';

  @override
  String get errorNetwork =>
      'Нет подключения к интернету. Проверьте сеть и повторите.';

  @override
  String get errorTimeout => 'Время ожидания истекло. Попробуйте ещё раз.';

  @override
  String get errorServer =>
      'На нашей стороне произошла ошибка. Попробуйте позже.';

  @override
  String get errorUnauthorized => 'Сессия истекла. Войдите снова.';

  @override
  String get signedOutOnDevice =>
      'Вы вышли из аккаунта на этом устройстве. Войдите снова.';

  @override
  String get errorNotFound => 'Мы не нашли то, что вы искали.';

  @override
  String get errorUnknown => 'Что-то пошло не так. Попробуйте ещё раз.';

  @override
  String get actionCopy => 'Скопировать';

  @override
  String get toastCopied => 'Скопировано';

  @override
  String get actionContinue => 'Продолжить';

  @override
  String get actionCancel => 'Отмена';

  @override
  String get actionClose => 'Закрыть';

  @override
  String get actionGotIt => 'Понятно';

  @override
  String get actionLater => 'Позже';

  @override
  String get actionPasteCode => 'Вставить код';

  @override
  String get settingsGallery => 'Галерея дизайна (debug)';

  @override
  String unitGb(String value) {
    return '$value ГБ';
  }

  @override
  String unitMb(String value) {
    return '$value МБ';
  }

  @override
  String durationDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня',
      many: '$count дней',
      few: '$count дня',
      one: '$count день',
    );
    return '$_temp0';
  }

  @override
  String get dataUnlimited => 'Безлимит';

  @override
  String dailyAllowance(String size) {
    return '$size в день';
  }

  @override
  String unlimitedPlan(String daily, String days) {
    return 'Безлимит · $daily · $days';
  }

  @override
  String regionCountries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count страны',
      many: '$count стран',
      few: '$count страны',
      one: '$count страна',
    );
    return '$_temp0';
  }

  @override
  String get bannerEsimTitle => 'Что такое eSIM?';

  @override
  String get bannerEsimBody =>
      'Цифровая SIM-карта: ставится за пару минут, без пластика';

  @override
  String get bannerEsimAction => 'Как это работает →';

  @override
  String bannerInviteTitle(String reward) {
    return 'Пригласите друга — получите $reward';
  }

  @override
  String get bannerInviteAction => 'Пригласить →';

  @override
  String get bannerTravelTitle => 'Интернет в каждой поездке';

  @override
  String get bannerTravelBody => 'Местные пакеты для популярных направлений';

  @override
  String get bannerTravelAction => 'Смотреть страны →';

  @override
  String get catalogEmpty => 'Пока нет направлений';

  @override
  String get searchRecent => 'Недавние запросы';

  @override
  String get searchClear => 'Очистить';

  @override
  String get searchCountries => 'Страны';

  @override
  String get searchRegions => 'Регионы';

  @override
  String searchNoResults(String query) {
    return 'По запросу «$query» ничего не найдено';
  }

  @override
  String get searchNoResultsHint =>
      'Попробуйте название или код страны: «Турция», «US».';

  @override
  String get searchBack => 'Назад';

  @override
  String get compatSheetTitle => 'Поддерживает ли мой телефон eSIM?';

  @override
  String get compatSheetIos =>
      'Waysim не может автоматически проверить поддержку eSIM на этом iPhone. Некоторые региональные версии работают с двумя физическими SIM-картами, поэтому пакет eSIM может не работать на этом телефоне.';

  @override
  String get compatSheetAndroid =>
      'Waysim не удалось проверить доступность eSIM на этом устройстве. Перед покупкой пакета сверьтесь с характеристиками производителя.';

  @override
  String get compatUnverifiedRow => 'Поддержка eSIM не подтверждена';

  @override
  String get compatWarningTitle => 'Ваш телефон может не поддерживать eSIM';

  @override
  String get compatWarningBody =>
      'Вы можете купить пакет, но eSIM не будет работать на телефоне без поддержки eSIM. Всё равно продолжить?';

  @override
  String get actionContinueAnyway => 'Всё равно продолжить';

  @override
  String get packagesUnlimited => 'Безлимитные';

  @override
  String get packagesLimited => 'С лимитом';

  @override
  String get packagesChoose => 'Выберите пакет';

  @override
  String get esimActivatingNote =>
      'В некоторых странах eSIM активируется только после прилёта, когда телефон найдёт местную сеть. До этого в Настройках может быть написано «Активация…». Это нормально: не удаляйте eSIM.';

  @override
  String get packagesEmpty => 'В этой категории нет пакетов';

  @override
  String get packageDetailsLink => 'Сведения о пакете';

  @override
  String buyFor(String price) {
    return 'Купить за $price';
  }

  @override
  String get purchaseDisclaimer =>
      'Размещая заказ, вы подтверждаете, что используемое устройство совместимо с eSIM и не привязано к оператору.';

  @override
  String get oneTimePurchase =>
      'Разовая покупка — без подписки и автопродления.';

  @override
  String get detailCoverage => 'Покрытие';

  @override
  String get detailData => 'Трафик';

  @override
  String detailDataFull(String size) {
    return '$size на полной скорости';
  }

  @override
  String detailDataUnlimited(String size) {
    return 'Безлимит, $size в день на полной скорости';
  }

  @override
  String get detailValidity => 'Срок действия';

  @override
  String get detailValidityNote =>
      'Начинается с первого подключения eSIM к сети в стране поездки';

  @override
  String get detailNetwork => 'Сеть';

  @override
  String get detailHotspot => 'Раздача интернета';

  @override
  String get detailTopUp => 'Пополнение';

  @override
  String get detailCalls => 'Звонки и SMS';

  @override
  String get detailInstall => 'Установка';

  @override
  String get detailAvailable => 'Доступно';

  @override
  String get detailUnavailable => 'Недоступно';

  @override
  String get detailDataOnly => 'Только интернет';

  @override
  String get detailCallsIncluded => 'Включены';

  @override
  String detailInstallWithin(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'В течение $count дня',
      many: 'В течение $count дней',
      few: 'В течение $count дней',
      one: 'В течение $count дня',
    );
    return '$_temp0';
  }

  @override
  String get coverageCountries => 'Страны в пакете';

  @override
  String get confirmTitle => 'Подтвердите покупку';

  @override
  String get confirmPrice => 'Цена';

  @override
  String get confirmBalanceNow => 'Баланс сейчас';

  @override
  String get confirmBalanceAfter => 'Баланс после покупки';

  @override
  String get confirmConsent =>
      'Прошу выпустить eSIM сразу и понимаю, что после её установки отказаться от покупки нельзя. Разовая покупка — без подписки и автопродления.';

  @override
  String confirmPay(String price) {
    return 'Оплатить $price';
  }

  @override
  String get insufficientTitle => 'Недостаточно средств';

  @override
  String insufficientBody(String missing) {
    return 'Не хватает $missing для покупки этого пакета.';
  }

  @override
  String insufficientAction(String amount) {
    return 'Пополнить на $amount';
  }

  @override
  String get orderPreparing => 'Оформляем eSIM…';

  @override
  String get orderPreparingHint => 'Обычно это занимает несколько секунд.';

  @override
  String get orderSlow =>
      'Это занимает дольше обычного. Мы пришлём уведомление, когда eSIM будет готова.';

  @override
  String get orderFailedTitle => 'Не удалось оформить заказ';

  @override
  String get orderFailedBody =>
      'Если средства были списаны, они возвращены на баланс.';

  @override
  String orderPriceChanged(String price) {
    return 'Цена изменилась: $price. Проверьте и повторите.';
  }

  @override
  String get orderBackToPlans => 'К пакетам';

  @override
  String get actionGoToMyEsim => 'Перейти в «Мои eSIM»';

  @override
  String get esimReadyTitle => 'eSIM готова!';

  @override
  String get esimReadyBody =>
      'Установите её сейчас, пока есть Wi-Fi. Дни пакета начнут считаться только после подключения в стране поездки.';

  @override
  String get esimInstall => 'Установить eSIM';

  @override
  String get maintenanceBanner =>
      'Покупки и пополнения временно приостановлены.';

  @override
  String get errorMaintenance =>
      'Покупки временно приостановлены. Попробуйте позже.';

  @override
  String get errorPackageUnavailable => 'Этот пакет больше недоступен.';

  @override
  String get errorOrderFailed =>
      'Не удалось оформить заказ. Если средства списаны, они возвращены на баланс.';

  @override
  String get errorTooManyRequests =>
      'Слишком много запросов. Подождите немного.';

  @override
  String get errorBoundToOtherDevice =>
      'Эта eSIM уже привязана к другому устройству.';

  @override
  String get agoJustNow => 'только что';

  @override
  String agoMinutes(int count) {
    return '$count мин назад';
  }

  @override
  String agoHours(int count) {
    return '$count ч назад';
  }

  @override
  String agoDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня назад',
      many: '$count дней назад',
      few: '$count дня назад',
      one: '$count день назад',
    );
    return '$_temp0';
  }

  @override
  String get balanceLabel => 'Баланс';

  @override
  String get statusProvisioning => 'Оформляется';

  @override
  String get statusNotInstalled => 'Не установлена';

  @override
  String get statusInstalled => 'Установлена';

  @override
  String get statusActive => 'Активна';

  @override
  String get statusUsedUp => 'Израсходована';

  @override
  String get statusExpired => 'Истекла';

  @override
  String get statusFailedRefunded => 'Не выполнен, средства возвращены';

  @override
  String get myEsimArchiveEmpty => 'В архиве пусто';

  @override
  String esimLeftOf(String left, String total) {
    return 'Осталось $left из $total';
  }

  @override
  String esimDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Осталось $count дня',
      many: 'Осталось $count дней',
      few: 'Осталось $count дня',
      one: 'Остался $count день',
    );
    return '$_temp0';
  }

  @override
  String esimInstallBy(String date) {
    return 'Установить до $date';
  }

  @override
  String get esimValidityFromFirst => 'Срок пойдёт с первого подключения';

  @override
  String esimDeviceUpdated(String device, String ago) {
    return '$device · Обновлено $ago';
  }

  @override
  String esimUpdated(String ago) {
    return 'Обновлено $ago';
  }

  @override
  String esimRegionTitle(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count страны',
      many: '$count стран',
      few: '$count страны',
      one: '$count страна',
    );
    return '$name ($_temp0)';
  }

  @override
  String esimPackageLine(String volume, String duration) {
    return '$volume · $duration';
  }

  @override
  String get actionInstall => 'Установить';

  @override
  String get howTitle => 'Принцип работы eSIM';

  @override
  String get howStep1Title => 'Выберите пакет';

  @override
  String get howStep1Body =>
      'Найдите страну поездки и выберите нужный объём и количество дней.';

  @override
  String get howStep2Title => 'Оплатите с баланса';

  @override
  String get howStep2Body =>
      'Пополните баланс через PayPal или криптовалютой и купите пакет в одно нажатие.';

  @override
  String get howStep3Title => 'Установите до поездки';

  @override
  String get howStep3Body =>
      'Отсканируйте QR-код или установите в одно нажатие, пока есть Wi-Fi. Потом не удаляйте eSIM.';

  @override
  String get howStep4Title => 'Включите по прилёте';

  @override
  String get howStep4Body =>
      'Выберите eSIM Waysim для мобильных данных и включите для неё роуминг данных.';

  @override
  String get esimDetailTitle => 'Данные eSIM';

  @override
  String get installOneTap => 'Установить в одно нажатие';

  @override
  String installOneTapNote(String date) {
    return 'Для iPhone с iOS 17.4 и новее · Установить до $date';
  }

  @override
  String get installByQr => 'Установка по QR-коду';

  @override
  String get installQrNote =>
      'Отсканируйте QR-код камерой телефона, с которым поедете: откройте этот экран на другом устройстве или распечатайте код.';

  @override
  String get installQrRetryNote =>
      'Не удалось установить? Попробуйте второй раз. Если снова не получится, подождите 5 минут и повторите попытку: мы завершаем добавление этой eSIM в нашу систему.';

  @override
  String get installArrivalNote =>
      'eSIM подключится, когда вы прилетите в страну назначения и телефон найдёт местную сеть.';

  @override
  String get installStuckNote =>
      'Установка зависла на «Подключение»? Закройте её и проверьте Настройки → Сотовая связь. Если eSIM там нет, установите её вручную по данным ниже. Если она есть и написано «Активация…», до прилёта это нормально: не удаляйте её.';

  @override
  String get installLinkFailed =>
      'Не удалось открыть установку. Используйте QR-код или ручную установку ниже.';

  @override
  String get installManual => 'Ручная установка';

  @override
  String get esimSmdp => 'Адрес SM-DP+';

  @override
  String get esimActivationCode => 'Код активации';

  @override
  String get esimIccid => 'ICCID';

  @override
  String get esimFullActivationCode => 'Полный код активации';

  @override
  String get esimFullActivationCodeHint =>
      'На Samsung/Android выберите «Добавить eSIM» → «Сканировать QR-код» → «Ввести код активации вручную», затем вставьте полный код выше, начиная с LPA:1\$. Названия пунктов могут отличаться.';

  @override
  String get installManualIosHint =>
      'На iPhone откройте Настройки → Сотовая связь → Добавить eSIM → Использовать QR-код → Ввести данные вручную. Вставьте адрес SM-DP+ и код активации выше, а поле «Код подтверждения» оставьте пустым.';

  @override
  String get esimKeepWarning =>
      'Не удаляйте eSIM с телефона, пока пакет действует. Переустановить её можно только на этом же телефоне.';

  @override
  String get esimRoamingWarning =>
      'Чтобы не платить за роуминг домашнему оператору, выключите роуминг данных для основной SIM-карты.';

  @override
  String get instructionsTitle => 'Инструкция';

  @override
  String get tabIphone => 'iPhone';

  @override
  String get tabAndroid => 'Android';

  @override
  String get iosStep1 => 'Подключитесь к Wi-Fi.';

  @override
  String get iosStep2 => 'Откройте Настройки → Сотовая связь → Добавить eSIM.';

  @override
  String get iosStep3 =>
      'Выберите «Использовать QR-код» или «Ввести данные вручную».';

  @override
  String get iosStep4 =>
      'Назовите линию «Waysim». Основной номер оставьте для звонков и iMessage.';

  @override
  String get iosStep5 =>
      'По прилёте включите линию Waysim и «Роуминг данных», выберите её для сотовых данных.';

  @override
  String get androidStep1 => 'Подключитесь к Wi-Fi.';

  @override
  String get androidStep2 =>
      'В настройках откройте Диспетчер SIM-карт или SIM-карты и выберите «Добавить eSIM» (названия зависят от телефона).';

  @override
  String get androidStep3 =>
      'Выберите «Сканировать QR-код». Если сканировать не получается, нажмите «Ввести вручную» под сканером и вставьте полный код активации выше.';

  @override
  String get androidStep4 =>
      'Назовите линию «Waysim», основную SIM-карту оставьте для звонков.';

  @override
  String get androidStep5 =>
      'По прилёте включите линию Waysim и роуминг данных, выберите её для мобильного интернета.';

  @override
  String get usageTitle => 'Расход трафика';

  @override
  String get usageUnlimitedNote =>
      'Безлимитный пакет — расход показывает оператор';

  @override
  String get topUpPackage => 'Пополнить пакет';

  @override
  String get topUpPlansTitle => 'Пополнить пакет';

  @override
  String get topUpPlansSubtitle => 'Выберите пакет для этой eSIM';

  @override
  String get topUpPlansEmpty => 'Для этой eSIM нет пакетов пополнения.';

  @override
  String get topUpAddedTitle => 'Пакет добавлен';

  @override
  String get topUpAddedBody => 'Новые гигабайты и дни уже на вашей eSIM.';

  @override
  String get loginTitle => 'Вход или регистрация';

  @override
  String get loginBody =>
      'Мы отправим 6-значный код на почту. Пароль не нужен.';

  @override
  String get emailLabel => 'Электронная почта';

  @override
  String get emailHint => 'name@example.com';

  @override
  String get demoAccounts => 'Тестовые аккаунты';

  @override
  String get demoNewAccount => 'Новый аккаунт';

  @override
  String get demoExistingAccount => 'Аккаунт с историей';

  @override
  String demoCodeHint(String code) {
    return 'Тестовый код: $code (письмо не отправляется)';
  }

  @override
  String get inviteLabel => 'Код приглашения (необязательно)';

  @override
  String get termsConsent =>
      'Мне есть 18 лет, и я принимаю Условия использования. Как мы обрабатываем данные — в Политике конфиденциальности.';

  @override
  String get termsConsentStart => 'Мне есть 18 лет, и я принимаю ';

  @override
  String get termsOfUseLink => 'Условия использования';

  @override
  String get termsConsentMiddle => '. Как мы обрабатываем данные — в ';

  @override
  String get privacyPolicyLink => 'Политике конфиденциальности';

  @override
  String get termsConsentEnd => '.';

  @override
  String get loginErrorEmail => 'Введите корректный адрес почты';

  @override
  String get loginErrorTerms => 'Примите условия, чтобы продолжить';

  @override
  String get codeTitle => 'Введите код';

  @override
  String get codeInstructions => 'Введите 6-значный код, чтобы продолжить.';

  @override
  String get codeLabel => 'Код из письма';

  @override
  String resendIn(String time) {
    return 'Отправить снова через $time';
  }

  @override
  String get resendNow => 'Отправить снова';

  @override
  String get changeEmail => 'Изменить почту';

  @override
  String get checkSpam => 'Письма нет? Проверьте папку «Спам».';

  @override
  String get codeErrorWrong => 'Неверный код. Попробуйте ещё раз.';

  @override
  String get codeErrorExpired => 'Срок действия кода истёк. Запросите новый.';

  @override
  String get codeErrorTooMany => 'Слишком много попыток. Попробуйте позже.';

  @override
  String get nameTitle => 'Как к вам обращаться?';

  @override
  String get nameBody =>
      'Необязательно — мы будем использовать имя в приветствии.';

  @override
  String get nameHint => 'Ваше имя';

  @override
  String get actionSkip => 'Пропустить';

  @override
  String profileId(String id) {
    return 'ID $id';
  }

  @override
  String get actionTopUp => 'Пополнить';

  @override
  String get orders => 'Заказы';

  @override
  String get inviteFriends => 'Пригласить друзей';

  @override
  String get myDevices => 'Мои устройства';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get signOut => 'Выйти';

  @override
  String get signOutConfirmTitle => 'Выйти из аккаунта?';

  @override
  String get signOutConfirmBody => 'Вы уверены, что хотите выйти из аккаунта?';

  @override
  String get settingsNotifications => 'Уведомления';

  @override
  String get notifEsimTitle => 'Уведомления';

  @override
  String get notifEsimBody => 'Статус eSIM, баланс и расход трафика';

  @override
  String get notifNewsTitle => 'Новости и предложения';

  @override
  String get notifNewsBody => 'Скидки и новые страны';

  @override
  String aboutVersion(String version, String build) {
    return 'Версия $version ($build)';
  }

  @override
  String get aboutTagline => 'Мобильный интернет в поездках';

  @override
  String get aboutApp => 'О приложении';

  @override
  String get devicesTitle => 'Мои устройства';

  @override
  String get devicesNote =>
      'Управляйте устройствами, на которых выполнен вход в ваш аккаунт.';

  @override
  String get deviceRemove => 'Удалить устройство';

  @override
  String get deviceRemoveTitle => 'Удалить это устройство?';

  @override
  String deviceRemoveBody(String device) {
    return 'Выйти из Waysim на устройстве $device? На нём можно будет войти снова.';
  }

  @override
  String get deviceRemoved => 'Устройство удалено.';

  @override
  String get deviceThis => 'Это устройство';

  @override
  String deviceLastSeen(String ago) {
    return 'Был активен $ago';
  }

  @override
  String get deleteTitle => 'Удаление аккаунта';

  @override
  String get deleteWarnTitle => 'Это действие нельзя отменить';

  @override
  String deleteBullet1(String balance) {
    return 'Остаток баланса ($balance) и бонусы сгорят.';
  }

  @override
  String get deleteBullet2 =>
      'Неустановленные eSIM-пакеты будут аннулированы без возврата.';

  @override
  String get deleteBullet3 =>
      'Уже установленные eSIM будут работать до конца срока пакета.';

  @override
  String get deleteBullet4 =>
      'Личные данные будут обезличены в течение 30 дней. Записи об оплатах хранятся столько, сколько требует закон.';

  @override
  String get deleteRefundNote =>
      'Хотите вернуть неиспользованное пополнение? Напишите в поддержку до удаления.';

  @override
  String get deleteSupportLink => 'Напишите в поддержку';

  @override
  String deleteCodeBody(String email) {
    return 'Введите 6-значный код, отправленный на $email, чтобы подтвердить.';
  }

  @override
  String get deleteConfirm => 'Удалить мой аккаунт';

  @override
  String get deleteDone => 'Аккаунт удалён';

  @override
  String get topUpTitle => 'Пополнить баланс';

  @override
  String get topUpCurrentBalance => 'Текущий баланс';

  @override
  String get topUpChooseAmount => 'Выберите сумму';

  @override
  String get topUpOtherAmount => 'Другая сумма';

  @override
  String get topUpAmountHint => 'Сумма в USD';

  @override
  String topUpAmountInvalid(String min, String max) {
    return 'Введите сумму от $min до $max';
  }

  @override
  String get topUpMethod => 'Способ оплаты';

  @override
  String get topUpPaypalTitle => 'PayPal';

  @override
  String get topUpPaypalBody => 'Баланс PayPal или карта через PayPal';

  @override
  String get topUpCryptoTitle => 'Криптовалюта';

  @override
  String get topUpCryptoBody => 'Выберите монету и сеть';

  @override
  String get topUpMinimumLabel => 'Минимальное пополнение';

  @override
  String get topUpPaymentFeeIncluded => 'Комиссия включена в сумму к отправке';

  @override
  String get topUpNote =>
      'Баланс тратится только на eSIM-пакеты и не выводится. Неиспользованное пополнение можно вернуть по Политике возврата средств. Платёжный сервис может взять комиссию.';

  @override
  String topUpButton(String amount) {
    return 'Пополнить на $amount';
  }

  @override
  String get topUpPaypalWaitingTitle => 'Ждём подтверждение PayPal';

  @override
  String get topUpPaypalWaitingBody =>
      'Завершите оплату в окне PayPal. Этот экран обновится сам.';

  @override
  String get topUpReopenPaypal => 'Открыть PayPal снова';

  @override
  String get cryptoTitle => 'Оплата криптовалютой';

  @override
  String get cryptoCoin => 'Монета';

  @override
  String get cryptoNetwork => 'Сеть';

  @override
  String get cryptoWaitingPayment => 'Ожидаем оплату';

  @override
  String get cryptoStepWaiting => 'Ожидаем';

  @override
  String get cryptoStepConfirmations => 'Подтверждения';

  @override
  String get cryptoStepCredited => 'Зачислено';

  @override
  String cryptoConfirmationsOf(int n, int m) {
    return '$n из $m';
  }

  @override
  String get cryptoSendExactly => 'Отправьте ровно';

  @override
  String get cryptoToAddress => 'На адрес';

  @override
  String cryptoRateLocked(String rate, String amount) {
    return 'Курс зафиксирован: $rate · Пополнение на $amount';
  }

  @override
  String cryptoFeeOnTop(String amount, String fee, String total) {
    return '$amount + комиссия $fee = $total';
  }

  @override
  String get contactsTitle => 'Связаться с нами';

  @override
  String cryptoWarning(String coin, String network) {
    return 'Отправляйте только $coin в сети $network, точную сумму одной транзакцией. Комиссию кошелька добавьте сверху — к нам должна прийти полная сумма.';
  }

  @override
  String get cryptoCloseNote =>
      'Можно закрыть экран — мы пришлём уведомление, когда платёж зачислится.';

  @override
  String get cryptoChangeAmountAction => 'Изменить сумму';

  @override
  String get cryptoChangeAmountTitle => 'Выбрать другую сумму?';

  @override
  String get cryptoChangeAmountBody =>
      'Этот счёт остаётся активным до конца таймера. Если вы уже отправили криптовалюту, дождитесь завершения платежа. Иначе можно создать новый счёт на другую сумму.';

  @override
  String get cryptoChangeCurrencyTitle => 'Изменить монету или сеть?';

  @override
  String get cryptoChangeCurrencyBody =>
      'Для другой монеты или сети нужен новый адрес оплаты. Текущий счёт остаётся активным до истечения срока. Если вы уже отправили криптовалюту, дождитесь завершения платежа.';

  @override
  String get cryptoChangeCurrencyAction => 'Создать новый счёт';

  @override
  String get topUpDoneTitle => 'Баланс пополнен';

  @override
  String topUpDoneBody(String amount) {
    return '$amount зачислено на ваш баланс.';
  }

  @override
  String get actionDone => 'Готово';

  @override
  String get topUpExpiredTitle => 'Время оплаты истекло';

  @override
  String get topUpExpiredBody =>
      'Если вы уже отправили деньги, они будут зачислены после проверки. Иначе начните заново.';

  @override
  String get actionTryAgain => 'Попробовать снова';

  @override
  String get ordersTitle => 'Заказы';

  @override
  String get ordersTabPurchases => 'Покупки';

  @override
  String get ordersTabTopUps => 'Пополнения';

  @override
  String get ordersTabActivity => 'Операции';

  @override
  String get ordersEmptyPurchases => 'Покупок пока нет';

  @override
  String get ordersEmptyTopUps => 'Пополнений пока нет';

  @override
  String get ordersEmptyActivity => 'Операций по балансу пока нет';

  @override
  String get paymentDetailTitle => 'Детали платежа';

  @override
  String get paymentDetailBreakdown => 'Расчёт платежа';

  @override
  String get paymentDetailTransaction => 'Детали транзакции';

  @override
  String get orderDetailTitle => 'Детали заказа';

  @override
  String get activityDetailTitle => 'Детали операции';

  @override
  String get detailOrderNumber => 'Номер заказа';

  @override
  String get detailStatus => 'Статус';

  @override
  String get detailPackage => 'Пакет';

  @override
  String get detailFailureReason => 'Причина ошибки';

  @override
  String get detailCompletedAt => 'Завершено';

  @override
  String get detailEsimId => 'ID eSIM';

  @override
  String get detailOrderId => 'ID заказа';

  @override
  String get detailViewEsim => 'Открыть eSIM';

  @override
  String get detailType => 'Тип';

  @override
  String get detailNote => 'Примечание';

  @override
  String get detailBalanceAfter => 'Баланс после';

  @override
  String get detailReference => 'Связанная запись';

  @override
  String get detailEntryId => 'ID операции';

  @override
  String get detailViewReference => 'Открыть связанные детали';

  @override
  String get paymentDetailTopUpAmount => 'Сумма пополнения';

  @override
  String get paymentDetailNumber => 'Номер платежа';

  @override
  String get paymentDetailDate => 'Создан';

  @override
  String get paymentDetailCurrency => 'Монета и сеть';

  @override
  String get paymentDetailExpected => 'Запрошенная сумма';

  @override
  String get paymentDetailReceived => 'Полученная сумма';

  @override
  String get paymentDetailFee => 'Комиссия за оплату';

  @override
  String get paymentDetailTotal => 'Итого в USD';

  @override
  String get paymentDetailProviderStatus => 'Статус провайдера';

  @override
  String get paymentDetailTransactionId => 'ID транзакции';

  @override
  String get paymentDetailCredited => 'Зачислено на баланс';

  @override
  String get paymentDetailCreditedAt => 'Дата зачисления';

  @override
  String get paymentDetailId => 'ID платежа';

  @override
  String get paymentDetailContinue => 'Посмотреть инструкции по оплате';

  @override
  String get paymentDetailReview =>
      'Перед зачислением на баланс этот платёж нужно проверить вручную.';

  @override
  String get paymentDetailOverpaid =>
      'Платёжный сервис получил больше запрошенной суммы. Поддержка проверит платёж перед зачислением на баланс.';

  @override
  String get paymentDetailUnderpaid =>
      'Платёжный сервис получил меньше запрошенной суммы. Поддержка проверит платёж перед зачислением на баланс.';

  @override
  String get paymentDetailLate =>
      'Платёж поступил после окончания срока оплаты. Поддержка проверит его перед зачислением на баланс.';

  @override
  String orderNumberDate(String number, String date) {
    return 'Заказ $number · $date';
  }

  @override
  String get orderCompleted => 'Выполнен';

  @override
  String orderPurchaseTitle(String place, String plan) {
    return '$place · $plan';
  }

  @override
  String orderAddOnTitle(String place, String plan) {
    return 'Пополнение пакета · $place +$plan';
  }

  @override
  String get orderTopUpPaypal => 'Пополнение баланса · PayPal';

  @override
  String get orderTopUpCrypto => 'Пополнение баланса · Криптовалюта';

  @override
  String get referralTitle => 'Пригласить друзей';

  @override
  String referralHeroTitle(String reward) {
    return 'Получите $reward за каждого друга';
  }

  @override
  String referralHeroBody(String reward) {
    return 'Друг регистрируется с вашим кодом — вы получаете $reward на баланс.';
  }

  @override
  String get referralYourCode => 'Ваш код';

  @override
  String get referralShare => 'Поделиться приглашением';

  @override
  String referralShareText(String code) {
    return 'Собираетесь в поездку? Посмотрите eSIM-тарифы Waysim. При регистрации укажите мой код приглашения:\n$code';
  }

  @override
  String referralShareLinkText(String link, String code) {
    return 'Собираетесь в поездку? Посмотрите eSIM-тарифы Waysim. Зарегистрируйтесь по моей ссылке:\n$link\n\nКод приглашения: $code';
  }

  @override
  String get referralStatInvited => 'Приглашено';

  @override
  String get referralStatCredited => 'Начислено';

  @override
  String get referralStatPending => 'На проверке';

  @override
  String get referralStatRejected => 'Отклонено';

  @override
  String get referralRulesTitle => 'Правила';

  @override
  String get referralRule1 =>
      'Бонус тратится только на eSIM-пакеты и не выводится.';

  @override
  String get referralRule2 =>
      'Засчитываются только новые пользователи Waysim — один бонус на устройство.';

  @override
  String get referralRule3 => 'Не больше 10 бонусов в месяц.';

  @override
  String get referralRule4 =>
      'Приглашения проверяются автоматически. Приглашения самого себя и фейковые аккаунты отклоняются.';

  @override
  String get referralRule5 =>
      'Сумма бонуса фиксируется в момент регистрации друга.';

  @override
  String get referralFullTerms => 'Полные условия';

  @override
  String get referralYourInvites => 'Ваши приглашения';

  @override
  String referralInviteCredited(String reward) {
    return '+$reward начислено';
  }

  @override
  String referralInviteSignedUp(String date) {
    return 'Регистрация: $date';
  }

  @override
  String get referralEmpty => 'Приглашений пока нет';

  @override
  String get supportSheetTitle => 'Чем помочь?';

  @override
  String get supportAiTitle => 'Онлайн-чат с ИИ';

  @override
  String get supportAiBody => 'Мгновенные ответы 24/7';

  @override
  String get supportMailTitle => 'Написать нам';

  @override
  String get supportMailBody => 'Ответит сотрудник по почте';

  @override
  String supportMailSubject(String id) {
    return 'Waysim — обращение, ID $id';
  }

  @override
  String supportMailTemplate(String id, String app, String system) {
    return 'Опишите ваш вопрос здесь.\n\n— Технические данные —\nID: $id\nПриложение: $app\nСистема: $system';
  }

  @override
  String supportMailFallback(String email) {
    return 'Почтовое приложение не найдено. Наш адрес: $email.';
  }

  @override
  String get actionCopyAddress => 'Скопировать адрес';

  @override
  String get chatTitle => 'Помощник Waysim';

  @override
  String get chatBadge => 'Отвечает ИИ';

  @override
  String get chatDisclaimer =>
      'ИИ может ошибаться. Он не видит ваши платежи и не меняет баланс. Не отправляйте пароли и данные карт.';

  @override
  String get chatGreeting =>
      'Привет! Я ИИ-помощник Waysim. Спросите меня о выборе пакета, установке eSIM или подключении за границей.';

  @override
  String get chatChipInstall => 'Как установить eSIM?';

  @override
  String get chatChipChoose => 'Какой пакет выбрать?';

  @override
  String get chatChipNetwork => 'eSIM не подключается к сети';

  @override
  String get chatNotHelped => 'Не помогло?';

  @override
  String get chatContactHuman => 'Написать сотруднику';

  @override
  String get chatInputHint => 'Напишите сообщение';

  @override
  String get chatHistoryNote => 'История чата хранится 30 дней';

  @override
  String get updateRequiredTitle => 'Обновите приложение';

  @override
  String get updateRequiredBody =>
      'Эта версия больше не поддерживается. Обновите Waysim, чтобы покупать и использовать eSIM.';

  @override
  String get updateRequiredAction => 'Обновить';

  @override
  String get integrityWarningTitle =>
      'С этого устройства нельзя получать реферальные бонусы';

  @override
  String get integrityWarningBody =>
      'Ваш телефон похож на изменённый (root, jailbreak или эмулятор). Всё остальное работает как обычно.';

  @override
  String get noConnectionTitle => 'Нет подключения';

  @override
  String get noConnectionBody =>
      'Waysim нужен интернет, чтобы загрузить тарифы и ваши eSIM. Проверьте Wi‑Fi или мобильные данные и повторите.';

  @override
  String get noConnectionWaiting => 'Ждём подключение…';

  @override
  String get noConnectionContinue => 'Продолжить без сети';

  @override
  String get statusSuspended => 'Приостановлена';

  @override
  String get statusCancelled => 'Отменена';

  @override
  String get statusRevoked => 'Отозвана';

  @override
  String get statusFailed => 'Ошибка';

  @override
  String get paymentReview => 'Платёж на проверке';

  @override
  String get paymentPending => 'В обработке';

  @override
  String get paymentMemo => 'Memo / тег назначения';

  @override
  String get supportTeam => 'Служба поддержки';

  @override
  String get supportLiveDisclaimer =>
      'Ваши сообщения получает служба поддержки Waysim.';

  @override
  String get supportLiveGreeting => 'Задайте вопрос о Waysim или вашей eSIM.';

  @override
  String get inviteCodeInvalid =>
      'Неверный код приглашения. Проверьте его и повторите.';

  @override
  String get paymentFailed => 'Платёж не завершён';

  @override
  String get paymentFailedBody =>
      'Платёж не завершён. Если вы уже отправили средства, обратитесь в поддержку.';

  @override
  String get activationOnInstall => 'Начинается с момента установки eSIM.';

  @override
  String get notifPromptTitle =>
      'Включите уведомления, чтобы получить максимум от Waysim';

  @override
  String get notifPromptBody =>
      'Получайте оповещения, например о заканчивающемся трафике. Иногда мы также будем присылать акции и предложения — настройки уведомлений можно изменить в профиле в любой момент.';

  @override
  String get notifPromptLater => 'Позже';

  @override
  String get notifPromptEnable => 'Включить';

  @override
  String get compatNoRow => 'Ваше устройство не поддерживает eSIM';

  @override
  String get compatNoSheetTitle => 'Проверьте устройство';

  @override
  String get compatNoBody =>
      'Возможно, вы не сможете использовать Waysim на этом устройстве.';

  @override
  String get compatNoOtherLead => 'Если вы покупаете для другого устройства, ';

  @override
  String get compatNoOtherBold =>
      'убедитесь, что оно поддерживает eSIM и не привязано к оператору или сети.';

  @override
  String get compatYesRow => 'Ваше устройство поддерживает eSIM';

  @override
  String get compatYesLead =>
      'Отлично! Если вы получили устройство через мобильного оператора, ';

  @override
  String get compatYesBold =>
      'убедитесь, что оно не привязано к оператору или сети.';

  @override
  String get compatLockTitle =>
      'Как проверить, привязано ли устройство к оператору или сети';

  @override
  String get compatLockIos =>
      'Откройте Настройки → Основные → Об этом устройстве. В строке «Блокировка оператором» должно быть «SIM без ограничений». Блокировка оператора может помешать работе туристической eSIM.';

  @override
  String get compatLockAndroid =>
      'Откройте настройки устройства и найдите раздел SIM, оператора или блокировки сети (например, Настройки → Подключения → Диспетчер SIM). Если блокировок и ограничений нет, всё готово!';

  @override
  String get compatLockTip =>
      'Если есть блокировка или ограничения, возможно, нужно обратиться к своему мобильному оператору.';

  @override
  String get compatNoCheckDevices => 'Проверить поддерживаемые устройства';
}

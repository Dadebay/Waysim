import '../utils/formatters/money.dart';

abstract interface class AnalyticsService {
  void logEvent(String name, [Map<String, Object> parameters]);

  void logPurchase(AnalyticsPurchase purchase);

  void logScreen(String name);

  void setUserId(String? publicId);

  void setUserProperty(String name, String? value);
}

class NoopAnalytics implements AnalyticsService {
  @override
  void logEvent(String name, [Map<String, Object> parameters = const {}]) {}

  @override
  void logPurchase(AnalyticsPurchase purchase) {}

  @override
  void logScreen(String name) {}

  @override
  void setUserId(String? publicId) {}

  @override
  void setUserProperty(String name, String? value) {}
}

class AnalyticsPurchase {
  const AnalyticsPurchase({
    required this.transactionId,
    required this.packageId,
    required this.destination,
    required this.price,
    required this.addOn,
  });

  final String transactionId;
  final String packageId;
  final String destination;
  final Money price;
  final bool addOn;

  double get value => price.cents / 100;

  Map<String, Object> get eventParameters => {
    'transaction_id': transactionId,
    'currency': AnalyticsEvents.currency,
    'value': value,
    'destination_code': destination,
    'add_on': addOn ? 1 : 0,
    'items': [
      {
        'item_id': packageId,
        'item_category': destination,
        'price': value,
        'quantity': 1,
      },
    ],
  };
}

extension AnalyticsEvents on AnalyticsService {
  static const currency = 'USD';

  static double dollars(Money m) => m.cents / 100;

  void searched(
    String term, {
    required int results,
    String? destinationCode,
    bool region = false,
  }) => logEvent('search', {
    'search_term': term,
    'results': results,
    'destination_code': ?destinationCode,
    if (destinationCode != null)
      'destination_type': region ? 'region' : 'country',
  });

  void viewedDestination({required String code, required bool region}) =>
      logEvent('view_item_list', {
        'item_list_id': code,
        'item_list_name': region ? 'region' : 'country',
      });

  void selectedPackage({required String packageId, required Money price}) =>
      logEvent('select_item', {
        'item_id': packageId,
        'value': dollars(price),
        'currency': currency,
      });

  void openedPackageDetails(String packageId) =>
      logEvent('view_item', {'item_id': packageId});

  void startedCheckout({
    required String packageId,
    required Money price,
    required bool addOn,
  }) => logEvent('begin_checkout', {
    'currency': currency,
    'value': dollars(price),
    'item_id': packageId,
    'add_on': addOn ? 1 : 0,
  });

  void purchased({
    required String transactionId,
    required String packageId,
    required String destination,
    required Money price,
    required bool addOn,
  }) => logPurchase(
    AnalyticsPurchase(
      transactionId: transactionId,
      packageId: packageId,
      destination: destination,
      price: price,
      addOn: addOn,
    ),
  );

  void purchaseFailed({required String packageId, required String reason}) =>
      logEvent('purchase_failed', {'item_id': packageId, 'reason': reason});

  void signedUp() => logEvent('sign_up', {'method': 'email_otp'});

  void loggedIn() => logEvent('login', {'method': 'email_otp'});

  void startedEsimInstall({required String method}) =>
      logEvent('esim_install_started', {'method': method});

  void startedTopUp({required String method, required Money amount}) =>
      logEvent('top_up_started', {
        'method': method,
        'value': dollars(amount),
        'currency': currency,
      });

  void creditedTopUp({required String method, required Money amount}) =>
      logEvent('top_up_credited', {
        'method': method,
        'value': dollars(amount),
        'currency': currency,
      });

  void opened(String what) => logEvent('open_$what');

  void shared(String what) => logEvent('share', {'content_type': what});

  void changedSetting(String setting, String value) =>
      logEvent('setting_changed', {'setting': setting, 'value': value});

  void inviteLinkOpened(String code) =>
      logEvent('invite_link_opened', {'code': code});
}

class AnalyticsScreenTracker {
  AnalyticsScreenTracker(this._analytics, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AnalyticsService _analytics;
  final DateTime Function() _now;
  String? _screen;
  Object? _routeKey;
  DateTime? _enteredAt;
  bool _foreground = true;

  static String currentScreen = 'launch';

  void enter(String name, {Object? routeKey}) {
    if (name.isEmpty || (_screen == name && _routeKey == routeKey)) return;
    _recordElapsed();
    _screen = name;
    _routeKey = routeKey;
    _enteredAt = _foreground ? _now() : null;
    currentScreen = name;
    _analytics.logScreen(name);
  }

  void pause() {
    _foreground = false;
    _recordElapsed();
  }

  void _recordElapsed() {
    final start = _enteredAt;
    final name = _screen;
    _enteredAt = null;
    if (start == null || name == null) return;
    final milliseconds = _now().difference(start).inMilliseconds;
    if (milliseconds < 1000) return;
    _analytics.logEvent('screen_time', {
      'screen_name': name,
      'duration_ms': milliseconds.clamp(
        0,
        const Duration(hours: 24).inMilliseconds,
      ),
    });
  }

  void resume() {
    if (_foreground) return;
    _foreground = true;
    if (_screen != null) _enteredAt = _now();
  }
}

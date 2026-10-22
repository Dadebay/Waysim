import '../utils/formatters/money.dart';

/// Product analytics. The contract the app logs through; Firebase Analytics
/// implements it in release, [NoopAnalytics] everywhere else (tests, builds
/// without Firebase).
///
/// What the dashboards answer, and how:
/// * **Where users come from** — Firebase collects the install source on its
///   own (Google Play referrer, campaign links); an invitation link adds the
///   `invite_link_opened` event and the `acquisition` user property.
/// * **Who buys what** — the standard `view_item`, `begin_checkout` and
///   `purchase` events, with the package as the item and the price as value.
/// * **How long they stay** — `session_start` and `user_engagement`
///   (engagement time) are automatic; `screen_view` shows the path taken.
abstract interface class AnalyticsService {
  void logEvent(String name, [Map<String, Object> parameters]);

  void logScreen(String name);

  /// The public id (`A0123`) only — never an e-mail address.
  void setUserId(String? publicId);

  void setUserProperty(String name, String? value);
}

class NoopAnalytics implements AnalyticsService {
  @override
  void logEvent(String name, [Map<String, Object> parameters = const {}]) {}

  @override
  void logScreen(String name) {}

  @override
  void setUserId(String? publicId) {}

  @override
  void setUserProperty(String name, String? value) {}
}

/// Event names and parameters in one place, so the dashboards and the code
/// cannot drift apart. Money is sent in dollars (a number) as Firebase
/// expects; everywhere else in the app it stays in cents.
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

  /// A paid order that finished. [transactionId] is the eSIM's id.
  void purchased({
    required String transactionId,
    required String packageId,
    required String destination,
    required Money price,
    required bool addOn,
  }) => logEvent('purchase', {
    'transaction_id': transactionId,
    'currency': currency,
    'value': dollars(price),
    'item_id': packageId,
    'item_category': destination,
    'destination_code': destination,
    'add_on': addOn ? 1 : 0,
  });

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

  /// Someone opened an invitation link (`waysim.co/r/CODE`).
  void inviteLinkOpened(String code) =>
      logEvent('invite_link_opened', {'code': code});
}

/// Tracks the visible route once, across the root navigator and tab branches.
/// Only active foreground time is counted; route IDs and query strings are
/// never sent to Analytics.
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

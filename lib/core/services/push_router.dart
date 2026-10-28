import '../../app/router/app_routes.dart';

abstract final class PushRouter {
  static final _id = RegExp(r'^[A-Za-z0-9_-]{1,64}$');

  static const _locales = {'en', 'zh', 'ru', 'es', 'fr'};

  static String? routeFor(Map<String, String> data) {
    final paymentId = data['paymentId'];
    if (data['type'] == 'payment_credited' &&
        paymentId != null &&
        _id.hasMatch(paymentId)) {
      return AppRoute.paymentDetail.withParams({'id': paymentId});
    }
    final deepLink = routeForLink(data['deepLink'] ?? data['link'] ?? '');
    if (deepLink != null) return deepLink;
    final id = data['esimId'];
    final validId = id != null && _id.hasMatch(id);

    switch (data['type']) {
      case 'esim_ready' ||
          'order_done' ||
          'topup_done' ||
          'data_low' ||
          'validity_low' ||
          'esim_used_up' ||
          'esim_status' ||
          'esim_usage' ||
          'esim_usage_low' ||
          'esim_expiring_soon':
        return validId
            ? AppRoute.esim.withParams({'id': id})
            : AppRoute.myEsim.path;

      case 'order_failed' || 'topup_failed':
        return AppRoute.orders.path;

      case 'balance_topped_up' ||
          'payment_credited' ||
          'wallet_adjusted' ||
          'reward':
        return AppRoute.profile.path;

      case 'referral_bonus':
        return AppRoute.referral.path;

      case 'support_reply':
        return AppRoute.supportChat.path;
      case 'broadcast':
        return routeForLink(data['link'] ?? '') ?? _safePath(data['path']);
      default:
        return routeForLink(data['link'] ?? '');
    }
  }

  static String? routeForLink(String link) {
    final uri = Uri.tryParse(link);
    if (uri == null) return null;
    if (uri.scheme != 'waysim' &&
        !(uri.scheme == 'https' && uri.host == 'waysim.co')) {
      return null;
    }
    final parts = [
      if (uri.scheme == 'waysim' && uri.host.isNotEmpty) uri.host,
      ...uri.pathSegments,
    ];

    if (uri.scheme == 'https' &&
        parts.length == 3 &&
        _locales.contains(parts.first)) {
      parts.removeAt(0);
    }
    if (parts.length == 1) {
      return switch (parts.first) {
        'home' => AppRoute.home.path,
        'esims' => AppRoute.myEsim.path,
        'profile' => AppRoute.profile.path,
        'wallet' || 'top-up' || 'balance-top-up' => AppRoute.balanceTopUp.path,
        'how-it-works' => '${AppRoute.home.path}?guide=true',
        'support' => AppRoute.supportChat.path,
        'referral' => AppRoute.referral.path,
        'orders' => AppRoute.orders.path,
        _ => null,
      };
    }
    if (parts.length != 2 || !_id.hasMatch(parts[1])) return null;
    return switch (parts[0]) {
      'esim' || 'esims' => AppRoute.esim.withParams({'id': parts[1]}),
      'payment' => '${AppRoute.balanceTopUp.path}?paymentId=${parts[1]}',
      'destination' ||
      'location' ||
      'country' ||
      'region' => AppRoute.destination.withParams({'code': parts[1]}),
      'orders' => AppRoute.orders.path,
      'packages' => '/package/${Uri.encodeComponent(parts[1])}',
      'legal' => AppRoute.legalDocument.withParams({'id': parts[1]}),
      'r' || 'invite' => AppRoute.invite.withParams({'code': parts[1]}),
      _ => null,
    };
  }

  static String? _safePath(String? path) {
    if (path == null || !path.startsWith('/') || path.startsWith('//')) {
      return null;
    }
    const allowed = ['/home', '/my-esim', '/profile', '/referral', '/orders'];
    return allowed.contains(path) ? path : null;
  }
}

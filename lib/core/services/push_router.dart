import '../../app/router/app_routes.dart';

/// Turns a notification's data into the screen it opens, or `null` when it
/// should just open the app. Everything in a payload is untrusted text: ids
/// are checked against a strict pattern and only known types navigate.
abstract final class PushRouter {
  static final _id = RegExp(r'^[A-Za-z0-9_-]{1,64}$');

  static String? routeFor(Map<String, String> data) {
    final id = data['esimId'];
    final validId = id != null && _id.hasMatch(id);

    switch (data['type']) {
      // eSIM ready; ≤100 MB left; 1 day left; plan used up.
      case 'esim_ready' || 'data_low' || 'validity_low' || 'esim_used_up':
        return validId
            ? AppRoute.esim.withParams({'id': id})
            : AppRoute.myEsim.path;
      // Order failed and the money came back.
      case 'order_failed':
        return AppRoute.orders.path;
      // Balance topped up.
      case 'balance_topped_up':
        return AppRoute.profile.path;
      // Referral bonus credited.
      case 'referral_bonus':
        return AppRoute.referral.path;
      // A broadcast from the admin: a path inside the app, nothing external.
      case 'broadcast':
        return _safePath(data['path']);
      default:
        return null;
    }
  }

  static String? _safePath(String? path) {
    if (path == null || !path.startsWith('/') || path.startsWith('//')) {
      return null;
    }
    const allowed = ['/home', '/my-esim', '/profile', '/referral', '/orders'];
    return allowed.contains(path) ? path : null;
  }
}

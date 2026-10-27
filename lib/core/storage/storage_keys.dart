/// Keys for local persistence. Keeping them here prevents typo-driven bugs.
abstract final class StorageKeys {
  // Secure (Keychain / Keystore)
  static const accessToken = 'access_token';
  static const refreshToken = 'refresh_token';

  /// Public guest/user id (`A0123`) is issued by the server on first launch.
  static const deviceId = 'device_id';
  static const deviceToken = 'device_token';
  static const installId = 'install_id';

  // Preferences
  /// Search phrases. Kept separate from the old destination-code history.
  static const recentQueries = 'recent_queries';

  /// Language sent as `Accept-Language`, kept in plain preferences so the Dio
  /// interceptor can read it without touching a bloc.
  static const contentLanguage = 'content_language';

  /// Invite code from a `waysim.co/r/CODE` link, prefilled at sign-up.
  static const pendingInvite = 'pending_invite';

  /// Settings toggles (docs/01-product-spec.md §6).
  static const notifyEsim = 'notify_esim';

  /// Set once the user has been asked for push permission (after the first
  /// purchase), so the prompt never repeats.
  static const pushPromptShown = 'push_prompt_shown';

  /// Set once the first-launch permission screens (notifications, then iOS
  /// tracking) have been shown.
  static const startupPermissionsShown = 'startup_permissions_shown';
}

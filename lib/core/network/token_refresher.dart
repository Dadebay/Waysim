/// How a refresh attempt ended.
enum RefreshOutcome {
  /// New tokens were obtained and saved; the failed request can be replayed.
  renewed,

  /// The server refused the refresh token (expired after 180 days, revoked,
  /// account blocked). The session is over: sign in again.
  rejected,

  /// The server could not be reached. The session is not over — keep it and
  /// let the original error surface.
  unavailable,
}

/// Exchanges the stored refresh token for a new token pair.
///
/// Implemented by the auth feature; [AuthInterceptor] only knows this
/// contract, so `core/` never imports a feature.
abstract interface class TokenRefresher {
  Future<RefreshOutcome> refresh();
}

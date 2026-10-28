enum RefreshOutcome { renewed, rejected, revoked, unavailable }

abstract interface class TokenRefresher {
  Future<RefreshOutcome> refresh();
}

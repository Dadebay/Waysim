/// Proof that a request comes from the genuine app on a real device
/// (Firebase App Check: App Attest on iOS, Play Integrity on Android).
abstract interface class AppAttestation {
  /// A fresh token, or `null` when attestation is unavailable.
  Future<String?> token();
}

class NoopAppAttestation implements AppAttestation {
  @override
  Future<String?> token() async => null;
}

abstract interface class AppAttestation {
  Future<String?> token();
}

class NoopAppAttestation implements AppAttestation {
  @override
  Future<String?> token() async => null;
}

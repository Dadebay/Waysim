import 'dart:async';

import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/esim/presentation/cubit/esim_list_cubit.dart';
import '../features/wallet/presentation/cubit/wallet_cubit.dart';

/// Keeps the data that depends on who is signed in in step with
/// [AuthCubit]: sign in loads balance and eSIMs, sign out clears them.
class SessionCoordinator {
  SessionCoordinator({required this._auth, required this._wallet, required this._esims});

  final AuthCubit _auth;
  final WalletCubit _wallet;
  final EsimListCubit _esims;
  StreamSubscription<AuthState>? _subscription;
  AuthStatus? _last;

  void start() {
    _apply(_auth.state.status);
    _subscription = _auth.stream.listen((s) => _apply(s.status));
  }

  void _apply(AuthStatus status) {
    if (status == _last) return;
    _last = status;
    switch (status) {
      case AuthStatus.signedIn:
        unawaited(_wallet.refresh());
        unawaited(_esims.load());
      case AuthStatus.guest:
        _wallet.clear();
        _esims.clear();
      case AuthStatus.unknown:
        break;
    }
  }

  Future<void> dispose() async => _subscription?.cancel();
}

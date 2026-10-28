import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/utils/result.dart';

enum AuthStatus { unknown, guest, signedIn }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.guestId,
    this.signedOutRemotely = false,
  });

  final AuthStatus status;
  final User? user;

  final String? guestId;
  final bool signedOutRemotely;

  bool get isSignedIn => status == AuthStatus.signedIn;

  String? get publicId => user?.publicId ?? guestId;

  @override
  List<Object?> get props => [status, user, guestId, signedOutRemotely];
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState());

  final AuthRepository _repository;
  bool _checkingSession = false;
  int _sessionRevision = 0;

  Future<void> revalidate() async {
    if (!state.isSignedIn || _checkingSession) return;
    _checkingSession = true;
    final revision = _sessionRevision;
    try {
      final result = await _repository.restore();
      if (isClosed || revision != _sessionRevision || !state.isSignedIn) return;
      if (result case Success(:final data)) {
        data == null ? sessionExpired() : userUpdated(data);
      }
    } finally {
      _checkingSession = false;
    }
  }

  Future<void> restore() async {
    final revision = _sessionRevision;
    final guest = (await _repository.guestId()).dataOrNull;
    final user = (await _repository.restore()).dataOrNull;
    if (isClosed || revision != _sessionRevision) return;
    emit(
      AuthState(
        status: user == null ? AuthStatus.guest : AuthStatus.signedIn,
        user: user,
        guestId: guest,
      ),
    );
  }

  void signedIn(User user) {
    _sessionRevision++;
    emit(
      AuthState(
        status: AuthStatus.signedIn,
        user: user,
        guestId: state.guestId,
      ),
    );
  }

  void userUpdated(User user) => signedIn(user);

  void clearSupportUnread() {
    final user = state.user;
    if (user == null) return;

    _sessionRevision++;
    if (user.supportUnread == 0) return;
    emit(
      AuthState(
        status: state.status,
        user: user.copyWith(supportUnread: 0),
        guestId: state.guestId,
      ),
    );
  }

  Future<void> signOut() async {
    await _repository.signOut();
    sessionExpired();
  }

  void sessionExpired({bool revoked = false}) {
    _sessionRevision++;
    emit(
      AuthState(
        status: AuthStatus.guest,
        guestId: state.guestId,
        signedOutRemotely: revoked || state.signedOutRemotely,
      ),
    );
  }
}

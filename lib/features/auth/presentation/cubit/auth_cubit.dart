import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/utils/result.dart';

enum AuthStatus {
  /// Not yet known; the session is being restored.
  unknown,
  guest,
  signedIn,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.guestId,
    this.signedOutRemotely = false,
  });

  final AuthStatus status;
  final User? user;

  /// `A0000`-style id every install has, signed in or not.
  final String? guestId;
  final bool signedOutRemotely;

  bool get isSignedIn => status == AuthStatus.signedIn;

  /// The id support asks for: the account's once signed in.
  String? get publicId => user?.publicId ?? guestId;

  @override
  List<Object?> get props => [status, user, guestId, signedOutRemotely];
}

/// Who is using the app. One instance for the whole app: the profile page,
/// every gated button and the HTTP layer read it.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState());

  final AuthRepository _repository;
  bool _checkingSession = false;
  int _sessionRevision = 0;

  /// Revalidate cached tabs without hiding content or logging out on network
  /// failures. The API interceptor handles rejected/revoked credentials.
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

  /// On launch: restore a stored session, otherwise a guest with an id.
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
    // An older /me response must not restore a badge after /support/read.
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

  /// The server ended the session (token refused, account blocked).
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

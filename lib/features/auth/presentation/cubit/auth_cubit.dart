import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthStatus {
  /// Not yet known; the session is being restored.
  unknown,
  guest,
  signedIn,
}

class AuthState extends Equatable {
  const AuthState({this.status = AuthStatus.unknown, this.user, this.guestId});

  final AuthStatus status;
  final User? user;

  /// `A0000`-style id every install has, signed in or not.
  final String? guestId;

  bool get isSignedIn => status == AuthStatus.signedIn;

  /// The id support asks for: the account's once signed in.
  String? get publicId => user?.publicId ?? guestId;

  @override
  List<Object?> get props => [status, user, guestId];
}

/// Who is using the app. One instance for the whole app: the profile page,
/// every gated button and the HTTP layer read it.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState());

  final AuthRepository _repository;

  /// On launch: restore a stored session, otherwise a guest with an id.
  Future<void> restore() async {
    final guest = (await _repository.guestId()).dataOrNull;
    final user = (await _repository.restore()).dataOrNull;
    emit(
      AuthState(
        status: user == null ? AuthStatus.guest : AuthStatus.signedIn,
        user: user,
        guestId: guest,
      ),
    );
  }

  void signedIn(User user) => emit(
    AuthState(status: AuthStatus.signedIn, user: user, guestId: state.guestId),
  );

  void userUpdated(User user) => signedIn(user);

  Future<void> signOut() async {
    await _repository.signOut();
    emit(AuthState(status: AuthStatus.guest, guestId: state.guestId));
  }

  /// The server ended the session (token refused, account blocked).
  void sessionExpired() =>
      emit(AuthState(status: AuthStatus.guest, guestId: state.guestId));
}

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_cubit.dart';

enum DeleteStep { warning, code, done }

class DeleteAccountState extends Equatable {
  const DeleteAccountState({
    this.step = DeleteStep.warning,
    this.loading = false,
    this.wrongCode = false,
    this.failure,
  });

  final DeleteStep step;
  final bool loading;
  final bool wrongCode;
  final Failure? failure;

  @override
  List<Object?> get props => [step, loading, wrongCode, failure];
}

/// Account deletion: read the consequences, confirm with an e-mailed code.
class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  DeleteAccountCubit(this._repository, this._auth)
    : super(const DeleteAccountState());

  final AuthRepository _repository;
  final AuthCubit _auth;

  /// "Continue" on the warning: send the code.
  Future<void> requestCode() async {
    emit(const DeleteAccountState(loading: true));
    final result = await _repository.requestDeletionCode();
    if (isClosed) return;
    switch (result) {
      case Success():
        emit(const DeleteAccountState(step: DeleteStep.code));
      case Error(:final failure):
        emit(DeleteAccountState(failure: failure));
    }
  }

  Future<void> confirm(String code) async {
    if (code.length != 6 || state.loading) return;
    emit(const DeleteAccountState(step: DeleteStep.code, loading: true));
    final result = await _repository.deleteAccount(code: code);
    if (isClosed) return;
    switch (result) {
      case Success():
        // Back to a guest: the repository already dropped the session.
        await _auth.signOut();
        emit(const DeleteAccountState(step: DeleteStep.done));
      case Error(:final failure):
        emit(
          DeleteAccountState(
            step: DeleteStep.code,
            wrongCode: failure.code == ApiCodes.otpInvalid,
            failure: failure.code == ApiCodes.otpInvalid ? null : failure,
          ),
        );
    }
  }
}

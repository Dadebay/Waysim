import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/utils/result.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_cubit.dart';

enum LoginStep { email, code, name, done }

enum LoginProblem { invalidEmail, notAccepted, wrongCode, codeExpired, tooMany }

class LoginState extends Equatable {
  const LoginState({
    this.step = LoginStep.email,
    this.email = '',
    this.loading = false,
    this.problem,
    this.failure,
    this.resendIn = 0,
    this.isNewUser = false,
  });

  final LoginStep step;
  final String email;
  final bool loading;

  /// A mistake the person can fix; shown next to the field.
  final LoginProblem? problem;

  /// A technical failure (network, server); shown as a banner.
  final Failure? failure;

  /// Seconds until "Send again" works.
  final int resendIn;
  final bool isNewUser;

  LoginState copyWith({
    LoginStep? step,
    String? email,
    bool? loading,
    LoginProblem? Function()? problem,
    Failure? Function()? failure,
    int? resendIn,
    bool? isNewUser,
  }) => LoginState(
    step: step ?? this.step,
    email: email ?? this.email,
    loading: loading ?? this.loading,
    problem: problem == null ? this.problem : problem(),
    failure: failure == null ? this.failure : failure(),
    resendIn: resendIn ?? this.resendIn,
    isNewUser: isNewUser ?? this.isNewUser,
  );

  @override
  List<Object?> get props => [
    step,
    email,
    loading,
    problem,
    failure,
    resendIn,
    isNewUser,
  ];
}

/// Passwordless sign-in: e-mail → 6-digit code → (new users) a name.
class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._repository, this._auth, this._analytics)
    : super(const LoginState());

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$');

  final AuthRepository _repository;
  final AuthCubit _auth;
  final AnalyticsService _analytics;
  Timer? _ticker;

  /// Step 1. [accepted] is the 18+ / terms checkbox.
  Future<void> submitEmail({
    required String email,
    required bool accepted,
    String? inviteCode,
  }) async {
    final trimmed = email.trim();
    if (!_emailPattern.hasMatch(trimmed)) {
      emit(state.copyWith(problem: () => LoginProblem.invalidEmail));
      return;
    }
    if (!accepted) {
      emit(state.copyWith(problem: () => LoginProblem.notAccepted));
      return;
    }
    emit(
      state.copyWith(
        loading: true,
        email: trimmed,
        problem: () => null,
        failure: () => null,
      ),
    );

    final invite = inviteCode?.trim();
    final result = await _repository.requestCode(
      email: trimmed,
      inviteCode: invite == null || invite.isEmpty ? null : invite,
    );
    if (isClosed) return;
    switch (result) {
      case Success():
        emit(state.copyWith(loading: false, step: LoginStep.code));
        _startCountdown();
      case Error(:final failure):
        emit(state.copyWith(loading: false, failure: () => failure));
    }
  }

  /// Step 2. Called when the sixth digit arrives.
  Future<void> submitCode(String code) async {
    if (code.length != 6 || state.loading) return;
    emit(
      state.copyWith(loading: true, problem: () => null, failure: () => null),
    );
    final result = await _repository.verifyCode(email: state.email, code: code);
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        _ticker?.cancel();
        _auth.signedIn(data.user);
        data.isNewUser ? _analytics.signedUp() : _analytics.loggedIn();
        emit(
          state.copyWith(
            loading: false,
            isNewUser: data.isNewUser,
            step: data.isNewUser ? LoginStep.name : LoginStep.done,
          ),
        );
      case Error(:final failure):
        emit(
          state.copyWith(
            loading: false,
            problem: () => switch (failure.code) {
              ApiCodes.otpInvalid => LoginProblem.wrongCode,
              ApiCodes.otpExpired => LoginProblem.codeExpired,
              ApiCodes.otpTooManyAttempts ||
              ApiCodes.otpRateLimited => LoginProblem.tooMany,
              _ => null,
            },
            failure: () => switch (failure.code) {
              ApiCodes.otpInvalid ||
              ApiCodes.otpExpired ||
              ApiCodes.otpTooManyAttempts ||
              ApiCodes.otpRateLimited => null,
              _ => failure,
            },
          ),
        );
    }
  }

  Future<void> resend() async {
    if (state.resendIn > 0 || state.loading) return;
    final result = await _repository.requestCode(email: state.email);
    if (isClosed) return;
    if (result.isSuccess) {
      emit(state.copyWith(problem: () => null, failure: () => null));
      _startCountdown();
    } else {
      emit(state.copyWith(failure: () => result.failureOrNull));
    }
  }

  /// The person started typing again: a stale "wrong code" no longer applies.
  void clearProblem() {
    if (state.problem != null) emit(state.copyWith(problem: () => null));
  }

  /// Back from the code step to change the address.
  void changeEmail() {
    _ticker?.cancel();
    emit(LoginState(email: state.email));
  }

  /// Step 3 (optional).
  Future<void> saveName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      emit(state.copyWith(step: LoginStep.done));
      return;
    }
    emit(state.copyWith(loading: true));
    final result = await _repository.updateName(trimmed);
    if (isClosed) return;
    if (result case Success(:final data)) _auth.userUpdated(data);
    // A failed name save must not block the sign-in that already happened.
    emit(state.copyWith(loading: false, step: LoginStep.done));
  }

  void skipName() => emit(state.copyWith(step: LoginStep.done));

  void _startCountdown() {
    _ticker?.cancel();
    emit(state.copyWith(resendIn: AppConstants.otpResend.inSeconds));
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      final left = state.resendIn - 1;
      if (left <= 0) t.cancel();
      if (!isClosed) emit(state.copyWith(resendIn: left < 0 ? 0 : left));
    });
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}

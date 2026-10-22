import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/utils/formatters/money.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/wallet_entities.dart';
import '../../domain/repositories/wallet_repository.dart';
import 'wallet_cubit.dart';

enum TopUpPhase {
  /// Choosing amount and method.
  form,

  /// Creating the payment on the server.
  creating,

  /// Paying: PayPal in the browser, or the crypto invoice on screen.
  paying,
  credited,
  expired,
  failed,
}

class TopUpState extends Equatable {
  const TopUpState({
    this.amount,
    this.method = TopUpMethod.paypal,
    this.crypto = CryptoOption.usdtTrc20,
    this.phase = TopUpPhase.form,
    this.session,
    this.progress = const TopUpProgress(TopUpStatus.waiting),
    this.failure,
    this.options,
    this.optionsLoading = false,
  });

  final WalletOptions? options;
  final bool optionsLoading;
  int get minCents =>
      method == TopUpMethod.crypto &&
          (crypto.minCents ?? 0) > (options?.minCents ?? 500)
      ? crypto.minCents!
      : (options?.minCents ?? 500);
  bool get canPay =>
      options != null &&
      options!.methods.contains(method) &&
      (method != TopUpMethod.crypto || options!.currencies.contains(crypto));
  final Money? amount;
  final TopUpMethod method;
  final CryptoOption crypto;
  final TopUpPhase phase;
  final TopUpSession? session;
  final TopUpProgress progress;
  final Failure? failure;

  TopUpState copyWith({
    WalletOptions? options,
    bool? optionsLoading,
    Money? Function()? amount,
    TopUpMethod? method,
    CryptoOption? crypto,
    TopUpPhase? phase,
    TopUpSession? session,
    TopUpProgress? progress,
    Failure? Function()? failure,
  }) => TopUpState(
    options: options ?? this.options,
    optionsLoading: optionsLoading ?? this.optionsLoading,
    amount: amount == null ? this.amount : amount(),
    method: method ?? this.method,
    crypto: crypto ?? this.crypto,
    phase: phase ?? this.phase,
    session: session ?? this.session,
    progress: progress ?? this.progress,
    failure: failure == null ? this.failure : failure(),
  );

  @override
  List<Object?> get props => [
    amount,
    options,
    optionsLoading,
    method,
    crypto,
    phase,
    session,
    progress,
    failure,
  ];
}

/// Tops up the balance: form → payment → credited. One screen, one cubit.
/// Polls the server while a payment is open; the server credits exactly once.
class TopUpCubit extends Cubit<TopUpState> {
  TopUpCubit({
    required this._repository,
    required this._wallet,
    required this._analytics,
    Money? initialAmount,
    this.pollInterval = const Duration(seconds: 10),
  }) : super(TopUpState(amount: initialAmount));

  final WalletRepository _repository;
  final WalletCubit _wallet;
  final AnalyticsService _analytics;
  final Duration pollInterval;

  Timer? _poll;
  bool _checking = false;
  bool _visible = true;
  String _key = const Uuid().v4();

  Future<void> initialize({String? paymentId}) async {
    if (state.optionsLoading) return;
    emit(state.copyWith(optionsLoading: true));
    final result = await _repository.options();
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        final method = data.methods.contains(state.method)
            ? state.method
            : (data.methods.firstOrNull ?? TopUpMethod.crypto);
        emit(
          state.copyWith(
            options: data,
            optionsLoading: false,
            method: method,
            crypto: data.currencies.firstOrNull ?? state.crypto,
            failure: () => null,
          ),
        );
        final pending = paymentId == null
            ? data.pending
            : (await _repository.payment(paymentId)).dataOrNull;
        if (isClosed) return;
        if (pending != null) _openSession(pending);
      case Error(:final failure):
        emit(state.copyWith(optionsLoading: false, failure: () => failure));
    }
  }

  void _openSession(TopUpSession session) {
    final selectedCrypto = state.options?.currencies
        .where(
          (option) =>
              option.coin == session.crypto?.coin &&
              option.network == session.crypto?.network,
        )
        .firstOrNull;
    emit(
      state.copyWith(
        amount: () => session.amount,
        session: session,
        method: session.method,
        crypto: selectedCrypto ?? state.crypto,
        phase: _phase(session.status),
        progress: TopUpProgress(
          session.status,
          creditedAmount: session.creditedAmount,
        ),
      ),
    );
    if (state.phase == TopUpPhase.paying) _startPolling(session.id);
  }

  TopUpPhase _phase(TopUpStatus status) => switch (status) {
    TopUpStatus.credited => TopUpPhase.credited,
    TopUpStatus.expired => TopUpPhase.expired,
    TopUpStatus.failed => TopUpPhase.failed,
    _ => TopUpPhase.paying,
  };

  void setVisible(bool visible) {
    _visible = visible;
    if (!visible) {
      _poll?.cancel();
      return;
    }
    final id = state.session?.id;
    if (id != null && state.phase == TopUpPhase.paying) {
      unawaited(checkNow());
      _startPolling(id);
    }
  }

  void setAmount(Money? amount) {
    _key = const Uuid().v4();
    emit(state.copyWith(amount: () => amount, failure: () => null));
  }

  void setMethod(TopUpMethod method) {
    _key = const Uuid().v4();
    emit(state.copyWith(method: method, failure: () => null));
  }

  void setCrypto(CryptoOption option) {
    _key = const Uuid().v4();
    emit(state.copyWith(crypto: option));
  }

  /// Opens the payment. [openUrl] is called with a PayPal checkout page, if
  /// the server gave one; the screen opens it in the in-app browser.
  Future<void> submit({Future<void> Function(Uri url)? openUrl}) async {
    if (state.phase != TopUpPhase.form || state.optionsLoading) return;
    if (state.options == null) await initialize();
    if (isClosed || state.phase != TopUpPhase.form) return;
    final amount = state.amount;
    if (amount == null ||
        !state.canPay ||
        amount.cents < state.minCents ||
        amount.cents > state.options!.maxCents) {
      return;
    }
    emit(state.copyWith(phase: TopUpPhase.creating, failure: () => null));

    final result = await _repository.createTopUp(
      amount: amount,
      method: state.method,
      idempotencyKey: _key,
      payCurrency: state.method == TopUpMethod.crypto
          ? state.crypto.code
          : null,
      coin: state.method == TopUpMethod.crypto ? state.crypto.coin : null,
      network: state.method == TopUpMethod.crypto ? state.crypto.network : null,
    );
    if (isClosed) return;

    switch (result) {
      case Success(:final data):
        _analytics.startedTopUp(method: state.method.name, amount: amount);
        _openSession(data);
        final url = data.checkoutUrl;
        if (url != null && url.scheme == 'https' && openUrl != null) {
          try {
            await openUrl(url);
          } on Object {
            /* Keep the invoice available for retry. */
          }
        }
      case Error(:final failure):
        emit(state.copyWith(phase: TopUpPhase.form, failure: () => failure));
    }
  }

  /// Asks the server now instead of waiting for the next tick — used when the
  /// app comes back from the PayPal browser or the customer's wallet app.
  Future<void> checkNow() async {
    final id = state.session?.id;
    if (id != null && state.phase == TopUpPhase.paying) await _check(id);
  }

  void _startPolling(String sessionId) {
    _poll?.cancel();
    if (_visible) {
      _poll = Timer.periodic(pollInterval, (_) => _check(sessionId));
    }
  }

  Future<void> _check(String sessionId) async {
    if (_checking || !_visible) return;
    _checking = true;
    final result = await _repository.topUpProgress(sessionId);
    _checking = false;
    if (isClosed) return;
    if (state.session?.id != sessionId || state.phase != TopUpPhase.paying) {
      return;
    }
    if (result case Success(:final data)) {
      switch (data.status) {
        case TopUpStatus.credited:
          _poll?.cancel();
          final credited = data.creditedAmount ?? state.session?.amount;
          if (credited != null) {
            _analytics.creditedTopUp(
              method: state.method.name,
              amount: credited,
            );
          }
          emit(state.copyWith(phase: TopUpPhase.credited, progress: data));
          // The server has the new balance; ask for it rather than adding
          // locally, so a repeated webhook can never show a double credit.
          unawaited(_wallet.refresh());
        case TopUpStatus.failed:
          _poll?.cancel();
          emit(state.copyWith(phase: TopUpPhase.failed, progress: data));
        case TopUpStatus.expired:
          _poll?.cancel();
          emit(state.copyWith(phase: TopUpPhase.expired, progress: data));
        case TopUpStatus.waiting ||
            TopUpStatus.confirming ||
            TopUpStatus.review:
          emit(state.copyWith(progress: data));
      }
    }
  }

  /// Leave an unpaid crypto invoice and choose another amount. The invoice
  /// remains open on the server until it expires; this only changes the UI.
  void chooseAnotherAmount() {
    if (state.phase != TopUpPhase.paying ||
        state.session?.crypto == null ||
        state.progress.status != TopUpStatus.waiting) {
      return;
    }
    reset();
  }

  /// A different coin or network needs a new server invoice and payment
  /// address. The previous unpaid invoice remains valid until its expiry.
  Future<void> changeCryptoInvoice(CryptoOption option) async {
    final session = state.session;
    final invoice = session?.crypto;
    final options = state.options;
    if (state.phase != TopUpPhase.paying ||
        state.progress.status != TopUpStatus.waiting ||
        session == null ||
        invoice == null ||
        options == null ||
        !options.currencies.contains(option) ||
        session.amount.cents < options.minCents ||
        session.amount.cents < (option.minCents ?? 0) ||
        (option.coin == invoice.coin && option.network == invoice.network)) {
      return;
    }
    reset();
    setAmount(session.amount);
    setCrypto(option);
    await submit();
  }

  /// Back to the form after an expired or failed payment.
  void reset() {
    _poll?.cancel();
    _key = const Uuid().v4();
    emit(
      TopUpState(
        amount: state.amount,
        method: state.method,
        crypto: state.crypto,
        options: state.options,
      ),
    );
  }

  @override
  Future<void> close() {
    _poll?.cancel();
    return super.close();
  }
}

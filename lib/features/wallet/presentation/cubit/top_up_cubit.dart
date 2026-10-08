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

/// A coin + network the customer can pay in.
class CryptoOption extends Equatable {
  const CryptoOption(this.coin, this.network);

  final String coin;
  final String network;

  static const usdtTrc20 = CryptoOption('USDT', 'TRC-20');

  String get label => '$coin · $network';

  @override
  List<Object?> get props => [coin, network];
}

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
  });

  final Money? amount;
  final TopUpMethod method;
  final CryptoOption crypto;
  final TopUpPhase phase;
  final TopUpSession? session;
  final TopUpProgress progress;
  final Failure? failure;

  TopUpState copyWith({
    Money? Function()? amount,
    TopUpMethod? method,
    CryptoOption? crypto,
    TopUpPhase? phase,
    TopUpSession? session,
    TopUpProgress? progress,
    Failure? Function()? failure,
  }) => TopUpState(
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
    required WalletRepository repository,
    required WalletCubit wallet,
    required AnalyticsService analytics,
    Money? initialAmount,
    this.pollInterval = const Duration(seconds: 2),
  }) : _repository = repository,
       _wallet = wallet,
       _analytics = analytics,
       super(TopUpState(amount: initialAmount));

  static const cryptoOptions = [
    CryptoOption.usdtTrc20,
    CryptoOption('USDT', 'ERC-20'),
    CryptoOption('USDC', 'ERC-20'),
  ];

  final WalletRepository _repository;
  final WalletCubit _wallet;
  final AnalyticsService _analytics;
  final Duration pollInterval;

  Timer? _poll;
  String _key = const Uuid().v4();

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
    final amount = state.amount;
    if (amount == null) return;
    emit(state.copyWith(phase: TopUpPhase.creating, failure: () => null));

    final result = await _repository.createTopUp(
      amount: amount,
      method: state.method,
      idempotencyKey: _key,
      coin: state.method == TopUpMethod.crypto ? state.crypto.coin : null,
      network: state.method == TopUpMethod.crypto ? state.crypto.network : null,
    );
    if (isClosed) return;

    switch (result) {
      case Success(:final data):
        _analytics.startedTopUp(method: state.method.name, amount: amount);
        emit(
          state.copyWith(
            phase: TopUpPhase.paying,
            session: data,
            progress: const TopUpProgress(TopUpStatus.waiting),
          ),
        );
        final url = data.checkoutUrl;
        if (url != null && openUrl != null) await openUrl(url);
        _startPolling(data.id);
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
    _poll = Timer.periodic(pollInterval, (_) => _check(sessionId));
  }

  Future<void> _check(String sessionId) async {
    final result = await _repository.topUpProgress(sessionId);
    if (isClosed) return;
    if (result case Success(:final data)) {
      switch (data.status) {
        case TopUpStatus.credited:
          _poll?.cancel();
          final credited = state.session?.amount;
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

  /// Back to the form after an expired or failed payment.
  void reset() {
    _poll?.cancel();
    _key = const Uuid().v4();
    emit(
      TopUpState(
        amount: state.amount,
        method: state.method,
        crypto: state.crypto,
      ),
    );
  }

  @override
  Future<void> close() {
    _poll?.cancel();
    return super.close();
  }
}

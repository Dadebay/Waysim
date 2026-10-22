import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/push_service.dart';
import '../../../../core/utils/formatters/money.dart';
import '../../../../core/utils/result.dart';
import '../../../catalog/domain/entities/esim_package.dart';
import '../../../esim/domain/entities/esim.dart';
import '../../../esim/presentation/cubit/esim_list_cubit.dart';
import '../../../wallet/presentation/cubit/wallet_cubit.dart';
import '../../domain/repositories/purchase_repository.dart';

enum PurchasePhase { processing, success, failed }

class PurchaseState extends Equatable {
  const PurchaseState({this.phase = PurchasePhase.processing, this.esim, this.failure, this.slow = false});

  final PurchasePhase phase;

  /// The new (or topped-up) eSIM on success.
  final Esim? esim;
  final Failure? failure;

  /// The order has taken longer than the 30 s we promised; the customer is
  /// told a notification will follow.
  final bool slow;

  /// New price from a `price-changed` conflict.
  Money? get newPrice {
    final cents = failure?.details?['newPriceCents'];
    return cents is int ? Money(cents) : null;
  }

  @override
  List<Object?> get props => [phase, esim, failure, slow];
}

/// Places one order (a new eSIM, or a package added to [esimId]) and tracks
/// it to the end. Sends only the package id and an idempotency key: a retry
/// after a dropped connection reuses the key, so it can never double-charge.
class PurchaseCubit extends Cubit<PurchaseState> {
  PurchaseCubit({required this._repository, required this._wallet, required this._esims, required this._pushGate, required this._analytics, required this.package, this.esimId})
    : super(const PurchaseState());

  final PurchaseRepository _repository;
  final WalletCubit _wallet;
  final EsimListCubit _esims;
  final PushPermissionGate _pushGate;
  final AnalyticsService _analytics;
  final EsimPackage package;
  final String? esimId;

  final String _key = const Uuid().v4();
  Timer? _slowTimer;
  bool _running = false;

  /// Starts (or retries, with the same key) the order.
  Future<void> run() async {
    if (_running || state.phase == PurchasePhase.success) return;
    _running = true;
    emit(const PurchaseState());
    _slowTimer?.cancel();
    _slowTimer = Timer(AppConstants.orderWaitLimit, () {
      if (!isClosed && state.phase == PurchasePhase.processing) {
        emit(const PurchaseState(slow: true));
      }
    });

    final id = esimId;
    final result = id == null
        ? await _repository.buy(packageId: package.id, idempotencyKey: _key, expectedPrice: package.price, days: package.purchaseDays, cancelled: () => isClosed)
        : await _repository.topUp(esimId: id, packageId: package.id, idempotencyKey: _key, expectedPrice: package.price, days: package.purchaseDays, cancelled: () => isClosed);
    _slowTimer?.cancel();
    _running = false;
    if (isClosed) return;

    switch (result) {
      case Success(:final data):
        _wallet.set(data.balanceAfter);
        _esims.replace(data.esim);
        _analytics.purchased(transactionId: data.esim.id, packageId: package.id, destination: package.destinationCode, price: package.price, addOn: esimId != null);
        emit(PurchaseState(phase: PurchasePhase.success, esim: data.esim));
        // The first purchase is the moment notifications become useful
        // ("your eSIM is ready"); ask once, here.
        unawaited(_pushGate.afterPurchase());
      case Error(:final failure):
        // A failed order may have been refunded; make the balance honest.
        unawaited(_wallet.refresh());
        _analytics.purchaseFailed(packageId: package.id, reason: failure.code);
        emit(PurchaseState(phase: PurchasePhase.failed, failure: failure));
    }
  }

  @override
  Future<void> close() {
    _slowTimer?.cancel();
    return super.close();
  }
}

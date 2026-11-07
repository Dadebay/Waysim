import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/push_service.dart';
import '../../../../core/utils/formatters/money.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/result.dart';
import '../../../catalog/domain/entities/esim_package.dart';
import '../../../esim/domain/entities/esim.dart';
import '../../../esim/presentation/cubit/esim_list_cubit.dart';
import '../../../wallet/presentation/cubit/wallet_cubit.dart';
import '../../domain/repositories/purchase_repository.dart';

enum PurchasePhase { processing, success, failed }

class PurchaseState extends Equatable {
  const PurchaseState({
    this.phase = PurchasePhase.processing,
    this.esim,
    this.failure,
    this.slow = false,
  });

  final PurchasePhase phase;

  final Esim? esim;
  final Failure? failure;

  final bool slow;

  Money? get newPrice {
    final cents = failure?.details?['newPriceCents'];
    return cents is int ? Money(cents) : null;
  }

  @override
  List<Object?> get props => [phase, esim, failure, slow];
}

class PurchaseCubit extends Cubit<PurchaseState> {
  PurchaseCubit({
    required this._repository,
    required this._wallet,
    required this._esims,
    required this._pushGate,
    required this._analytics,
    required this.package,
    this.esimId,
  }) : super(const PurchaseState());

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

  Future<void> run() async {
    if (_running || state.phase == PurchasePhase.success) return;
    _running = true;
    AppLogger.group(
      '[ORDER] Checkout started',
      lines: [
        'kind=${esimId == null ? 'purchase' : 'add-on'} '
            'packageId=${package.id} days=${package.purchaseDays ?? '-'}',
        'displayPriceCents=${package.price.cents} key=${_key.substring(0, 8)}',
      ],
      level: Level.info,
    );
    emit(const PurchaseState());
    _slowTimer?.cancel();
    _slowTimer = Timer(AppConstants.orderWaitLimit, () {
      if (!isClosed && state.phase == PurchasePhase.processing) {
        AppLogger.w(
          '[ORDER] Still processing after ${AppConstants.orderWaitLimit.inSeconds}s packageId=${package.id}',
        );
        emit(const PurchaseState(slow: true));
      }
    });

    final id = esimId;
    final result = id == null
        ? await _repository.buy(
            packageId: package.id,
            idempotencyKey: _key,
            expectedPrice: package.price,
            days: package.purchaseDays,
            cancelled: () => isClosed,
          )
        : await _repository.topUp(
            esimId: id,
            packageId: package.id,
            idempotencyKey: _key,
            expectedPrice: package.price,
            days: package.purchaseDays,
            cancelled: () => isClosed,
          );
    _slowTimer?.cancel();
    _running = false;
    if (isClosed) return;

    switch (result) {
      case Success(:final data):
        AppLogger.i(
          '[ORDER] Checkout completed packageId=${package.id} esimId=${data.esimId}',
        );
        final balance = data.balanceAfter;
        if (balance == null) {
          unawaited(_wallet.refresh());
        } else {
          _wallet.set(balance);
        }
        final esim =
            data.esim ??
            (data.esimId == null ? null : _esims.byId(data.esimId!));
        if (data.esim != null) _esims.replace(data.esim!);
        _analytics.purchased(
          transactionId: data.orderId,
          packageId: package.id,
          destination: package.destinationCode,
          price: data.charged,
          addOn: esimId != null,
        );
        emit(PurchaseState(phase: PurchasePhase.success, esim: esim));

        if (data.esim == null && data.esimId != null) {
          unawaited(_loadEsim(data.esimId!));
        }

        unawaited(_pushGate.afterPurchase());
      case Error(:final failure):
        AppLogger.group(
          '[ORDER] Checkout failed',
          lines: [
            'packageId=${package.id} code=${failure.code} http=${failure.statusCode ?? '-'}',
            if (failure.message != null) 'message=${failure.message}',
            if (failure.details?['reason'] != null)
              'reason=${failure.details!['reason']}',
            if (failure.details?['newPriceCents'] != null)
              'newPriceCents=${failure.details!['newPriceCents']}',
          ],
          level: Level.warning,
        );

        unawaited(_wallet.refresh());
        _analytics.purchaseFailed(packageId: package.id, reason: failure.code);
        emit(PurchaseState(phase: PurchasePhase.failed, failure: failure));
    }
  }

  Future<void> _loadEsim(String id) async {
    try {
      final result = await _esims.detail(id);
      if (isClosed || state.phase != PurchasePhase.success) return;
      if (result case Success(:final data)) {
        emit(PurchaseState(phase: PurchasePhase.success, esim: data));
      }
    } on Object catch (error) {
      AppLogger.w('[ORDER] eSIM refresh failed after completed order: $error');
    }
  }

  @override
  Future<void> close() {
    _slowTimer?.cancel();
    return super.close();
  }
}

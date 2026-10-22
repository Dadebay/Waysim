import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/formatters/money.dart';
import '../../../../core/utils/result.dart';
import '../../domain/repositories/wallet_repository.dart';

class WalletState extends Equatable {
  const WalletState({this.balance, this.loading = false});

  /// Null for a guest, or before the first answer.
  final Money? balance;
  final bool loading;

  @override
  List<Object?> get props => [balance, loading];
}

/// The signed-in customer's balance, shared by the Home header, Profile,
/// the purchase confirmation and the top-up screens.
class WalletCubit extends Cubit<WalletState> {
  WalletCubit(this._repository) : super(const WalletState());

  final WalletRepository _repository;
  int _generation = 0;

  Future<void> refresh() async {
    final generation = ++_generation;
    emit(WalletState(balance: state.balance, loading: true));
    final result = await _repository.balance();
    if (isClosed || generation != _generation) return;
    switch (result) {
      case Success(:final data):
        emit(WalletState(balance: data));
      case Error():
        // Keep the last known balance on a failed refresh.
        emit(WalletState(balance: state.balance));
    }
  }

  /// A purchase or top-up already told us the new balance.
  void set(Money balance) => emit(WalletState(balance: balance));

  void clear() {
    _generation++;
    emit(const WalletState());
  }
}

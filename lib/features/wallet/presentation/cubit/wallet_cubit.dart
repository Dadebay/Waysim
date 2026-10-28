import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/formatters/money.dart';
import '../../../../core/utils/result.dart';
import '../../domain/repositories/wallet_repository.dart';

class WalletState extends Equatable {
  const WalletState({this.balance, this.loading = false});

  final Money? balance;
  final bool loading;

  @override
  List<Object?> get props => [balance, loading];
}

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
        emit(WalletState(balance: state.balance));
    }
  }

  void set(Money balance) => emit(WalletState(balance: balance));

  void clear() {
    _generation++;
    emit(const WalletState());
  }
}

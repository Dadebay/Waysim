import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../error/failure.dart';
import '../utils/result.dart';

sealed class AsyncState<T> extends Equatable {
  const AsyncState();

  T? get dataOrNull => switch (this) {
    AsyncData<T>(:final data) => data,
    _ => null,
  };

  @override
  List<Object?> get props => [];
}

class AsyncLoading<T> extends AsyncState<T> {
  const AsyncLoading();
}

class AsyncData<T> extends AsyncState<T> {
  const AsyncData(this.data, {this.refreshing = false});

  final T data;

  final bool refreshing;

  @override
  List<Object?> get props => [data, refreshing];
}

class AsyncFailure<T> extends AsyncState<T> {
  const AsyncFailure(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

class AsyncCubit<T> extends Cubit<AsyncState<T>> {
  AsyncCubit(this._loader) : super(const AsyncLoading());

  final Future<Result<T>> Function() _loader;
  int _generation = 0;

  Future<void> load({bool silent = false}) async {
    final generation = ++_generation;
    final current = state;
    if (silent && current is AsyncData<T>) {
      emit(AsyncData(current.data, refreshing: true));
    } else {
      emit(const AsyncLoading());
    }

    final result = await _loader();
    if (isClosed || generation != _generation) return;
    switch (result) {
      case Success(:final data):
        emit(AsyncData(data));
      case Error(:final failure):
        if (silent && current is AsyncData<T>) {
          emit(AsyncData(current.data));
        } else {
          emit(AsyncFailure(failure));
        }
    }
  }

  void put(T data) {
    _generation++;
    if (!isClosed) emit(AsyncData(data));
  }
}

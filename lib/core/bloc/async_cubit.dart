import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../error/failure.dart';
import '../utils/result.dart';

/// Load-once state for a screen that shows one remote value.
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

  /// A reload is running behind the data already on screen.
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

/// A cubit that runs one loader and exposes loading / data / failure.
/// Orders, referral, legal documents, devices and top-up plans all use it.
class AsyncCubit<T> extends Cubit<AsyncState<T>> {
  AsyncCubit(this._loader) : super(const AsyncLoading());

  final Future<Result<T>> Function() _loader;
  int _generation = 0;

  /// Loads. With [silent] the current data stays on screen (pull-to-refresh);
  /// without it a failed first load shows the error view.
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
        // Keep showing what we had when a silent refresh fails.
        if (silent && current is AsyncData<T>) {
          emit(AsyncData(current.data));
        } else {
          emit(AsyncFailure(failure));
        }
    }
  }

  /// Replaces the data without a round trip (an eSIM just bought).
  void put(T data) {
    _generation++;
    if (!isClosed) emit(AsyncData(data));
  }
}

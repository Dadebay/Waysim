import '../error/failure.dart';

/// Lightweight `Either`-style return type — no extra dependency needed.
///
/// ```dart
/// final result = await repository.fetchProducts();
/// switch (result) {
///   case Success(:final data): emit(Loaded(data));
///   case Error(:final failure): emit(Failed(failure));
/// }
/// ```
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isError => this is Error<T>;

  T? get dataOrNull => switch (this) {
    Success<T>(:final data) => data,
    Error<T>() => null,
  };

  Failure? get failureOrNull => switch (this) {
    Success<T>() => null,
    Error<T>(:final failure) => failure,
  };

  R fold<R>(R Function(T data) onSuccess, R Function(Failure f) onError) =>
      switch (this) {
        Success<T>(:final data) => onSuccess(data),
        Error<T>(:final failure) => onError(failure),
      };

  Result<R> map<R>(R Function(T data) transform) => switch (this) {
    Success<T>(:final data) => Success(transform(data)),
    Error<T>(:final failure) => Error(failure),
  };
}

final class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

final class Error<T> extends Result<T> {
  const Error(this.failure);
  final Failure failure;
}

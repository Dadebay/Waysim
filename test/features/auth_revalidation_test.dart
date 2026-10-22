import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/core/error/failure.dart';
import 'package:waysim/core/utils/result.dart';
import 'package:waysim/features/auth/domain/entities/user.dart';
import 'package:waysim/features/auth/domain/repositories/auth_repository.dart';
import 'package:waysim/features/auth/presentation/cubit/auth_cubit.dart';

class _Repository implements AuthRepository {
  final response = Completer<Result<User?>>();
  int calls = 0;

  @override
  Future<Result<User?>> restore() {
    calls++;
    return response.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const user = User(publicId: 'A123', email: 'person@example.com');
  late _Repository repository;
  late AuthCubit cubit;
  setUp(() {
    repository = _Repository();
    cubit = AuthCubit(repository);
  });
  tearDown(() => cubit.close());

  test('guest navigation does not request an authenticated profile', () async {
    cubit.sessionExpired();
    await cubit.revalidate();
    expect(repository.calls, 0);
  });

  test('a removed session clears cached signed-in state', () async {
    cubit.signedIn(user);
    repository.response.complete(const Success(null));
    await cubit.revalidate();
    expect(cubit.state.status, AuthStatus.guest);
    expect(cubit.state.user, isNull);
  });

  test('network failure preserves the session', () async {
    cubit.signedIn(user);
    repository.response.complete(const Error(NetworkFailure()));
    await cubit.revalidate();
    expect(cubit.state.user, user);
    expect(cubit.state.isSignedIn, isTrue);
  });

  test('rapid tab changes share one pending check', () async {
    cubit.signedIn(user);
    final pending = cubit.revalidate();
    await cubit.revalidate();
    expect(repository.calls, 1);
    repository.response.complete(const Success(user));
    await pending;
    expect(cubit.state.user, user);
  });

  test('late response cannot overwrite a newer login', () async {
    cubit.signedIn(user);
    final pending = cubit.revalidate();
    const next = User(publicId: 'A456', email: 'new@example.com');
    cubit.signedIn(next);
    repository.response.complete(const Success(null));
    await pending;
    expect(cubit.state.user, next);
  });

  test('late profile response cannot restore a read support badge', () async {
    const withUnread = User(
      publicId: 'A123',
      email: 'person@example.com',
      supportUnread: 1,
    );
    cubit.signedIn(withUnread);
    final pending = cubit.revalidate();
    cubit.clearSupportUnread();
    repository.response.complete(const Success(withUnread));
    await pending;
    expect(cubit.state.user?.supportUnread, 0);
  });
}

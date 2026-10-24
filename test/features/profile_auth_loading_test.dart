import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/app/app.dart';
import 'package:waysim/core/di/injector.dart';
import 'package:waysim/features/auth/domain/entities/user.dart';
import 'package:waysim/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:waysim/features/catalog/presentation/cubit/catalog_cubit.dart';

import '../helpers/load_fonts.dart';
import '../helpers/test_dependencies.dart';

void main() {
  setUpAll(loadAppFonts);
  setUp(() async {
    await setUpTestDependencies();
    await getIt<CatalogCubit>().load();
  });

  testWidgets('profile shows loading until auth resolves as signed in', (
    tester,
  ) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile').last);
    await tester.pump(const Duration(milliseconds: 500));

    expect(getIt<AuthCubit>().state.status, AuthStatus.unknown);
    expect(find.byKey(const ValueKey('profile-auth-loading')), findsOneWidget);
    expect(find.byKey(const ValueKey('profile-guest-hero')), findsNothing);

    getIt<AuthCubit>().signedIn(
      const User(publicId: 'A123', email: 'person@example.com'),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('profile-auth-loading')), findsNothing);
    expect(find.byKey(const ValueKey('profile-account-menu')), findsOneWidget);
    expect(find.byKey(const ValueKey('profile-guest-hero')), findsNothing);

    await tester.pumpWidget(const SizedBox());
  });
}

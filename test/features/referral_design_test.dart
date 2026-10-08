import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/app/app.dart';
import 'package:waysim/app/cubit/locale_cubit.dart';
import 'package:waysim/app/session_coordinator.dart';
import 'package:waysim/core/di/injector.dart';
import 'package:waysim/core/theme/app_color_tokens.dart';
import 'package:waysim/core/utils/result.dart';
import 'package:waysim/features/auth/domain/repositories/auth_repository.dart';
import 'package:waysim/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:waysim/features/catalog/presentation/cubit/catalog_cubit.dart';
import 'package:waysim/features/referral/presentation/view/referral_page.dart';
import 'package:waysim/mock/mock_backend.dart';

import '../helpers/load_fonts.dart';
import '../helpers/test_dependencies.dart';

void main() {
  setUpAll(loadAppFonts);
  setUp(() async {
    await setUpTestDependencies(
      backend: MockBackend(
        latency: Duration.zero,
        purchaseLatency: Duration.zero,
      ),
    );
    await getIt<CatalogCubit>().load();
    final result = await getIt<AuthRepository>().verifyCode(
      email: 'anna@example.com',
      code: '123456',
    );
    getIt<AuthCubit>().signedIn((result as Success).data.user);
    getIt<SessionCoordinator>().start();
    getIt<LocaleCubit>().setLocale(const Locale('ru'));
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });

  testWidgets('referral page groups the PDF design sections on cards', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Профиль').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Пригласить друзей'));
    await tester.pumpAndSettle();

    final hero = tester.widget<Container>(
      find.byKey(const ValueKey('referral-hero')),
    );
    expect(
      (hero.decoration! as BoxDecoration).color,
      AppColorTokens.light.primary,
    );
    expect(find.text('WAY7K2Q'), findsOneWidget);
    expect(find.byKey(const ValueKey('referral-rules-card')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('referral-invites-card')),
      250,
      scrollable: find
          .descendant(
            of: find.byType(ReferralPage),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.byKey(const ValueKey('referral-invites-card')), findsOneWidget);
    expect(find.text('a***@gmail.com'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
  });
}

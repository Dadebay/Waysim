import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/app/app.dart';
import 'package:waysim/core/di/injector.dart';
import 'package:waysim/core/utils/formatters/money.dart';
import 'package:waysim/core/utils/result.dart';
import 'package:waysim/core/widgets/package_tile.dart';
import 'package:waysim/features/catalog/data/mock_catalog_repository.dart';
import 'package:waysim/features/catalog/domain/entities/esim_package.dart';
import 'package:waysim/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:waysim/features/catalog/presentation/cubit/catalog_cubit.dart';

import '../helpers/load_fonts.dart';
import '../helpers/test_dependencies.dart';

class _DailyCatalog extends MockCatalogRepository {
  _DailyCatalog()
    : super(latency: Duration.zero, destinationOfEsim: (_) => null);

  @override
  Future<Result<List<EsimPackage>>> packages(String destinationCode) async =>
      Success([
        EsimPackage(
          id: '${destinationCode}_daily',
          destinationCode: destinationCode,
          kind: PackageKind.unlimited,
          days: 1,
          price: const Money(99),
          dailyPrice: const Money(99),
          dailyBytes: 524288000,
          purchaseDays: 1,
          minPurchaseDays: 1,
          maxPurchaseDays: 3,
        ),
      ]);
}

void main() {
  setUpAll(loadAppFonts);

  setUp(() async {
    await setUpTestDependencies();
    getIt
      ..unregister<CatalogRepository>()
      ..registerSingleton<CatalogRepository>(_DailyCatalog());
    await getIt<CatalogCubit>().load();
  });

  testWidgets('one daily API plan stays one card while days change', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Where do you need an eSIM?'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'alb');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Albania'));
    await tester.pumpAndSettle();

    expect(find.byType(PackageTile), findsOneWidget);
    expect(
      tester.widget<PackageTile>(find.byType(PackageTile)).price,
      r'$0.99',
    );

    await tester.tap(find.byTooltip('2 days'));
    await tester.pumpAndSettle();
    expect(find.byType(PackageTile), findsOneWidget);
    expect(
      tester.widget<PackageTile>(find.byType(PackageTile)).selectedDays,
      2,
    );
    expect(
      tester.widget<PackageTile>(find.byType(PackageTile)).price,
      r'$1.98',
    );
    expect(find.text(r'Buy for $1.98'), findsOneWidget);

    await tester.tap(find.byTooltip('3 days'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<PackageTile>(find.byType(PackageTile)).selectedDays,
      3,
    );
    expect(
      tester.widget<PackageTile>(find.byType(PackageTile)).price,
      r'$2.97',
    );
    expect(find.text(r'Buy for $2.97'), findsOneWidget);
  });
}

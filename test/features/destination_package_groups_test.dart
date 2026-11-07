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

class _GroupedCatalog extends MockCatalogRepository {
  _GroupedCatalog()
    : super(latency: Duration.zero, destinationOfEsim: (_) => null);

  @override
  Future<Result<List<EsimPackage>>> packages(String destinationCode) async =>
      Success([
        for (var i = 0; i < 5; i++)
          EsimPackage(
            id: 'unlimited-$i',
            destinationCode: destinationCode,
            kind: PackageKind.unlimited,
            days: 1,
            price: Money(99 + i * 100),
            dailyBytes: 524288000,
          ),
        for (var i = 0; i < 9; i++)
          EsimPackage(
            id: 'limited-$i',
            destinationCode: destinationCode,
            kind: PackageKind.limited,
            days: 30,
            price: Money(199 + i * 100),
            volumeBytes: (i + 1) * 1073741824,
          ),
      ]);
}

void main() {
  setUpAll(loadAppFonts);

  setUp(() async {
    await setUpTestDependencies();
    getIt
      ..unregister<CatalogRepository>()
      ..registerSingleton<CatalogRepository>(_GroupedCatalog());
    await getIt<CatalogCubit>().load();
  });

  testWidgets('location shows both API groups and their plan counts', (
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

    expect(find.text('Unlimited (5)'), findsOneWidget);
    expect(find.text('Limited (9)'), findsOneWidget);
    expect(find.byType(PackageTile), findsNWidgets(9));

    await tester.tap(find.text('Unlimited (5)'));
    await tester.pumpAndSettle();
    expect(find.byType(PackageTile), findsNWidgets(5));
  });
}

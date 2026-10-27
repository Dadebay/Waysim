import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/app/app.dart';
import 'package:waysim/core/di/injector.dart';
import 'package:waysim/core/utils/formatters/money.dart';
import 'package:waysim/core/utils/result.dart';
import 'package:waysim/features/catalog/data/mock_catalog_repository.dart';
import 'package:waysim/features/catalog/domain/entities/esim_package.dart';
import 'package:waysim/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:waysim/features/catalog/presentation/cubit/catalog_cubit.dart';

import '../helpers/load_fonts.dart';
import '../helpers/test_dependencies.dart';

class _CoverageCatalog extends MockCatalogRepository {
  _CoverageCatalog()
    : super(latency: Duration.zero, destinationOfEsim: (_) => null);

  @override
  Future<Result<List<EsimPackage>>> packages(String destinationCode) async =>
      Success([
        const EsimPackage(
          id: 'global-1',
          destinationCode: 'GLOBAL',
          kind: PackageKind.limited,
          days: 30,
          price: Money(799),
          volumeBytes: 1073741824,
          coverage: ['XK', 'TR'],
          coverageNames: {'XK': 'Kosovo', 'TR': 'Türkiye'},
        ),
      ]);
}

void main() {
  setUpAll(loadAppFonts);
  setUp(() async {
    await setUpTestDependencies();
    getIt
      ..unregister<CatalogRepository>()
      ..registerSingleton<CatalogRepository>(_CoverageCatalog());
    await getIt<CatalogCubit>().load();
  });

  testWidgets('regional coverage opens country names from the API', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Where do you need an eSIM?'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'world');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Worldwide'));
    await tester.pumpAndSettle();

    expect(find.text('Countries covered (2)'), findsOneWidget);
    await tester.tap(find.text('Countries covered (2)'));
    await tester.pumpAndSettle();
    expect(find.text('Kosovo'), findsOneWidget);
    expect(find.text('Türkiye'), findsOneWidget);
  });
}

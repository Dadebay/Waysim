import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/app/app.dart';
import 'package:waysim/core/di/injector.dart';
import 'package:waysim/core/widgets/package_tile.dart';
import 'package:waysim/features/catalog/presentation/cubit/catalog_cubit.dart';

import '../helpers/load_fonts.dart';
import '../helpers/test_dependencies.dart';

void main() {
  setUpAll(loadAppFonts);

  setUp(() async {
    await setUpTestDependencies();
    await getIt<CatalogCubit>().load();
  });

  testWidgets('changing plans animates the card without delaying selection', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Where do you need an eSIM?'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'tur');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Türkiye'));
    await tester.pumpAndSettle();

    final tiles = find.byType(PackageTile);
    expect(tiles, findsAtLeastNWidgets(2));
    final first = tiles.first;
    final initialColor = _cardColor(tester, first);
    final price = tester.widget<PackageTile>(first).price;
    expect(tester.widget<PackageTile>(first).selected, isFalse);

    await tester.tap(first);
    await tester.pump();
    expect(tester.widget<PackageTile>(first).selected, isTrue);
    expect(find.text('Buy for $price'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 125));
    final middleColor = _cardColor(tester, first);
    await tester.pumpAndSettle();
    final finalColor = _cardColor(tester, first);

    expect(middleColor, isNot(initialColor));
    expect(middleColor, isNot(finalColor));
    expect(tester.takeException(), isNull);
  });
}

Color _cardColor(WidgetTester tester, Finder tile) => tester
    .widgetList<DecoratedBox>(
      find.descendant(of: tile, matching: find.byType(DecoratedBox)),
    )
    .map((box) => box.decoration)
    .whereType<BoxDecoration>()
    .firstWhere((decoration) => decoration.border != null)
    .color!;

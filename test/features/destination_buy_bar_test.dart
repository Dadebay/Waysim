import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/app/app.dart';
import 'package:waysim/core/di/injector.dart';
import 'package:waysim/features/catalog/presentation/cubit/catalog_cubit.dart';

import '../helpers/load_fonts.dart';
import '../helpers/test_dependencies.dart';

void main() {
  setUpAll(loadAppFonts);

  setUp(() async {
    await setUpTestDependencies();
    await getIt<CatalogCubit>().load();
  });

  testWidgets('buy bar stays compact until its info button is tapped', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 650 * 3);
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

    final details = find.byKey(const ValueKey('buy-bar-details'));
    final legal = find.byKey(const ValueKey('buy-bar-legal'));
    final bar = find.byKey(const ValueKey('destination-buy-bar'));
    final expandedHeight = tester.getSize(bar).height;
    expect(tester.getSize(details).height, greaterThan(0));
    expect(tester.getSize(legal).height, greaterThan(0));
    expect(find.text(r'Buy for $5.99'), findsOneWidget);

    final drag = await tester.startGesture(
      tester.getCenter(find.byType(ListView)),
    );
    await drag.moveBy(const Offset(0, -40));
    await tester.pump();
    await drag.moveBy(const Offset(0, -310));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    final closingHeight = tester.getSize(bar).height;
    await tester.pump(const Duration(milliseconds: 80));
    final middleHeight = tester.getSize(bar).height;
    await tester.pump(const Duration(milliseconds: 80));
    final lateHeight = tester.getSize(bar).height;
    await drag.up();
    await tester.pumpAndSettle();

    final compactHeight = tester.getSize(bar).height;
    expect(middleHeight, lessThan(closingHeight));
    expect(lateHeight, lessThan(middleHeight));
    expect(lateHeight, greaterThan(compactHeight));
    expect(closingHeight, greaterThan(compactHeight));
    expect(closingHeight, lessThan(expandedHeight));

    expect(tester.getSize(details).height, 0);
    expect(find.byTooltip('Package details'), findsOneWidget);
    expect(tester.getSize(legal).height, 0);
    expect(find.text(r'Buy for $5.99'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, 600));
    await tester.pumpAndSettle();

    expect(tester.getSize(details).height, 0);
    expect(find.text(r'Buy for $5.99'), findsOneWidget);

    await tester.tap(find.byTooltip('Package details'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));

    expect(tester.getSize(details).height, greaterThan(0));
    expect(tester.getSize(legal).height, greaterThan(0));

    await tester.pumpAndSettle();

    expect(tester.getSize(details).height, greaterThan(0));
    expect(tester.getSize(legal).height, greaterThan(0));
  });
}

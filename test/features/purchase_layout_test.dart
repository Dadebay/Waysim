import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/core/theme/app_theme.dart';
import 'package:waysim/features/catalog/data/mock/catalog_fixtures.dart';
import 'package:waysim/features/catalog/presentation/widgets/package_details_sheet.dart';
import 'package:waysim/features/purchase/presentation/purchase_subject.dart';
import 'package:waysim/features/purchase/presentation/view/purchase_page.dart';
import 'package:waysim/l10n/app_localizations.dart';
import 'package:waysim/mock/mock_backend.dart';

import '../helpers/load_fonts.dart';
import '../helpers/test_dependencies.dart';

void main() {
  setUpAll(loadAppFonts);
  setUp(() async {
    await setUpTestDependencies(
      backend: MockBackend(
        latency: Duration.zero,
        purchaseLatency: const Duration(seconds: 10),
      ),
    );
  });

  Future<void> phone(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  Widget app(Widget child) => MaterialApp(
    theme: AppTheme.light,
    locale: const Locale('en'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: child,
  );

  final plan = CatalogFixtures.packages(
    'TR',
  ).firstWhere((package) => package.id == 'TR_5_30');

  testWidgets('package details keep the purchase action near the last row', (
    tester,
  ) async {
    await phone(tester);
    await tester.pumpWidget(
      app(
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showPackageDetailsSheet(
                context,
                package: plan,
                destinationName: 'Türkiye',
                coverage: 'Türkiye',
                canBuy: true,
              ),
              child: const Text('Open details'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open details'));
    await tester.pumpAndSettle();

    final lastRow = find.text('Installation');
    final buyButton = find.text(r'Buy for $5.99');
    expect(lastRow, findsOneWidget);
    expect(buyButton, findsOneWidget);
    final gap =
        tester.getTopLeft(buyButton).dy - tester.getBottomLeft(lastRow).dy;
    expect(gap, lessThan(100));
    expect(tester.getBottomRight(buyButton).dy, lessThan(844));
    expect(tester.takeException(), isNull);
  });

  testWidgets('purchase loading indicator is centered horizontally', (
    tester,
  ) async {
    await phone(tester);

    await tester.pumpWidget(
      app(
        PurchasePage(
          subject: PurchaseSubject(
            package: plan,
            title: 'Türkiye',
            planLine: '5 GB · 30 days',
            flagCode: 'TR',
          ),
        ),
      ),
    );
    await tester.pump();

    final spinner = find.byType(CircularProgressIndicator);
    expect(spinner, findsOneWidget);
    expect(tester.getCenter(spinner).dx, closeTo(195, 1));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
  });
}

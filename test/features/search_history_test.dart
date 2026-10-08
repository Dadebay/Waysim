import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waysim/app/app.dart';
import 'package:waysim/core/di/injector.dart';
import 'package:waysim/core/storage/storage_keys.dart';
import 'package:waysim/features/catalog/presentation/cubit/catalog_cubit.dart';

import '../helpers/load_fonts.dart';
import '../helpers/test_dependencies.dart';

void main() {
  setUpAll(loadAppFonts);

  setUp(() async {
    await setUpTestDependencies();
    await getIt<CatalogCubit>().load();
  });

  testWidgets('a completed phrase can be repeated from recent searches', (
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
    expect(find.text('Türkiye'), findsOneWidget);
    final prefs = getIt<SharedPreferences>();
    expect(prefs.getStringList(StorageKeys.recentQueries), isNull);
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(prefs.getStringList(StorageKeys.recentQueries), ['tur']);

    await tester.enterText(find.byType(TextField), 'geo');
    await tester.pumpAndSettle();
    await tester.tap(find.text('tur'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      'tur',
    );
    expect(find.text('Türkiye'), findsOneWidget);
    expect(find.text('Georgia'), findsNothing);
  });
}

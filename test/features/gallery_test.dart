import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/core/theme/app_theme.dart';
import 'package:waysim/features/gallery/presentation/view/gallery_page.dart';
import 'package:waysim/l10n/app_localizations.dart';

import '../helpers/load_fonts.dart';

/// Builds the whole gallery (every component, light and dark) at phone width
/// in each language. Layout overflows surface as test failures.
void main() {
  setUpAll(loadAppFonts);

  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets('gallery lays out without overflow in ${locale.languageCode}', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 3, 9000 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const GalleryPage(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
      expect(find.text('LIGHT'), findsWidgets);
      expect(find.text('DARK'), findsWidgets);

      // Unmount so the carousel timer is cancelled before the test ends.
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('large system font does not overflow', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 12000 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.6)),
          child: child!,
        ),
        home: const GalleryPage(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}

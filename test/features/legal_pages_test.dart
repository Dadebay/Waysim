import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/core/di/injector.dart';
import 'package:waysim/core/theme/app_theme.dart';
import 'package:waysim/features/config/presentation/cubit/config_cubit.dart';
import 'package:waysim/features/legal/domain/entities/legal_document.dart';
import 'package:waysim/features/legal/presentation/view/legal_pages.dart';
import 'package:waysim/l10n/app_localizations.dart';

import '../helpers/load_fonts.dart';
import '../helpers/test_dependencies.dart';

Widget host(Widget page, {Locale locale = const Locale('en')}) => MaterialApp(
  theme: AppTheme.light,
  locale: locale,
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: BlocProvider.value(value: getIt<ConfigCubit>(), child: page),
);

void main() {
  setUpAll(loadAppFonts);
  setUp(setUpTestDependencies);

  const tableDocument = LegalDocument(
    id: 'privacy',
    title: 'Privacy Policy',
    markdown: true,
    body: r'''
## Data we collect

| Category | Examples | Source |
| --- | --- | --- |
| Account | **Email address**, name (optional), login method | You |
| Payments | Cryptocurrency, network, amount, transaction hash, sending wallet address | Our payment processor, public blockchain, you |

## Your rights

| Purpose | Contact |
| --- | --- |
| Access \| deletion | [Privacy support](mailto:support@waysim.co) |

We do not sell your personal data.
''',
  );

  for (final theme in [AppTheme.light, AppTheme.dark]) {
    testWidgets(
      'legal tables reflow on a narrow phone with large text (${theme.brightness})',
      (tester) async {
        tester.view.physicalSize = const Size(320, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
            home: const LegalDocumentPage(
              id: 'privacy',
              document: tableDocument,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(Table), findsNothing);
        expect(find.textContaining('Category'), findsNWidgets(2));
        expect(find.textContaining('Email address'), findsOneWidget);
        expect(find.textContaining('transaction hash'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.textContaining('Access | deletion'),
          400,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.textContaining('Access | deletion'), findsOneWidget);
        expect(find.textContaining('Privacy support'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('We do not sell your personal data.'),
          400,
          scrollable: find.byType(Scrollable).first,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('wide legal tables reflow when resized to a phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      host(const LegalDocumentPage(id: 'privacy', document: tableDocument)),
    );
    expect(find.byType(Table), findsNWidgets(2));
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();
    expect(find.byType(Table), findsNothing);
    expect(find.textContaining('transaction hash'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('More uses a bold title and two white cards', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      host(const LegalListPage(), locale: const Locale('ru')),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    final title = tester.widget<Text>(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Подробнее'),
      ),
    );
    expect(title.style?.fontSize, 20);
    expect(title.style?.fontWeight, FontWeight.w700);
    expect(tester.widget<AppBar>(find.byType(AppBar)).centerTitle, isTrue);
    expect(find.byKey(const ValueKey('more-document-links')), findsOneWidget);
    expect(find.byKey(const ValueKey('more-about-card')), findsOneWidget);
    expect(find.text('Политика возврата средств'), findsOneWidget);
    expect(find.text('Лицензии открытого ПО'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('More shows Contact us without a session or loaded config', (
    tester,
  ) async {
    await tester.pumpWidget(host(const LegalListPage()));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('more-contact-links')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Contact us'), findsOneWidget);
    expect(find.text('support@waysim.co'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('About the app opens a branded dialog and closes cleanly', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      host(const LegalListPage(), locale: const Locale('ru')),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('О приложении'));
    await tester.pumpAndSettle();

    final dialog = find.byKey(const ValueKey('about-app-dialog'));
    expect(dialog, findsOneWidget);

    final icon = find.descendant(
      of: dialog,
      matching: find.byKey(const ValueKey('about-app-icon')),
    );
    expect(icon, findsOneWidget);
    expect(tester.getSize(icon), const Size(128, 128));
    final image = tester.widget<Image>(
      find.descendant(of: icon, matching: find.byType(Image)),
    );
    expect((image.image as AssetImage).assetName, 'assets/brand/app_icon.png');
    expect(
      find.descendant(
        of: dialog,
        matching: find.text('Мобильный интернет в поездках'),
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(of: dialog, matching: find.text('Закрыть')),
    );
    await tester.pumpAndSettle();
    expect(dialog, findsNothing);
    expect(find.text('Подробнее'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a document opened from More shows its title in the AppBar', (
    tester,
  ) async {
    const doc = LegalDocument(
      id: 'terms',
      title: 'Terms of use',
      body: 'First paragraph.\n\nSecond paragraph.',
    );

    await tester.pumpWidget(
      host(const LegalDocumentPage(id: 'terms', document: doc)),
    );

    final title = tester.widget<Text>(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Terms of use'),
      ),
    );
    expect(title.style?.fontSize, 20);
    expect(title.style?.fontWeight, FontWeight.w700);
    expect(find.text('Terms of use'), findsOneWidget);
    expect(find.text('First paragraph.'), findsOneWidget);
  });

  testWidgets('General provisions uses the same bold AppBar title', (
    tester,
  ) async {
    const doc = LegalDocument(
      id: 'general',
      title: 'General provisions',
      body: 'Document body.',
    );
    await tester.pumpWidget(
      host(const LegalDocumentPage(id: 'general', document: doc)),
    );

    final title = tester.widget<Text>(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('General provisions'),
      ),
    );
    expect(title.style?.fontSize, 20);
    expect(title.style?.fontWeight, FontWeight.w700);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a document opened by link gets its title after loading', (
    tester,
  ) async {
    await tester.pumpWidget(host(const LegalDocumentPage(id: 'refund')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Refund policy'),
      ),
      findsOneWidget,
    );
    expect(find.text('Refund policy'), findsOneWidget);
  });
}

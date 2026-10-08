import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/app/app.dart';
import 'package:waysim/app/cubit/locale_cubit.dart';
import 'package:waysim/app/cubit/theme_cubit.dart';
import 'package:waysim/core/di/injector.dart';
import 'package:waysim/core/storage/local_storage.dart';
import 'package:waysim/core/theme/app_theme.dart';
import 'package:waysim/core/widgets/app_crossfade.dart';
import 'package:waysim/core/widgets/app_hero.dart';
import 'package:waysim/features/catalog/presentation/cubit/catalog_cubit.dart';
import 'package:waysim/features/catalog/presentation/view/destination_page.dart';
import 'package:waysim/features/home/presentation/view/home_page.dart';
import 'package:waysim/features/home/presentation/widgets/destination_list.dart';
import 'package:waysim/features/legal/presentation/view/legal_pages.dart';
import 'package:waysim/features/notification/presentation/cubit/notification_prefs_cubit.dart';
import 'package:waysim/features/profile/presentation/view/settings_page.dart';
import 'package:waysim/l10n/app_localizations.dart';

import '../helpers/load_fonts.dart';
import '../helpers/test_dependencies.dart';

void main() {
  setUpAll(loadAppFonts);

  setUp(() async {
    await setUpTestDependencies();
    await getIt<CatalogCubit>().load();
  });

  testWidgets('boots in English, light, on the Home tab', (tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.text('Hi!'), findsOneWidget);
    expect(find.text('Where do you need an eSIM?'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('My eSIM'), findsWidgets);
    expect(find.text('Profile'), findsOneWidget);
    expect(Theme.of(tester.element(find.text('Hi!'))).brightness, Brightness.light);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('tab pages get the screen above the tab bar', (tester) async {
    // Regression: a max-sized Column in the tab bar once took the whole
    // height and left every tab page 0 px tall.
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(HomePage)).height, greaterThan(400));

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Sign in to buy eSIMs').hitTestable(), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('destination flag has a matching Hero on its detail page', (tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    final row = find.byType(DestinationRow).first;
    final destination = tester.widget<DestinationRow>(row).destination;
    await tester.ensureVisible(row);
    await tester.pumpAndSettle();
    await tester.tap(row);
    await tester.pumpAndSettle();

    expect(find.byType(DestinationPage), findsOneWidget);
    expect(
      find.descendant(of: find.byType(DestinationPage), matching: find.byWidgetPredicate((widget) => widget is Hero && widget.tag == AppHeroTags.destinationFlag(destination.code))),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Profile, More, and document titles navigate with Heroes', (tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(find.byType(LegalListPage), findsOneWidget);

    await tester.tap(find.text('Terms of use'));
    await tester.pumpAndSettle();
    expect(find.byType(LegalDocumentPage), findsOneWidget);
    expect(find.descendant(of: find.byType(AppBar), matching: find.text('Terms of use')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Settings: language and theme apply immediately', (tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>.value(value: getIt<ThemeCubit>()),
          BlocProvider<LocaleCubit>.value(value: getIt<LocaleCubit>()),
          BlocProvider.value(value: getIt<NotificationPrefsCubit>()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) => BlocBuilder<LocaleCubit, Locale>(
            builder: (context, locale) => MaterialApp(
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeMode,
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              home: const SettingsPage(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    final title = tester.widget<Text>(find.text('Settings'));
    expect(title.style?.fontSize, 20);
    expect(title.style?.fontWeight, FontWeight.w700);

    await tester.tap(find.text('Русский'));
    await tester.pumpAndSettle();
    expect(find.text('Настройки'), findsOneWidget);
    expect(getIt<LocaleCubit>().state, const Locale('ru'));

    // The language cards push the theme section below the fold.
    await tester.scrollUntilVisible(find.text('Тёмная'), 200, scrollable: find.byType(Scrollable).first);
    // Built is not the same as on screen: bring it inside the viewport.
    await tester.ensureVisible(find.text('Тёмная'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Тёмная'));
    await tester.pumpAndSettle();
    expect(getIt<ThemeCubit>().state, ThemeMode.dark);
    expect(Theme.of(tester.element(find.text('Настройки'))).brightness, Brightness.dark);

    // The choice reaches plain preferences, where the Dio interceptor reads it.
    expect(getIt<LocalStorage>().getString('content_language'), 'ru');
  });

  testWidgets('app keeps the theme reveal over Settings during a theme change', (tester) async {
    final photo = (await tester.runAsync(() => createTestImage(width: 8, height: 8)))!;
    AppCrossfadeState.debugCapture = () async => photo;
    addTearDown(() => AppCrossfadeState.debugCapture = null);

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Dark'), 200, scrollable: find.byType(Scrollable).first);
    await tester.ensureVisible(find.text('Dark'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dark'));
    await tester.pump();
    await tester.pump();
    expect(getIt<ThemeCubit>().state, ThemeMode.dark);
    expect(find.byType(RawImage), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
    expect(find.byType(RawImage), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('theme still changes smoothly when no screenshot is available', (tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    final title = find.text('Hi!');
    final light = Theme.of(tester.element(title)).colorScheme.surface;

    getIt<ThemeCubit>().setThemeMode(ThemeMode.dark);
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final midway = Theme.of(tester.element(title)).colorScheme.surface;
    expect(midway, isNot(light));
    expect(midway, isNot(AppTheme.dark.colorScheme.surface));

    await tester.pumpAndSettle();
    expect(Theme.of(tester.element(title)).colorScheme.surface, AppTheme.dark.colorScheme.surface);
    await tester.pumpWidget(const SizedBox());
  });

  test('every supported locale is one of the five app languages', () {
    expect(LocaleCubit.supported.map((l) => l.languageCode).toSet(), {'en', 'zh', 'ru', 'es', 'fr'});
  });
}

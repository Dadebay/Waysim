import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/app/app.dart';
import 'package:waysim/core/constants/app_icons.dart';
import 'package:waysim/core/di/injector.dart';
import 'package:waysim/core/theme/app_theme.dart';
import 'package:waysim/core/widgets/promo_carousel.dart';
import 'package:waysim/core/widgets/skeleton.dart';
import 'package:waysim/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:waysim/features/catalog/presentation/cubit/catalog_cubit.dart';
import 'package:waysim/features/home/presentation/widgets/destination_list.dart';
import 'package:waysim/features/home/presentation/widgets/promo_banner.dart';
import 'package:waysim/features/home/presentation/widgets/sim_refresh_indicator.dart';
import 'package:waysim/features/catalog/presentation/widgets/search_field_box.dart';
import 'package:waysim/l10n/app_localizations.dart';

import '../helpers/load_fonts.dart';
import '../helpers/test_dependencies.dart';

void main() {
  setUpAll(loadAppFonts);

  group('PromoCarousel', () {
    testWidgets('a Home banner card stays 16:9 at phone width', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: PromoCarousel(
              aspectRatio: 16 / 9,
              children: [ColoredBox(color: Colors.blue)],
            ),
          ),
        ),
      );

      final pageSize = tester.getSize(find.byType(PageView));
      final cardWidth = pageSize.width * 0.93;
      expect(cardWidth / pageSize.height, closeTo(16 / 9, 0.001));
    });

    testWidgets('fallback copy fits a narrow 16:9 banner', (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: PromoCarousel(
              aspectRatio: 16 / 9,
              children: [
                PromoBanner(
                  title: 'What is eSIM?',
                  body: 'A digital SIM card: set up in minutes, no plastic',
                  action: 'How it works →',
                  icon: AppIcons.myEsim,
                  compact: true,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    Widget carousel() => MaterialApp(
      theme: AppTheme.light,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: PromoCarousel(
          // Long enough that a timer tick never lands on the boundary of a
          // test pump, which would fire it twice.
          interval: const Duration(seconds: 10),
          height: 120,
          children: [
            for (final n in [1, 2, 3]) Center(child: Text('Banner $n')),
          ],
        ),
      ),
    );

    double page(WidgetTester tester) =>
        tester.widget<PageView>(find.byType(PageView)).controller!.page!;

    testWidgets('after the last banner it keeps going forward to the first', (
      tester,
    ) async {
      await tester.pumpWidget(carousel());
      final start = page(tester);
      expect(find.text('Banner 1'), findsOneWidget);

      final visited = <String>[];
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(seconds: 10));
        await tester.pumpAndSettle(const Duration(milliseconds: 100));
        visited.add(
          [
            for (final n in [1, 2, 3])
              if ((tester.getCenter(find.text('Banner $n')).dx -
                          tester.getCenter(find.byType(Scaffold)).dx)
                      .abs() <
                  2)
                'Banner $n',
          ].single,
        );
      }

      // 1 → 2 → 3 → 1 → 2, always forward: the page index only ever grows.
      expect(visited, ['Banner 2', 'Banner 3', 'Banner 1', 'Banner 2']);
      expect(page(tester), start + 4);
    });

    testWidgets('a single banner does not loop or scroll', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: PromoCarousel(children: [Text('only')])),
        ),
      );
      await tester.pump(const Duration(seconds: 6));
      expect(find.text('only'), findsOneWidget);
    });

    testWidgets('removing an optional banner keeps the visible one', (
      tester,
    ) async {
      var showInvite = true;
      late StateSetter update;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return PromoCarousel(
                  interval: const Duration(days: 1),
                  height: 120,
                  children: [
                    const Text('First', key: ValueKey('first')),
                    if (showInvite)
                      const Text('Invite', key: ValueKey('invite')),
                    const Text('Travel', key: ValueKey('travel')),
                  ],
                );
              },
            ),
          ),
        ),
      );

      final controller = tester
          .widget<PageView>(find.byType(PageView))
          .controller!;
      controller.jumpToPage(controller.initialPage + 2);
      await tester.pump();
      expect(page(tester) % 3, 2);

      update(() => showInvite = false);
      await tester.pump();
      expect(
        tester.widget<PageView>(find.byType(PageView)).controller!.initialPage %
            2,
        1,
        reason: 'the replacement controller starts at Travel',
      );
      expect(page(tester) % 2, 1, reason: 'Travel stays visible');
    });

    testWidgets('adding an optional banner keeps its neighbour visible', (
      tester,
    ) async {
      var showInvite = false;
      late StateSetter update;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return PromoCarousel(
                  interval: const Duration(seconds: 10),
                  height: 120,
                  children: [
                    const Text('First', key: ValueKey('first')),
                    if (showInvite)
                      const Text('Invite', key: ValueKey('invite')),
                    const Text('Travel', key: ValueKey('travel')),
                  ],
                );
              },
            ),
          ),
        ),
      );

      final controller = tester
          .widget<PageView>(find.byType(PageView))
          .controller!;
      controller.jumpToPage(controller.initialPage + 1);
      await tester.pump();
      update(() => showInvite = true);
      await tester.pump();
      expect(page(tester) % 3, 2, reason: 'Travel stays visible');

      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();
      expect(page(tester) % 3, 0, reason: 'next is First, moving forward');
    });

    testWidgets(
      'removing the visible optional banner advances to its neighbour',
      (tester) async {
        var showInvite = true;
        late StateSetter update;
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  update = setState;
                  return PromoCarousel(
                    interval: const Duration(days: 1),
                    height: 120,
                    children: [
                      const Text('First', key: ValueKey('first')),
                      if (showInvite)
                        const Text('Invite', key: ValueKey('invite')),
                      const Text('Travel', key: ValueKey('travel')),
                    ],
                  );
                },
              ),
            ),
          ),
        );

        final controller = tester
            .widget<PageView>(find.byType(PageView))
            .controller!;
        controller.jumpToPage(controller.initialPage + 1);
        await tester.pump();
        update(() => showInvite = false);
        await tester.pump();
        expect(page(tester) % 2, 1, reason: 'Travel follows Invite');
      },
    );
  });

  group('Search field flight', () {
    setUp(() async {
      await setUpTestDependencies();
      await getIt<CatalogCubit>().load();
      await getIt<AuthCubit>().restore();
    });

    testWidgets('the search field stays pinned and still opens search', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      final search = find.byType(SearchFieldBox);
      final restingTop = tester.getTopLeft(search).dy;
      final scrollView = find.byType(CustomScrollView).first;

      await tester.drag(scrollView, const Offset(0, -500));
      await tester.pumpAndSettle();
      final pinnedTop = tester.getTopLeft(search).dy;
      expect(pinnedTop, lessThan(restingTop));

      await tester.drag(scrollView, const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(search).dy, closeTo(pinnedTop, 1));

      await tester.tap(search);
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('the box flies from Home into the app bar', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      final homeTop = tester.getTopLeft(find.byType(SearchFieldBox)).dy;

      await tester.tap(find.text('Where do you need an eSIM?'));
      await tester.pump(); // push starts
      await tester.pump(const Duration(milliseconds: 120)); // mid-flight

      // While it flies, a copy of the box sits somewhere between the two
      // ends: the Hero's overlay copy.
      final tops = [
        for (final e in find.byType(SearchFieldBox).evaluate())
          tester.getTopLeft(find.byWidget(e.widget)).dy,
      ];
      await tester.pumpAndSettle();
      final searchTop = tester.getTopLeft(find.byType(SearchFieldBox)).dy;

      expect(searchTop, lessThan(homeTop), reason: 'ends in the app bar');
      expect(
        tops.any((y) => y < homeTop - 1 && y > searchTop + 1),
        isTrue,
        reason:
            'a copy of the box is mid-way at 120 ms: $tops '
            '(home $homeTop → bar $searchTop)',
      );
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('the keyboard waits for the box to land', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Where do you need an eSIM?'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Mid-flight the keyboard is still down…
      expect(tester.testTextInput.isVisible, isFalse);

      // …and it comes up once the box has landed.
      await tester.pumpAndSettle();
      expect(tester.testTextInput.isVisible, isTrue);
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('Home refresh indicator', () {
    setUp(() async {
      await setUpTestDependencies();
      await getIt<AuthCubit>().restore();
    });

    testWidgets('shows an animated SIM instead of the default spinner', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.runAsync(() => getIt<CatalogCubit>().load());
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      expect(find.byType(SimRefreshIndicator), findsNothing);
      expect(find.byType(DestinationList), findsOneWidget);
      expect(find.byType(SkeletonList), findsNothing);

      final refresh = tester.state<RefreshIndicatorState>(
        find.byType(RefreshIndicator),
      );
      final refreshFuture = refresh.show();
      await tester.pump();
      expect(find.byType(SimRefreshIndicator), findsNothing);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump();
      expect(
        tester
            .widget<SimRefreshIndicator>(find.byType(SimRefreshIndicator))
            .active,
        isTrue,
      );
      expect(
        tester
            .widget<CircularProgressIndicator>(
              find.byKey(const ValueKey('sim-refresh-ring')),
            )
            .value,
        isNull,
      );
      expect(find.byType(RefreshProgressIndicator), findsNothing);
      expect(find.byType(SkeletonList), findsOneWidget);
      expect(find.byType(DestinationList), findsNothing);

      double verticalMotion() => tester
          .widget<Transform>(find.byKey(const ValueKey('sim-refresh-motion')))
          .transform
          .getTranslation()
          .y;
      final start = verticalMotion();
      await tester.pump(const Duration(milliseconds: 350));
      expect(verticalMotion(), isNot(start));

      await tester.pump(const Duration(seconds: 1));
      await refreshFuture;
      await tester.pumpAndSettle();
      expect(find.byType(SimRefreshIndicator), findsNothing);
      expect(find.byType(SkeletonList), findsNothing);
      expect(find.byType(DestinationList), findsOneWidget);

      await tester.drag(
        find.byType(CustomScrollView).first,
        const Offset(0, 300),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump();
      expect(find.byKey(const ValueKey('sim-refresh-ring')), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('initial catalog loading has no SIM animation', (tester) async {
      unawaited(getIt<CatalogCubit>().load());

      await tester.pumpWidget(const App());
      await tester.pump();
      expect(getIt<CatalogCubit>().state.status, CatalogStatus.loading);
      expect(find.byType(SimRefreshIndicator), findsNothing);

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(getIt<CatalogCubit>().state.status, CatalogStatus.loaded);
      expect(find.byType(SimRefreshIndicator), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('reduced motion keeps the SIM card still', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Scaffold(body: SimRefreshIndicator(active: true)),
          ),
        ),
      );

      double verticalMotion() => tester
          .widget<Transform>(find.byKey(const ValueKey('sim-refresh-motion')))
          .transform
          .getTranslation()
          .y;
      expect(verticalMotion(), 0);
      expect(
        tester
            .widget<CircularProgressIndicator>(
              find.byKey(const ValueKey('sim-refresh-ring')),
            )
            .value,
        0.75,
      );
      await tester.pump(const Duration(seconds: 2));
      expect(verticalMotion(), 0);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}

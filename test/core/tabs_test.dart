import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/app/view/widgets/app_tab_bar.dart';
import 'package:waysim/core/theme/app_theme.dart';
import 'package:waysim/core/widgets/segmented_tabs.dart';
import 'package:waysim/core/widgets/tab_switcher.dart';
import 'package:waysim/l10n/app_localizations.dart';

import '../helpers/load_fonts.dart';

Widget host(Widget child, {bool reduceMotion = false}) => MaterialApp(
  theme: AppTheme.light,
  locale: const Locale('en'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  builder: (context, app) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
    child: app!,
  ),
  home: Scaffold(
    body: Center(child: SizedBox(width: 300, child: child)),
  ),
);

void main() {
  setUpAll(loadAppFonts);

  group('SegmentedTabs', () {
    Widget tabs(int selected, ValueChanged<int> onChanged) => SegmentedTabs(
      labels: const ['Local', 'Regional'],
      selectedIndex: selected,
      onChanged: onChanged,
    );

    Alignment thumb(WidgetTester tester) =>
        tester.widget<AnimatedAlign>(find.byType(AnimatedAlign)).alignment
            as Alignment;

    testWidgets('the thumb sits under the selected segment and slides', (
      tester,
    ) async {
      var selected = 0;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) =>
                tabs(selected, (i) => setState(() => selected = i)),
          ),
        ),
      );
      expect(thumb(tester), Alignment.centerLeft);

      await tester.tap(find.text('Regional'));
      await tester.pump(const Duration(milliseconds: 100));

      final mid = thumb(tester);
      expect(mid.x, equals(1.0));
      await tester.pumpAndSettle();

      expect(selected, 1);
      expect(thumb(tester), Alignment.centerRight);
    });

    testWidgets('dragging across the control changes the segment', (
      tester,
    ) async {
      var selected = 0;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) =>
                tabs(selected, (i) => setState(() => selected = i)),
          ),
        ),
      );

      await tester.drag(find.text('Local'), const Offset(200, 0));
      await tester.pumpAndSettle();

      expect(selected, 1);
    });

    testWidgets('tapping the selected segment does nothing', (tester) async {
      var calls = 0;
      await tester.pumpWidget(host(tabs(0, (_) => calls++)));

      await tester.tap(find.text('Local'));
      await tester.pumpAndSettle();

      expect(calls, 0);
    });

    testWidgets('Reduce Motion: no animation, same result', (tester) async {
      var selected = 0;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) =>
                tabs(selected, (i) => setState(() => selected = i)),
          ),
          reduceMotion: true,
        ),
      );
      await tester.tap(find.text('Regional'));
      await tester.pump();
      await tester.pump();

      expect(thumb(tester), Alignment.centerRight);
    });
  });

  group('AppTabBar', () {
    testWidgets('selection changes without a dot', (tester) async {
      var index = 0;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) => AppTabBar(
              currentIndex: index,
              onSelected: (i) => setState(() => index = i),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AnimatedAlign), findsNothing);

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(index, 2);
      expect(find.byType(AnimatedAlign), findsNothing);
    });

    testWidgets('the selected tab is announced as selected', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(AppTabBar(currentIndex: 1, onSelected: (_) {})),
      );
      await tester.pumpAndSettle();

      final selected = [
        for (final label in ['Home', 'My eSIM', 'Profile'])
          if (tester
                  .getSemantics(find.bySemanticsLabel(label))
                  .getSemanticsData()
                  .flagsCollection
                  .isSelected ==
              Tristate.isTrue)
            label,
      ];
      expect(selected, ['My eSIM']);
      handle.dispose();
    });
  });

  group('TabSwitcher', () {
    Widget switcher(int index) =>
        TabSwitcher(index: index, child: Text('page $index'));

    testWidgets('old and new content cross over, then only the new stays', (
      tester,
    ) async {
      await tester.pumpWidget(host(switcher(0)));
      expect(find.text('page 0'), findsOneWidget);

      await tester.pumpWidget(host(switcher(1)));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('page 0'), findsOneWidget);
      expect(find.text('page 1'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('page 0'), findsNothing);
      expect(find.text('page 1'), findsOneWidget);
    });

    testWidgets('going right enters from the right, going left from the left', (
      tester,
    ) async {
      double dx(String text) => tester.getTopLeft(find.text(text)).dx;

      await tester.pumpWidget(host(switcher(0)));
      final rest = dx('page 0');

      await tester.pumpWidget(host(switcher(1)));
      await tester.pump(const Duration(milliseconds: 20));
      expect(dx('page 1'), greaterThan(rest));
      expect(dx('page 0'), lessThan(rest + 0.01));
      await tester.pumpAndSettle();

      await tester.pumpWidget(host(switcher(0)));
      await tester.pump(const Duration(milliseconds: 20));
      expect(dx('page 0'), lessThan(rest + 24));
      expect(dx('page 1'), greaterThan(rest - 0.01));
      await tester.pumpAndSettle();
    });

    testWidgets('Reduce Motion swaps at once', (tester) async {
      await tester.pumpWidget(host(switcher(0), reduceMotion: true));
      await tester.pumpWidget(host(switcher(1), reduceMotion: true));
      await tester.pump();
      await tester.pump();

      expect(find.text('page 0'), findsNothing);
      expect(find.text('page 1'), findsOneWidget);
    });
  });
}

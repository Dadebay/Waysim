import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/app/view/connection_gate.dart';
import 'package:waysim/core/theme/app_theme.dart';
import 'package:waysim/core/widgets/no_connection_art.dart';
import 'package:waysim/l10n/app_localizations.dart';

import '../helpers/load_fonts.dart';
import '../helpers/test_dependencies.dart';

Widget host(FakeNetworkInfo network, {Locale locale = const Locale('en')}) =>
    MaterialApp(
      theme: AppTheme.light,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: ConnectionGate(
        networkInfo: network,
        child: const Scaffold(body: Center(child: Text('the app'))),
      ),
    );

void main() {
  setUpAll(loadAppFonts);

  const offlineScreen = ValueKey('connection-offline-screen');

  testWidgets('online: the app shows straight away', (tester) async {
    await tester.pumpWidget(host(FakeNetworkInfo()));
    await tester.pumpAndSettle();

    expect(find.text('the app'), findsOneWidget);
    expect(find.byKey(offlineScreen), findsNothing);
  });

  testWidgets('offline: shows the no-connection screen, not the app', (
    tester,
  ) async {
    await tester.pumpWidget(host(FakeNetworkInfo(connected: false)));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byKey(offlineScreen), findsOneWidget);
    expect(find.byType(NoConnectionArt), findsOneWidget);
    expect(find.text("You're offline"), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.text('Continue offline'), findsOneWidget);
    expect(find.text('the app'), findsNothing);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('moves on by itself when the connection comes back', (
    tester,
  ) async {
    final network = FakeNetworkInfo(connected: false);
    await tester.pumpWidget(host(network));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byKey(offlineScreen), findsOneWidget);

    network.set(true);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('the app'), findsOneWidget);
    expect(find.byKey(offlineScreen), findsNothing);
  });

  testWidgets('Try again stays on the screen while still offline', (
    tester,
  ) async {
    await tester.pumpWidget(host(FakeNetworkInfo(connected: false)));
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('Try again'));
    await tester.pump();

    await tester.pump(const Duration(seconds: 2));

    expect(find.byKey(offlineScreen), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Try again lets the app in once the network is back', (
    tester,
  ) async {
    final network = FakeNetworkInfo(connected: false);
    await tester.pumpWidget(host(network));
    await tester.pump(const Duration(seconds: 1));

    network.connected = true;
    await tester.tap(find.text('Try again'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('the app'), findsOneWidget);
  });

  testWidgets('Continue offline opens the app anyway', (tester) async {
    await tester.pumpWidget(host(FakeNetworkInfo(connected: false)));
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('Continue offline'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('the app'), findsOneWidget);
  });

  testWidgets('reads in every language without overflow', (tester) async {
    tester.view.physicalSize = const Size(320 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    for (final code in ['en', 'ru', 'zh', 'es', 'fr']) {
      await tester.pumpWidget(
        host(FakeNetworkInfo(connected: false), locale: Locale(code)),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byKey(offlineScreen), findsOneWidget, reason: code);
      expect(tester.takeException(), isNull, reason: code);
    }
    await tester.pumpWidget(const SizedBox());
  });
}

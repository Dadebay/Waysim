import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/core/di/injector.dart';
import 'package:waysim/core/theme/app_theme.dart';
import 'package:waysim/core/utils/result.dart';
import 'package:waysim/core/widgets/tab_switcher.dart';
import 'package:waysim/features/wallet/domain/entities/wallet_entities.dart';
import 'package:waysim/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:waysim/features/wallet/presentation/view/orders_page.dart';
import 'package:waysim/l10n/app_localizations.dart';

import '../helpers/load_fonts.dart';
import '../helpers/test_dependencies.dart';

class _Wallet implements WalletRepository {
  int ledgerCalls = 0;

  @override
  Future<Result<List<Map<String, dynamic>>>> ledger() async {
    ledgerCalls++;
    return const Success([
      {
        'id': 'credit',
        'title': 'Referral bonus',
        'amountCents': 350,
        'createdAt': '2026-10-21T09:00:00Z',
      },
      {
        'id': 'debit',
        'title': 'eSIM purchase',
        'amountCents': -100,
        'createdAt': '2026-10-21T10:00:00Z',
      },
    ]);
  }

  @override
  Future<Result<List<WalletOrder>>> orders(OrderType type) async =>
      const Success([]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(loadAppFonts);
  setUp(setUpTestDependencies);

  testWidgets('Activity tab loads signed wallet ledger on demand', (
    tester,
  ) async {
    final wallet = _Wallet();
    getIt
      ..unregister<WalletRepository>()
      ..registerSingleton<WalletRepository>(wallet);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const OrdersPage(),
      ),
    );
    await tester.pumpAndSettle();
    expect(wallet.ledgerCalls, 0);

    await tester.tap(find.text('Activity'));
    await tester.pumpAndSettle();
    expect(wallet.ledgerCalls, 1);
    expect(find.text('Referral bonus'), findsOneWidget);
    expect(find.text('+\$3.50'), findsOneWidget);
    expect(find.text('-\$1.00'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('each empty orders tab shows its illustration', (tester) async {
    final wallet = _EmptyWallet();
    getIt
      ..unregister<WalletRepository>()
      ..registerSingleton<WalletRepository>(wallet);

    Widget app(ThemeMode mode) => MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: mode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const OrdersPage(),
    );

    String illustration() =>
        (tester
                    .widget<Image>(
                      find.byKey(const ValueKey('orders-empty-illustration')),
                    )
                    .image
                as AssetImage)
            .assetName;

    void expectExtraBottomPadding() {
      final tabArea = find.byType(TabSwitcher);
      final content = find.byKey(const ValueKey('orders-empty-content'));
      final tabCenter = tester.getCenter(tabArea).dy;
      final contentCenter = tester.getCenter(content).dy;
      expect(
        contentCenter,
        closeTo(tabCenter - tester.getSize(tabArea).height * 0.05, 1),
      );
    }

    await tester.pumpWidget(app(ThemeMode.light));
    await tester.pumpAndSettle();
    expect(illustration(), endsWith('orders_empty_purchases.png'));
    expectExtraBottomPadding();

    await tester.tap(find.text('Top-ups'));
    await tester.pumpAndSettle();
    expect(illustration(), endsWith('orders_empty_topups.png'));
    expectExtraBottomPadding();

    await tester.tap(find.text('Activity'));
    await tester.pumpAndSettle();
    expect(illustration(), endsWith('orders_empty_activity.png'));
    expectExtraBottomPadding();

    await tester.pumpWidget(app(ThemeMode.dark));
    await tester.pumpAndSettle();
    expect(illustration(), endsWith('orders_empty_activity.png'));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
  });
}

class _EmptyWallet extends _Wallet {
  @override
  Future<Result<List<Map<String, dynamic>>>> ledger() async =>
      const Success([]);
}

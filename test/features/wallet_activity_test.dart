import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:waysim/core/di/injector.dart';
import 'package:waysim/core/theme/app_theme.dart';
import 'package:waysim/core/utils/formatters/money.dart';
import 'package:waysim/core/utils/result.dart';
import 'package:waysim/core/widgets/tab_switcher.dart';
import 'package:waysim/features/wallet/domain/entities/wallet_entities.dart';
import 'package:waysim/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:waysim/features/wallet/presentation/view/orders_page.dart';
import 'package:waysim/features/wallet/presentation/view/order_activity_detail_page.dart';
import 'package:waysim/features/wallet/presentation/view/payment_detail_page.dart';
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

  testWidgets('a top-up opens its current payment details by public number', (
    tester,
  ) async {
    final wallet = _PaymentWallet();
    getIt
      ..unregister<WalletRepository>()
      ..registerSingleton<WalletRepository>(wallet);
    final router = GoRouter(
      initialLocation: '/orders',
      routes: [
        GoRoute(path: '/orders', builder: (_, _) => const OrdersPage()),
        GoRoute(
          path: '/payments/:id',
          builder: (_, state) =>
              PaymentDetailPage(id: state.pathParameters['id']!),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Top-ups'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('58008').first);
    await tester.pumpAndSettle();

    expect(wallet.paymentIds, ['58008']);
    expect(find.text('Payment details'), findsOneWidget);
    expect(find.text('4.99 USDT'), findsOneWidget);
    expect(find.text('1.02803431 USDT'), findsOneWidget);
    expect(find.text('Payment fee'), findsOneWidget);
    expect(find.text(r'$0.03'), findsOneWidget);
    expect(find.text('Payment under review'), findsOneWidget);
    expect(find.textContaining('received more than requested'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('purchase and activity rows open their own details', (
    tester,
  ) async {
    final wallet = _DetailWallet();
    getIt
      ..unregister<WalletRepository>()
      ..registerSingleton<WalletRepository>(wallet);
    final router = GoRouter(
      initialLocation: '/orders',
      routes: [
        GoRoute(path: '/orders', builder: (_, _) => const OrdersPage()),
        GoRoute(
          path: '/orders/:id',
          builder: (_, state) =>
              OrderDetailPage(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/activity/:id',
          builder: (_, state) => ActivityDetailPage(
            id: state.pathParameters['id']!,
            initialEntry: state.extra as Map<String, dynamic>?,
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('10234').first);
    await tester.pumpAndSettle();

    expect(wallet.orderIds, ['order-uuid']);
    expect(find.text('Order details'), findsOneWidget);
    expect(find.text('Türkiye 5 GB'), findsOneWidget);
    expect(find.text('TR_5_30'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Activity'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Referral bonus'));
    await tester.pumpAndSettle();

    expect(find.text('Activity details'), findsOneWidget);
    expect(find.text('Balance after'), findsOneWidget);
    expect(find.text(r'$27.00'), findsOneWidget);
    expect(find.text('Welcome reward'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}

class _DetailWallet extends _Wallet {
  final orderIds = <String>[];

  @override
  Future<Result<List<WalletOrder>>> orders(OrderType type) async =>
      type == OrderType.purchase
      ? Success([
          WalletOrder(
            id: 'order-uuid',
            number: '10234',
            type: OrderType.purchase,
            outcome: OrderOutcome.completed,
            amount: const Money(599),
            createdAt: DateTime.utc(2026, 10, 22),
            destinationNames: const {'en': 'Türkiye'},
            serverTitle: 'Türkiye 5 GB',
          ),
        ])
      : const Success([]);

  @override
  Future<Result<WalletOrder>> order(String id) async {
    orderIds.add(id);
    return Success(
      WalletOrder(
        id: id,
        number: '10234',
        type: OrderType.purchase,
        outcome: OrderOutcome.completed,
        amount: const Money(599),
        createdAt: DateTime.utc(2026, 10, 22),
        destinationNames: const {'en': 'Türkiye'},
        serverTitle: 'Türkiye 5 GB',
        slug: 'TR_5_30',
      ),
    );
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> ledger() async => const Success([
    {
      'id': 'ledger-1',
      'kind': 'referral_bonus',
      'title': 'Referral bonus',
      'note': 'Welcome reward',
      'amountCents': 350,
      'balanceAfterCents': 2700,
      'createdAt': '2026-10-22T10:00:00Z',
    },
  ]);
}

class _PaymentWallet extends _Wallet {
  final paymentIds = <String>[];

  @override
  Future<Result<List<WalletOrder>>> orders(OrderType type) async =>
      type == OrderType.topUp
      ? Success([
          WalletOrder(
            number: '58008',
            type: OrderType.topUp,
            outcome: OrderOutcome.review,
            amount: const Money(100),
            createdAt: DateTime.utc(2026, 10, 22),
            destinationNames: const {},
            method: TopUpMethod.crypto,
          ),
        ])
      : const Success([]);

  @override
  Future<Result<TopUpSession>> payment(String id) async {
    paymentIds.add(id);
    return Success(
      TopUpSession(
        id: 'payment-id',
        publicNo: 58008,
        method: TopUpMethod.crypto,
        amount: const Money(100),
        rawStatus: 'review_overpaid',
        status: TopUpStatus.review,
        crypto: CryptoInvoice(
          coin: 'USDT',
          network: 'BEP-20',
          address: 'payment-address',
          amountText: '1.02803431',
          paidAmountText: '4.99',
          feeCents: 3,
          totalCents: 103,
          providerStatus: 'finished',
          rateText: '1 USDT = \$1.00',
          expiresAt: DateTime.utc(2026, 10, 23),
          requiredConfirmations: 0,
        ),
      ),
    );
  }
}

class _EmptyWallet extends _Wallet {
  @override
  Future<Result<List<Map<String, dynamic>>>> ledger() async =>
      const Success([]);
}

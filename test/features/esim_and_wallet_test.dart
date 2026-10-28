import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:waysim/app/app.dart';
import 'package:waysim/app/session_coordinator.dart';
import 'package:waysim/core/di/injector.dart';
import 'package:waysim/core/constants/app_icons.dart';
import 'package:waysim/core/services/esim_compatibility.dart';
import 'package:waysim/core/utils/result.dart';
import 'package:waysim/core/widgets/app_bottom_sheet.dart';
import 'package:waysim/core/widgets/copy_field.dart';
import 'package:waysim/features/auth/domain/repositories/auth_repository.dart';
import 'package:waysim/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:waysim/features/catalog/presentation/cubit/catalog_cubit.dart';
import 'package:waysim/features/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:waysim/features/wallet/presentation/cubit/top_up_cubit.dart';
import 'package:waysim/mock/mock_backend.dart';

import '../helpers/load_fonts.dart';
import '../helpers/test_dependencies.dart';

void main() {
  setUpAll(loadAppFonts);

  void phone(WidgetTester tester) {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  /// Signs the demo customer in without going through the screens.
  Future<void> signInAnna(WidgetTester tester) async {
    await tester.runAsync(() async {
      // The mock server reads the test's fake clock, so "PayPal confirms
      // after 3 s" is a matter of pumping time.
      await setUpTestDependencies(
        backend: MockBackend(
          now: () => tester.binding.clock.now(),
          latency: Duration.zero,
          purchaseLatency: Duration.zero,
        ),
      );
      await getIt<CatalogCubit>().load();
      final result = await getIt<AuthRepository>().verifyCode(
        email: 'anna@example.com',
        code: '123456',
      );
      getIt<AuthCubit>().signedIn((result as Success).data.user);
      getIt<SessionCoordinator>().start();
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
  }

  testWidgets('My eSIM lists current eSIMs and archives the spent ones', (
    tester,
  ) async {
    phone(tester);
    await signInAnna(tester);
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    await tester.tap(find.text('My eSIM').last);
    await tester.pumpAndSettle();

    expect(find.text('Türkiye'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('3.2 GB of 5 GB left'), findsOneWidget);
    expect(find.textContaining('iPhone 15'), findsNothing);
    expect(find.textContaining('Updated'), findsOneWidget);
    // Not installed: offers the install button.
    expect(find.text('Install'), findsOneWidget);
    expect(find.text('Installed'), findsOneWidget);
    // Spent and expired ones are not in the current list…
    expect(find.text('Thailand'), findsNothing);

    // …but in the archive.
    await tester.tap(find.text('Archive'));
    await tester.pumpAndSettle();
    expect(find.text('Thailand'), findsOneWidget);
    expect(find.text('Japan'), findsOneWidget);
    expect(find.text('Expired'), findsOneWidget);
    expect(find.text('Used up'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('an eSIM page shows the QR code and the manual details', (
    tester,
  ) async {
    phone(tester);
    await signInAnna(tester);
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    await tester.tap(find.text('My eSIM').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Türkiye'));
    await tester.pumpAndSettle();

    expect(find.text('eSIM details'), findsOneWidget);
    expect(find.byType(QrImageView), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('SM-DP+ address'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('smdp.example.com'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('esim-full-activation-code')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    final fullCode = tester.widget<CopyField>(
      find.byKey(const ValueKey('esim-full-activation-code')),
    );
    expect(find.text('Full activation code'), findsOneWidget);
    expect(fullCode.value, startsWith('LPA:1\$'));
    final activationCode = tester
        .widgetList<CopyField>(find.byType(CopyField))
        .firstWhere((field) => field.label == 'Activation code')
        .value;
    expect(fullCode.value, 'LPA:1\$smdp.example.com\$$activationCode');
    expect(
      fullCode.copyValue,
      isNull,
      reason: 'CopyField copies its displayed value',
    );
    expect(
      find.textContaining('Enter activation code manually'),
      findsOneWidget,
    );
    expect(
      find.textContaining('leave Confirmation Code empty'),
      findsOneWidget,
    );
    expect(find.textContaining('connects when you arrive'), findsNothing);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('one-tap install explains it connects only on arrival', (
    tester,
  ) async {
    phone(tester);
    await signInAnna(tester);
    (getIt<EsimCompatibility>() as FakeCompatibility).oneTap = true;
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    await tester.tap(find.text('My eSIM').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Türkiye'));
    await tester.pumpAndSettle();

    expect(find.text('Install in one tap'), findsOneWidget);
    expect(
      find.text(
        'The eSIM connects when you arrive in the destination and your '
        'phone finds a local network.',
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining('Installer stuck on “Connecting”'),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the balance pill opens top-up and PayPal credits the balance', (
    tester,
  ) async {
    phone(tester);
    await signInAnna(tester);
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.text(r'$24.50'), findsOneWidget);
    await tester.tap(find.text(r'$24.50'));
    await tester.pumpAndSettle();

    expect(find.text('Top up balance'), findsWidgets);
    final currentBalance = tester.widget<Text>(find.text(r'$24.50').last);
    expect(currentBalance.style?.fontWeight, FontWeight.w700);
    expect(
      tester.widget<TextField>(find.byType(TextField)).decoration?.hintText,
      'Amount in USD',
    );
    for (final method in ['payment-paypal', 'payment-crypto']) {
      expect(
        find.descendant(
          of: find.byKey(ValueKey(method)),
          matching: find.byType(HugeIcon),
        ),
        findsOneWidget,
      );
    }
    expect(
      tester.widget<Text>(find.text(r'$20')).style?.fontWeight,
      FontWeight.w700,
    );
    await tester.tap(find.text(r'$20'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(r'Top up $20'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Waiting for PayPal'), findsOneWidget);

    // PayPal confirms after ~3 s; the screen polls every 2 s.
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(seconds: 2));
    }
    await tester.pumpAndSettle();
    expect(find.text('Balance topped up'), findsOneWidget);
    expect(getIt<WalletCubit>().state.balance?.cents, 4450);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('coin and network selectors open the chosen crypto invoice', (
    tester,
  ) async {
    phone(tester);
    await signInAnna(tester);
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    await tester.tap(find.text(r'$24.50'));
    await tester.pumpAndSettle();
    expect(find.text(r'From $5 to $500'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('payment-crypto')));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(AppSheetFrame), findsNothing);
    expect(find.text('Coin'), findsOneWidget);
    expect(find.text('Network'), findsOneWidget);
    expect(find.text('USDT'), findsOneWidget);
    expect(find.text('TRC-20'), findsOneWidget);
    expect(find.text(r'Minimum top-up · $1.00'), findsOneWidget);
    expect(
      find.text('Payment fee is included in the amount to send'),
      findsOneWidget,
    );

    await tester.ensureVisible(
      find.byKey(const ValueKey('top-up-network-selector')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('top-up-network-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ERC-20').last);
    await tester.pumpAndSettle();
    expect(find.text('ERC-20'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('top-up-coin-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('USDC').last);
    await tester.pumpAndSettle();
    expect(find.text('USDC'), findsOneWidget);
    expect(find.text('ERC-20'), findsOneWidget);

    await tester.ensureVisible(find.text(r'$20'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(r'$20'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text(r'Top up $20'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(r'Top up $20'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('USDC'), findsOneWidget);
    expect(find.text('ERC-20'), findsOneWidget);
    expect(find.byType(QrImageView), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('an unpaid crypto invoice can return to a new amount', (
    tester,
  ) async {
    phone(tester);
    await signInAnna(tester);
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    await tester.tap(find.text(r'$24.50'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(r'$20'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('payment-crypto')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('top-up-coin-selector')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('top-up-coin-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('USDC').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text(r'Top up $20'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(r'Top up $20'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final first = BlocProvider.of<TopUpCubit>(
      tester.element(find.byType(QrImageView)),
    ).state.session!.id;
    await tester.tap(find.byKey(const ValueKey('crypto-change-amount')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('stays active until its timer ends'),
      findsOneWidget,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(QrImageView), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('crypto-change-amount')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Change amount'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(QrImageView), findsNothing);
    await tester.scrollUntilVisible(
      find.text(r'Top up $20'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text(r'Top up $20'), findsOneWidget);

    await tester.ensureVisible(find.text(r'$50'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(r'$50'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text(r'Top up $50'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(r'Top up $50'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    final second = BlocProvider.of<TopUpCubit>(
      tester.element(find.byType(QrImageView)),
    ).state.session!;
    expect(second.id, isNot(first));
    expect(second.amount.cents, 5000);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('invoice coin and network selectors open matching new invoices', (
    tester,
  ) async {
    phone(tester);
    await signInAnna(tester);
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    await tester.tap(find.text(r'$24.50'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(r'$20'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('payment-crypto')));
    await tester.pumpAndSettle();
    expect(find.text('TRC-20'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text(r'Top up $20'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(r'Top up $20'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    TopUpCubit cubit() =>
        BlocProvider.of<TopUpCubit>(tester.element(find.byType(QrImageView)));

    final first = cubit().state.session!.id;
    await tester.tap(find.byKey(const ValueKey('crypto-network-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ERC-20'));
    await tester.pumpAndSettle();
    expect(find.textContaining('needs a new payment address'), findsOneWidget);
    await tester.tap(find.text('Create new payment'));
    await tester.pumpAndSettle();
    expect(cubit().state.session!.id, isNot(first));
    expect(cubit().state.session!.crypto!.network, 'ERC-20');

    final second = cubit().state.session!.id;
    await tester.tap(find.byKey(const ValueKey('crypto-coin-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('USDC'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create new payment'));
    await tester.pumpAndSettle();
    expect(cubit().state.session!.id, isNot(second));
    expect(cubit().state.session!.crypto!.coin, 'USDC');
    expect(cubit().state.session!.crypto!.network, 'ERC-20');

    await tester.pumpWidget(const SizedBox());
  });
}

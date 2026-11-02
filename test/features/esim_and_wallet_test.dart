import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:waysim/app/app.dart';
import 'package:waysim/app/session_coordinator.dart';
import 'package:waysim/core/di/injector.dart';
import 'package:waysim/core/constants/app_icons.dart';
import 'package:waysim/core/services/esim_compatibility.dart';
import 'package:waysim/core/storage/local_storage.dart';
import 'package:waysim/core/utils/result.dart';
import 'package:waysim/core/widgets/app_bottom_sheet.dart';
import 'package:waysim/core/widgets/copy_field.dart';
import 'package:waysim/features/esim/presentation/esim_install_tracker.dart';
import 'package:waysim/features/auth/domain/repositories/auth_repository.dart';
import 'package:waysim/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:waysim/features/catalog/presentation/cubit/catalog_cubit.dart';
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

  Future<void> signInAnna(WidgetTester tester) async {
    await tester.runAsync(() async {
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

    expect(find.text('Install'), findsOneWidget);
    expect(find.text('Installed'), findsOneWidget);

    expect(find.text('Thailand'), findsNothing);

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
    expect(find.text('SM-DP+ address'), findsNothing);
    await tester.tap(find.text('Manual installation'));
    await tester.pumpAndSettle();
    expect(find.byType(QrImageView), findsNothing);
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
    await tester.tap(find.text('Georgia'));
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

  testWidgets('active eSIM does not offer a reused one-tap code', (
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

    expect(find.text('Install in one tap'), findsNothing);
    expect(
      find.textContaining('already marked installed or active'),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('returning to a stuck install shows network reset steps once', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    phone(tester);
    await signInAnna(tester);
    (getIt<EsimCompatibility>() as FakeCompatibility).oneTap = true;
    await getIt<LocalStorage>().setString(
      'esim_install_started_esim_seed_ge',
      DateTime.now().subtract(const Duration(minutes: 4)).toIso8601String(),
    );
    await getIt<LocalStorage>().setString(
      'esim_install_status_esim_seed_ge',
      'notInstalled',
    );
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    await tester.tap(find.text('My eSIM').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Georgia'));
    await tester.pumpAndSettle();

    expect(find.text('Network reset steps'), findsWidgets);
    expect(find.text('Open the iPhone Settings app'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('esim-network-reset-open-settings')),
      findsNothing,
    );
    expect(
      find.textContaining('Do not choose Delete All eSIMs'),
      findsOneWidget,
    );
    expect(EsimInstallTracker.guideWasShown('esim_seed_ge'), isTrue);

    await tester.pumpWidget(const SizedBox());
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('stuck-install notification route opens the reset guide', (
    tester,
  ) async {
    phone(tester);
    await signInAnna(tester);
    await getIt<LocalStorage>().setString(
      'esim_install_started_esim_seed_ge',
      DateTime.now().subtract(const Duration(minutes: 2)).toIso8601String(),
    );
    await getIt<LocalStorage>().setString(
      'esim_install_status_esim_seed_ge',
      'notInstalled',
    );
    await getIt<LocalStorage>().setString(
      'esim_install_method_esim_seed_ge',
      'one_tap',
    );
    await EsimInstallTracker.markGuideShown('esim_seed_ge');
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    GoRouter.of(
      tester.element(find.text('My eSIM').last),
    ).push('/esim/esim_seed_ge?networkReset=true');
    await tester.pumpAndSettle();

    expect(find.text('Network reset steps'), findsWidgets);
    expect(
      find.textContaining('Do not choose Delete All eSIMs'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'the balance pill opens top-up with other methods marked coming soon',
    (tester) async {
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
      for (final method in [
        'payment-crypto',
        'payment-paypal',
        'payment-google-pay',
        'payment-bank-card',
      ]) {
        expect(
          find.descendant(
            of: find.byKey(ValueKey(method)),
            matching: find.byType(HugeIcon),
          ),
          findsOneWidget,
        );
      }
      expect(find.text('Coming soon'), findsNWidgets(3));
      await tester.scrollUntilVisible(
        find.byType(TextField),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        tester.widget<TextField>(find.byType(TextField)).decoration?.hintText,
        'Amount in USD',
      );
      expect(
        tester
            .widget<Semantics>(
              find
                  .descendant(
                    of: find.byKey(const ValueKey('payment-paypal')),
                    matching: find.byType(Semantics),
                  )
                  .first,
            )
            .properties
            .enabled,
        isFalse,
      );

      await tester.pumpWidget(const SizedBox());
    },
  );

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
    await tester.scrollUntilVisible(
      find.text(r'$20'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text(r'$20'));
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

    await tester.scrollUntilVisible(
      find.text(r'$50'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
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
    await tester.scrollUntilVisible(
      find.text(r'$20'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text(r'$20'));
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

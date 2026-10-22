import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/core/error/failure.dart';
import 'package:waysim/core/utils/formatters/money.dart';
import 'package:waysim/features/esim/domain/entities/esim.dart';
import 'package:waysim/features/wallet/domain/entities/wallet_entities.dart';
import 'package:waysim/mock/mock_backend.dart';

MockBackend backend({DateTime Function()? now}) => MockBackend(
  now: now,
  latency: Duration.zero,
  purchaseLatency: Duration.zero,
);

Future<MockBackend> signedIn({
  String email = 'new@example.com',
  DateTime Function()? now,
}) async {
  final b = backend(now: now);
  await b.verifyCode(email, '123456');
  return b;
}

void main() {
  group('sign in', () {
    test('rejects the demo bad code and bad e-mail', () async {
      final b = backend();
      expect(
        (await b.verifyCode('a@b.co', '000000')).failureOrNull?.code,
        ApiCodes.otpInvalid,
      );
      expect((await b.requestCode('nope')).isError, isTrue);
      expect((await b.requestCode('a@b.co')).isSuccess, isTrue);
    });

    test('a new address starts empty, the demo customer has history', () async {
      final fresh = await signedIn();
      expect((await fresh.esims()).dataOrNull, isEmpty);

      final anna = await signedIn(email: 'anna@example.com');
      final esims = (await anna.esims()).dataOrNull!;
      expect(esims.map((e) => e.status), contains(EsimStatus.active));
      expect(esims.where((e) => e.status.isArchived), hasLength(2));
    });

    test('guests cannot read private data', () async {
      final b = backend();
      expect((await b.balance()).failureOrNull, isA<UnauthorizedFailure>());
      expect((await b.esims()).failureOrNull, isA<UnauthorizedFailure>());
    });
  });

  group('purchase', () {
    test('charges once, creates a not-installed eSIM and an order', () async {
      final b = await signedIn();
      final result = await b.buy('TR_5_30', 'k1', const Money(599));

      final receipt = result.dataOrNull!;
      expect(receipt.balanceAfter, const Money(1851)); // $24.50 − $5.99
      expect(receipt.esim.status, EsimStatus.notInstalled);
      expect(receipt.esim.volumeBytes, 5 * 1024 * 1024 * 1024);
      expect(receipt.esim.lpa, startsWith(r'LPA:1$smdp.example.com$'));
      expect((await b.orders(OrderType.purchase)).dataOrNull, hasLength(1));
    });

    test('the same idempotency key never charges twice', () async {
      final b = await signedIn();
      await b.buy('TR_5_30', 'same', const Money(599));
      final again = await b.buy('TR_5_30', 'same', const Money(599));

      expect(again.dataOrNull!.balanceAfter, const Money(1851));
      expect((await b.esims()).dataOrNull, hasLength(1));
    });

    test('a stale price is rejected with the new one', () async {
      final b = await signedIn();
      final result = await b.buy('TR_5_30', 'k', const Money(499));

      final failure = result.failureOrNull!;
      expect(failure.code, ApiCodes.priceChanged);
      expect(failure.details!['newPriceCents'], 599);
      expect((await b.balance()).dataOrNull, const Money(2450));
    });

    test('cannot spend more than the balance', () async {
      final b = await signedIn();
      // Europe 50 GB is far above $24.50.
      final result = await b.buy('EU_50_30', 'k', const Money(11699));
      expect(result.failureOrNull?.code, ApiCodes.insufficientBalance);
      expect((await b.balance()).dataOrNull, const Money(2450));
    });

    test('a supplier failure is refunded and recorded', () async {
      final b = await signedIn();
      final result = await b.buy('TH_3_30', 'k', const Money(399));

      expect(result.isError, isTrue);
      expect((await b.balance()).dataOrNull, const Money(2450));
      final orders = (await b.orders(OrderType.purchase)).dataOrNull!;
      expect(orders.single.outcome, OrderOutcome.failedRefunded);
    });
  });

  group('top-up of an existing eSIM', () {
    test('adds data and days and charges the balance', () async {
      final b = await signedIn(email: 'anna@example.com');
      final before = (await b.esim('esim_seed_tr')).dataOrNull!;

      final result = await b.topUp(
        'esim_seed_tr',
        'TOPUP_TR_3_30',
        'k',
        const Money(399),
      );

      final after = result.dataOrNull!.esim;
      expect(after.volumeBytes, before.volumeBytes! + 3 * 1024 * 1024 * 1024);
      expect(after.days, before.days + 30);
      expect(result.dataOrNull!.balanceAfter, const Money(2051));
    });

    test('an expired eSIM cannot be topped up', () async {
      final b = await signedIn(email: 'anna@example.com');
      final result = await b.topUp(
        'esim_seed_th',
        'TOPUP_TH_1_7',
        'k',
        const Money(199),
      );
      expect(result.isError, isTrue);
    });
  });

  group('balance top-up', () {
    test('PayPal credits exactly once however often it is polled', () async {
      var clock = DateTime(2026, 10, 7, 12);
      final b = await signedIn(now: () => clock);
      final session = (await b.createTopUp(
        amount: const Money(2000),
        method: TopUpMethod.paypal,
        key: 'p1',
      )).dataOrNull!;

      expect(
        (await b.topUpProgress(session.id)).dataOrNull!.status,
        TopUpStatus.waiting,
      );
      expect((await b.balance()).dataOrNull, const Money(2450));

      clock = clock.add(const Duration(seconds: 5));
      for (var i = 0; i < 3; i++) {
        expect(
          (await b.topUpProgress(session.id)).dataOrNull!.status,
          TopUpStatus.credited,
        );
      }
      expect((await b.balance()).dataOrNull, const Money(4450));
      final topUps = (await b.orders(OrderType.topUp)).dataOrNull!;
      expect(topUps, hasLength(1));
      final details = (await b.payment(topUps.single.number)).dataOrNull!;
      expect(details.status, TopUpStatus.credited);
      expect(details.creditedAmount, const Money(2000));
    });

    test('crypto goes waiting → confirming → credited', () async {
      var clock = DateTime(2026, 10, 7, 12);
      final b = await signedIn(now: () => clock);
      final session = (await b.createTopUp(
        amount: const Money(2000),
        method: TopUpMethod.crypto,
        key: 'c1',
        coin: 'USDT',
        network: 'TRC-20',
      )).dataOrNull!;

      expect(session.crypto!.amountText, '20.00');
      expect(session.crypto!.requiredConfirmations, 20);

      expect(
        (await b.topUpProgress(session.id)).dataOrNull!.status,
        TopUpStatus.waiting,
      );

      clock = clock.add(const Duration(seconds: 6));
      final mid = (await b.topUpProgress(session.id)).dataOrNull!;
      expect(mid.status, TopUpStatus.confirming);
      expect(mid.confirmations, inInclusiveRange(1, 19));

      clock = clock.add(const Duration(seconds: 20));
      expect(
        (await b.topUpProgress(session.id)).dataOrNull!.status,
        TopUpStatus.credited,
      );
    });

    test('the same key returns the same payment', () async {
      final b = await signedIn();
      final first = (await b.createTopUp(
        amount: const Money(1000),
        method: TopUpMethod.paypal,
        key: 'dup',
      )).dataOrNull!;
      final second = (await b.createTopUp(
        amount: const Money(1000),
        method: TopUpMethod.paypal,
        key: 'dup',
      )).dataOrNull!;
      expect(second.id, first.id);
    });

    test('amounts outside the limits are refused', () async {
      final b = await signedIn();
      for (final cents in [100, 999999]) {
        final r = await b.createTopUp(
          amount: Money(cents),
          method: TopUpMethod.paypal,
          key: 'k$cents',
        );
        expect(r.isError, isTrue);
      }
    });
  });

  test('an eSIM binds to one device only', () async {
    final b = await signedIn();
    final id = (await b.buy(
      'TR_1_7',
      'k',
      const Money(199),
    )).dataOrNull!.esim.id;

    expect((await b.bindToDevice(id, 'iPhone 15')).isSuccess, isTrue);
    expect((await b.bindToDevice(id, 'iPhone 15')).isSuccess, isTrue);
    expect(
      (await b.bindToDevice(id, 'Pixel 8')).failureOrNull?.code,
      'esim-bound-to-another-device',
    );
  });
}

import '../../../core/error/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_helpers.dart';
import '../../../core/network/api_response.dart';
import '../../../core/utils/formatters/money.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/safe_url.dart';
import '../domain/entities/wallet_entities.dart';
import '../domain/repositories/wallet_repository.dart';

class ApiWalletRepository implements WalletRepository {
  ApiWalletRepository(this.api);
  final ApiClient api;

  @override
  Future<Result<Money>> balance() => apiResult(
    () async =>
        Money(asMap(await api.get('/v1/wallet')).intVal('balanceCents')),
  );

  @override
  Future<Result<WalletOptions>> options() => apiResult(() async {
    final wallet = asMap(await api.get('/v1/wallet'));
    final limits = wallet.mapOrNull('limits') ?? {};
    final methodRows = parseList(
      await api.get('/v1/payments/methods'),
      (j) => j,
    );
    final methods = methodRows
        .where((j) => j.boolVal('enabled'))
        .map(
          (j) => switch (j.str('provider')) {
            'crypto' => TopUpMethod.crypto,
            'paypal' => TopUpMethod.paypal,
            _ => null,
          },
        )
        .whereType<TopUpMethod>()
        .toList();
    final currencies = methods.contains(TopUpMethod.crypto)
        ? asMap(await api.get('/v1/payments/crypto/currencies'))
              .listOf('currencies')
              .map(
                (j) => CryptoOption(
                  j.str('coin'),
                  j.str('network'),
                  code: j.str('code'),
                  minCents: j.intOrNull('minCents'),
                  logoUrl: j.strOrNull('logoUrl'),
                ),
              )
              .toList()
        : <CryptoOption>[];
    final pendingId = wallet.mapOrNull('pendingPayment')?.strOrNull('id');
    final pending = pendingId == null
        ? null
        : paymentFromApi(
            asMap(
              await api.get('/v1/payments/${Uri.encodeComponent(pendingId)}'),
            ),
          );
    return WalletOptions(
      minCents: limits.intVal('minCents', 500),
      maxCents: limits.intVal('maxCents', 50000),
      methods: methods,
      currencies: currencies,
      pending: pending,
    );
  });

  @override
  Future<Result<TopUpSession>> createTopUp({
    required Money amount,
    required TopUpMethod method,
    required String idempotencyKey,
    String? coin,
    String? network,
    String? payCurrency,
  }) => apiResult(() async {
    if (method == TopUpMethod.crypto &&
        (payCurrency == null || payCurrency.isEmpty)) {
      throw const ParsingException('A server-provided currency is required');
    }
    return paymentFromApi(
      asMap(
        await api.post(
          '/v1/payments',
          headers: {'Idempotency-Key': idempotencyKey},
          data: {
            'amountCents': amount.cents,
            'provider': method.name,
            if (method == TopUpMethod.crypto) 'payCurrency': payCurrency,
          },
        ),
      ),
    );
  });

  @override
  Future<Result<TopUpSession>> payment(String id) => apiResult(
    () async => paymentFromApi(
      asMap(await api.get('/v1/payments/${Uri.encodeComponent(id)}')),
    ),
  );
  @override
  Future<Result<TopUpProgress>> topUpProgress(String sessionId) =>
      apiResult(() async {
        final j = asMap(
          await api.get('/v1/payments/${Uri.encodeComponent(sessionId)}'),
        );
        return TopUpProgress(
          paymentStatus(j.str('status')),
          creditedAmount: j.intOrNull('creditedCents') == null
              ? null
              : Money(j.intVal('creditedCents')),
        );
      });

  @override
  Future<Result<List<WalletOrder>>> orders(OrderType type) => apiResult(
    () async {
      final payment = type == OrderType.topUp;
      final rows = await apiPages(api, payment ? '/v1/payments' : '/v1/orders');
      if (!payment) {
        AppLogger.i('[ORDER] History loaded count=${rows.length}');
      }
      return rows.map((j) => walletOrderFromApi(j, type)).toList();
    },
  );

  @override
  Future<Result<WalletOrder>> order(String id) => apiResult(() async {
    final response = asMap(
      await api.get('/v1/orders/${Uri.encodeComponent(id)}'),
    );
    AppLogger.i(
      '[ORDER] Detail loaded orderId=$id status=${response.str('status')}',
    );
    return walletOrderFromApi(response, OrderType.purchase);
  });

  @override
  Future<Result<List<Map<String, dynamic>>>> ledger() =>
      apiResult(() => apiPages(api, '/v1/wallet/ledger'));
}

WalletOrder walletOrderFromApi(Map<String, dynamic> j, OrderType type) {
  final payment = type == OrderType.topUp;
  return WalletOrder(
    number: '${j['publicNo']}',
    id: j.strOrNull('id'),
    slug: j.strOrNull('slug'),
    esimId: j.strOrNull('esimId'),
    failedReason: j.strOrNull('failedReason'),
    doneAt: j.dateOrNull('doneAt'),
    type: type,
    outcome: switch (j.str('status')) {
      'done' || 'credited' => OrderOutcome.completed,
      'failed_refunded' || 'refunded' => OrderOutcome.failedRefunded,
      'pending' || 'processing' || 'confirming' => OrderOutcome.pending,
      'review_underpaid' ||
      'review_overpaid' ||
      'review_late' => OrderOutcome.review,
      _ => OrderOutcome.failed,
    },
    amount: Money(
      payment && j.str('status') == 'credited'
          ? j.intVal('creditedCents', j.intVal('amountCents'))
          : j.intVal('amountCents'),
    ),
    createdAt:
        j.dateOrNull('createdAt') ?? DateTime.fromMillisecondsSinceEpoch(0),
    destinationNames: {'en': j.str('title')},
    serverTitle: payment ? null : j.str('title'),
    addOn: j.str('kind') == 'topup',
    method: payment
        ? (j.str('provider') == 'paypal'
              ? TopUpMethod.paypal
              : TopUpMethod.crypto)
        : null,
  );
}

TopUpStatus paymentStatus(String status) => switch (status) {
  'pending' => TopUpStatus.waiting,
  'confirming' => TopUpStatus.confirming,
  'credited' => TopUpStatus.credited,
  'review_underpaid' ||
  'review_overpaid' ||
  'review_late' => TopUpStatus.review,
  'expired' => TopUpStatus.expired,
  _ => TopUpStatus.failed,
};

TopUpSession paymentFromApi(Map<String, dynamic> j) {
  final c = j.mapOrNull('crypto');
  final expiry = j.dateOrNull('expiresAt');
  if (c != null && expiry == null) {
    throw const ParsingException('Missing invoice expiry');
  }
  return TopUpSession(
    id: j.str('id'),
    publicNo: j.intOrNull('publicNo'),
    amount: Money(j.intVal('amountCents')),
    rawStatus: j.str('status'),
    createdAt: j.dateOrNull('createdAt'),
    creditedAt: j.dateOrNull('creditedAt'),
    method: j.str('provider') == 'paypal'
        ? TopUpMethod.paypal
        : TopUpMethod.crypto,
    checkoutUrl: safeHttpsUri(j.strOrNull('checkoutUrl')),
    status: paymentStatus(j.str('status')),
    creditedAmount: j.intOrNull('creditedCents') == null
        ? null
        : Money(j.intVal('creditedCents')),
    crypto: c == null
        ? null
        : CryptoInvoice(
            coin: c.str('coin'),
            network: c.str('network'),
            address: c.str('payAddress'),
            amountText: c.str('payAmount'),
            paidAmountText: c.strOrNull('paidAmount'),
            providerStatus: c.strOrNull('providerStatus'),
            feeCents: c.intOrNull('feeCents'),
            totalCents: c.intOrNull('totalCents'),
            txid: c.strOrNull('txid'),
            rateText: c.strOrNull('rateUsd') == null
                ? '—'
                : "1 ${c.str('coin')} = \$${c.str('rateUsd')}",
            expiresAt: expiry!,
            requiredConfirmations: 0,
            memo: c.strOrNull('payExtraId'),
            qrValue: c.strOrNull('qrValue'),
          ),
  );
}

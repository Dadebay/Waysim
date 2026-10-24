import '../../../core/error/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_helpers.dart';
import '../../../core/network/api_response.dart';
import '../../../core/utils/formatters/money.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/result.dart';
import '../../esim/data/api_esim_repository.dart';
import '../domain/repositories/purchase_repository.dart';

class ApiPurchaseRepository implements PurchaseRepository {
  ApiPurchaseRepository(
    this.api,
    this.esims, {
    this.delay = Future<void>.delayed,
  });
  final ApiClient api;
  final ApiEsimRepository esims;
  final Future<void> Function(Duration) delay;
  final _orders = <String, String>{};

  @override
  Future<Result<PurchaseReceipt>> buy({
    required String packageId,
    required String idempotencyKey,
    required Money expectedPrice,
    int? days,
    bool Function()? cancelled,
  }) => _order(
    '/v1/orders',
    packageId,
    idempotencyKey,
    expectedPrice: expectedPrice,
    days: days,
    cancelled: cancelled,
  );
  @override
  Future<Result<PurchaseReceipt>> topUp({
    required String esimId,
    required String packageId,
    required String idempotencyKey,
    required Money expectedPrice,
    int? days,
    bool Function()? cancelled,
  }) => _order(
    '/v1/esims/${Uri.encodeComponent(esimId)}/topups',
    packageId,
    idempotencyKey,
    expectedPrice: expectedPrice,
    cancelled: cancelled,
  );

  Future<Result<PurchaseReceipt>> _order(
    String path,
    String packageId,
    String key, {
    required Money expectedPrice,
    int? days,
    bool Function()? cancelled,
  }) => apiResult(() async {
    Map<String, dynamic> order;
    var interval = 2000;
    final elapsed = Stopwatch()..start();
    final kind = path == '/v1/orders' ? 'purchase' : 'add-on';
    final keyTag = key.length <= 8 ? key : key.substring(0, 8);
    final existing = _orders[key];
    AppLogger.group(
      '[ORDER] ${existing == null ? 'Create' : 'Resume'} $kind',
      lines: [
        'packageId=$packageId days=${days ?? '-'} key=$keyTag',
        if (existing != null) 'orderId=$existing',
      ],
      level: Level.info,
    );
    if (existing != null) {
      order = asMap(
        await api.get('/v1/orders/${Uri.encodeComponent(existing)}'),
      );
    } else {
      final result = asMap(
        await api.post(
          path,
          data: {'packageId': packageId, 'days': ?days},
          headers: {'Idempotency-Key': key},
        ),
      );
      order = asMap(result['order']);
      interval = result.intVal('pollAfterMs', 2000).clamp(1000, 10000);
      _orders[key] = order.str('id');
    }
    final orderId = order.str('id');
    final acceptedAmount = order.intOrNull('amountCents');
    var status = order.str('status');
    var polls = 0;
    AppLogger.group(
      '[ORDER] Accepted $kind',
      lines: [
        'orderId=$orderId number=${order['publicNo'] ?? '-'} status=$status',
        'amountCents=${order['amountCents'] ?? '-'} pollAfterMs=$interval',
      ],
      level: Level.info,
    );
    final deadline = DateTime.now().add(const Duration(minutes: 10));
    while (status == 'pending' || status == 'processing') {
      if (cancelled?.call() ?? false) {
        AppLogger.w(
          '[ORDER] View closed; orderId=$orderId continues on server',
        );
        throw const NetworkException('Order continues on the server');
      }
      if (DateTime.now().isAfter(deadline)) {
        AppLogger.w(
          '[ORDER] Poll timeout orderId=$orderId status=$status polls=$polls',
        );
        throw const TimeoutException();
      }
      await delay(Duration(milliseconds: interval));
      if (cancelled?.call() ?? false) {
        AppLogger.w(
          '[ORDER] View closed; orderId=$orderId continues on server',
        );
        throw const NetworkException('Order continues on the server');
      }
      order = asMap(
        await api.get('/v1/orders/${Uri.encodeComponent(orderId)}'),
      );
      polls++;
      final nextStatus = order.str('status');
      if (nextStatus != status) {
        AppLogger.i(
          '[ORDER] Status orderId=$orderId $status → $nextStatus '
          'polls=$polls elapsedMs=${elapsed.elapsedMilliseconds}',
        );
      }
      status = nextStatus;
    }
    if (status == 'failed_refunded') {
      AppLogger.w(
        '[ORDER] Refunded orderId=$orderId reason=${order['failedReason'] ?? '-'}',
      );
      throw ServerException(
        'Order failed and was refunded',
        code: 'order_failed_refunded',
        details: {'reason': order['failedReason']},
      );
    }
    final esimId = order.strOrNull('esimId');
    if (status != 'done' || esimId == null) {
      AppLogger.w(
        '[ORDER] Incomplete orderId=$orderId status=$status esimId=${esimId ?? '-'}',
      );
      throw const ParsingException('Incomplete order');
    }
    final esim = await esims.get(esimId);
    if (esim case Error(:final failure)) {
      throw ServerException(
        failure.message ?? 'eSIM unavailable',
        code: failure.code,
      );
    }
    final wallet = asMap(await api.get('/v1/wallet'));
    AppLogger.i(
      '[ORDER] Ready orderId=$orderId esimId=$esimId '
      'balanceCents=${wallet.intVal('balanceCents')} '
      'elapsedMs=${elapsed.elapsedMilliseconds}',
    );
    return PurchaseReceipt(
      orderId: orderId,
      charged: Money(
        order.intOrNull('amountCents') ?? acceptedAmount ?? expectedPrice.cents,
      ),
      esim: esim.dataOrNull!,
      balanceAfter: Money(wallet.intVal('balanceCents')),
    );
  });
}

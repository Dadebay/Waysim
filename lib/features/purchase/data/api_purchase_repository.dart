import '../../../core/error/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_helpers.dart';
import '../../../core/network/api_response.dart';
import '../../../core/utils/formatters/money.dart';
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
    cancelled: cancelled,
  );

  Future<Result<PurchaseReceipt>> _order(
    String path,
    String packageId,
    String key, {
    int? days,
    bool Function()? cancelled,
  }) => apiResult(() async {
    Map<String, dynamic> order;
    var interval = 2000;
    final existing = _orders[key];
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
    final deadline = DateTime.now().add(const Duration(minutes: 10));
    while (order.str('status') == 'pending' ||
        order.str('status') == 'processing') {
      if (cancelled?.call() ?? false) {
        throw const NetworkException('Order continues on the server');
      }
      if (DateTime.now().isAfter(deadline)) throw const TimeoutException();
      await delay(Duration(milliseconds: interval));
      if (cancelled?.call() ?? false) {
        throw const NetworkException('Order continues on the server');
      }
      order = asMap(
        await api.get('/v1/orders/${Uri.encodeComponent(order.str('id'))}'),
      );
    }
    if (order.str('status') == 'failed_refunded') {
      throw ServerException(
        'Order failed and was refunded',
        code: 'order_failed_refunded',
        details: {'reason': order['failedReason']},
      );
    }
    final esimId = order.strOrNull('esimId');
    if (order.str('status') != 'done' || esimId == null) {
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
    return PurchaseReceipt(
      esim: esim.dataOrNull!,
      balanceAfter: Money(wallet.intVal('balanceCents')),
    );
  });
}

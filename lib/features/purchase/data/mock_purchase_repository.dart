import '../../../core/utils/formatters/money.dart';
import '../../../core/utils/result.dart';
import '../../../mock/mock_backend.dart';
import '../domain/repositories/purchase_repository.dart';

class MockPurchaseRepository implements PurchaseRepository {
  MockPurchaseRepository(this._backend);

  final MockBackend _backend;

  @override
  Future<Result<PurchaseReceipt>> buy({
    required String packageId,
    required String idempotencyKey,
    required Money expectedPrice,
    int? days,
    bool Function()? cancelled,
  }) => _backend.buy(packageId, idempotencyKey, expectedPrice);

  @override
  Future<Result<PurchaseReceipt>> topUp({
    required String esimId,
    required String packageId,
    required String idempotencyKey,
    required Money expectedPrice,
    int? days,
    bool Function()? cancelled,
  }) => _backend.topUp(esimId, packageId, idempotencyKey, expectedPrice);
}

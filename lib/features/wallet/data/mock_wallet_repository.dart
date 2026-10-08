import '../../../core/utils/formatters/money.dart';
import '../../../core/utils/result.dart';
import '../../../mock/mock_backend.dart';
import '../domain/entities/wallet_entities.dart';
import '../domain/repositories/wallet_repository.dart';

class MockWalletRepository implements WalletRepository {
  MockWalletRepository(this._backend);

  final MockBackend _backend;

  @override
  Future<Result<Money>> balance() => _backend.balance();

  @override
  Future<Result<TopUpSession>> createTopUp({
    required Money amount,
    required TopUpMethod method,
    required String idempotencyKey,
    String? coin,
    String? network,
  }) => _backend.createTopUp(
    amount: amount,
    method: method,
    key: idempotencyKey,
    coin: coin,
    network: network,
  );

  @override
  Future<Result<TopUpProgress>> topUpProgress(String sessionId) =>
      _backend.topUpProgress(sessionId);

  @override
  Future<Result<List<WalletOrder>>> orders(OrderType type) =>
      _backend.orders(type);
}

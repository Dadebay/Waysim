import '../../../core/utils/formatters/money.dart';
import '../../../core/utils/result.dart';
import '../../../core/error/failure.dart';
import '../../../mock/mock_backend.dart';
import '../domain/entities/wallet_entities.dart';
import '../domain/repositories/wallet_repository.dart';

class MockWalletRepository implements WalletRepository {
  @override
  Future<Result<List<Map<String, dynamic>>>> ledger() async =>
      const Success([]);
  MockWalletRepository(this._backend);

  final MockBackend _backend;
  @override
  Future<Result<WalletOptions>> options() async =>
      const Success(WalletOptions());
  @override
  Future<Result<TopUpSession>> payment(String id) async =>
      const Error(NotFoundFailure());

  @override
  Future<Result<Money>> balance() => _backend.balance();

  @override
  Future<Result<TopUpSession>> createTopUp({
    required Money amount,
    required TopUpMethod method,
    required String idempotencyKey,
    String? coin,
    String? network,
    String? payCurrency,
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

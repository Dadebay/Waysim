import '../../../../core/utils/formatters/money.dart';
import '../../../../core/utils/result.dart';
import '../entities/wallet_entities.dart';

abstract interface class WalletRepository {
  Future<Result<List<Map<String, dynamic>>>> ledger();
  Future<Result<Money>> balance();
  Future<Result<WalletOptions>> options();
  Future<Result<TopUpSession>> payment(String id);

  Future<Result<TopUpSession>> createTopUp({
    required Money amount,
    required TopUpMethod method,
    required String idempotencyKey,
    String? coin,
    String? network,
    String? payCurrency,
  });

  Future<Result<TopUpProgress>> topUpProgress(String sessionId);

  Future<Result<List<WalletOrder>>> orders(OrderType type);
  Future<Result<WalletOrder>> order(String id);
}

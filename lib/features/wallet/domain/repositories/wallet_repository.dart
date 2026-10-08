import '../../../../core/utils/formatters/money.dart';
import '../../../../core/utils/result.dart';
import '../entities/wallet_entities.dart';

abstract interface class WalletRepository {
  Future<Result<Money>> balance();

  /// [idempotencyKey]: a repeated call with the same key returns the same
  /// session instead of creating a second payment.
  Future<Result<TopUpSession>> createTopUp({
    required Money amount,
    required TopUpMethod method,
    required String idempotencyKey,
    String? coin,
    String? network,
  });

  Future<Result<TopUpProgress>> topUpProgress(String sessionId);

  Future<Result<List<WalletOrder>>> orders(OrderType type);
}

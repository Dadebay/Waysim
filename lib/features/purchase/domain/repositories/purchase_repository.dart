import '../../../../core/utils/formatters/money.dart';
import '../../../../core/utils/result.dart';
import '../../../esim/domain/entities/esim.dart';

class PurchaseReceipt {
  const PurchaseReceipt({
    required this.orderId,
    required this.charged,
    required this.esim,
    required this.balanceAfter,
  });

  final String orderId;
  final Money charged;
  final Esim esim;
  final Money balanceAfter;
}

abstract interface class PurchaseRepository {
  Future<Result<PurchaseReceipt>> buy({
    required String packageId,
    required String idempotencyKey,
    required Money expectedPrice,
    int? days,
    bool Function()? cancelled,
  });

  Future<Result<PurchaseReceipt>> topUp({
    required String esimId,
    required String packageId,
    required String idempotencyKey,
    required Money expectedPrice,
    int? days,
    bool Function()? cancelled,
  });
}

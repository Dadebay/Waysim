import '../../../../core/utils/formatters/money.dart';
import '../../../../core/utils/result.dart';
import '../../../esim/domain/entities/esim.dart';

/// What a successful order hands back.
class PurchaseReceipt {
  const PurchaseReceipt({required this.esim, required this.balanceAfter});

  final Esim esim;
  final Money balanceAfter;
}

abstract interface class PurchaseRepository {
  /// Orders [packageId]. Only the package id and an idempotency key travel;
  /// the price is the server's. Failures to expect:
  /// `insufficient-balance`, `price-changed` (details carry the new price),
  /// `package-unavailable`, `maintenance-mode`.
  Future<Result<PurchaseReceipt>> buy({
    required String packageId,
    required String idempotencyKey,
    required Money expectedPrice,
  });

  /// Adds [packageId] to the installed eSIM [esimId].
  Future<Result<PurchaseReceipt>> topUp({
    required String esimId,
    required String packageId,
    required String idempotencyKey,
    required Money expectedPrice,
  });
}

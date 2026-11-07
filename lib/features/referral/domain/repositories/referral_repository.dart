import '../../../../core/utils/result.dart';
import '../entities/referral.dart';

abstract interface class ReferralRepository {
  Future<Result<ReferralInfo>> load();
}

import '../../../core/utils/result.dart';
import '../../../mock/mock_backend.dart';
import '../domain/entities/referral.dart';
import '../domain/repositories/referral_repository.dart';

class MockReferralRepository implements ReferralRepository {
  MockReferralRepository(this._backend);

  final MockBackend _backend;

  @override
  Future<Result<ReferralInfo>> load() => _backend.referral();
}

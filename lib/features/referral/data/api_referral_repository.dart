import '../../../core/network/api_client.dart';
import '../../../core/network/api_helpers.dart';
import '../../../core/network/api_response.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/formatters/money.dart';
import '../domain/entities/referral.dart';
import '../domain/repositories/referral_repository.dart';

class ApiReferralRepository implements ReferralRepository {
  ApiReferralRepository(this.api);
  final ApiClient api;
  @override
  Future<Result<ReferralInfo>> load() => apiResult(() async {
    final j = asMap(await api.get('/v1/referral'));
    final items = await apiPages(api, '/v1/referral/invitations');
    final stats = asMap(j['stats']);
    final invites = items
        .map(
          (i) => Invite(
            maskedEmail: i.str('email'),
            registeredAt: DateTime.parse(i.str('registeredAt')),
            status: switch (i.str('status')) {
              'credited' => InviteStatus.credited,
              'rejected' => InviteStatus.rejected,
              _ => InviteStatus.pending,
            },
            reward: Money(i.intVal('bonusCents')),
          ),
        )
        .toList();
    return ReferralInfo(
      code: j.str('code'),
      link: Uri.parse(j.str('link')),
      reward: Money(j.intVal('bonusCents')),
      invited: stats.intVal('invited'),
      credited: Money(stats.intVal('earnedCents')),
      pending: stats.intVal('pending'),
      rejected: invites.where((i) => i.status == InviteStatus.rejected).length,
      invites: invites,
      enabled: j.boolVal('enabled'),
      rulesText: j.strOrNull('rulesText'),
    );
  });
}

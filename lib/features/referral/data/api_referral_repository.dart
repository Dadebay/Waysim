import '../../../core/network/api_client.dart';
import '../../../core/network/api_helpers.dart';
import '../../../core/network/api_response.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/formatters/money.dart';
import '../domain/entities/referral.dart';
import '../domain/repositories/referral_repository.dart';

class ApiReferralRepository implements ReferralRepository {
  ApiReferralRepository(this.api);
  final ApiClient api;
  @override
  Future<Result<ReferralInfo>> load() => apiResult(() async {
    final started = DateTime.now();
    final Map<String, dynamic> j;
    final List<Map<String, dynamic>> items;
    try {
      j = asMap(await api.get('/v1/referral'));
      items = await apiPages(api, '/v1/referral/invitations');
    } catch (e, st) {
      AppLogger.e('[REFERRAL] load failed', e, st);
      rethrow;
    }
    final stats = asMap(j['stats']);
    _log(j, stats, items, started);
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

  static void _log(
    Map<String, dynamic> j,
    Map<String, dynamic> stats,
    List<Map<String, dynamic>> items,
    DateTime started,
  ) {
    String field(Map<String, dynamic> i, String key) =>
        i.containsKey(key) ? '${i[key]}' : '-';
    AppLogger.group(
      '[REFERRAL] loaded',
      level: Level.info,
      lines: [
        'took=${DateTime.now().difference(started).inMilliseconds}ms '
            'enabled=${j['enabled']} code=${j['code']} bonusCents=${j['bonusCents']}',
        'stats: $stats',
        'invitations=${items.length} (keys: ${j.keys.join(', ')})',
        for (final i in items)
          '- ${field(i, 'email')} status=${field(i, 'status')} '
              'bonusCents=${field(i, 'bonusCents')} '
              'registeredAt=${field(i, 'registeredAt')} '
              'extra=${{
                for (final e in i.entries)
                  if (!const {'email', 'status', 'bonusCents', 'registeredAt'}.contains(e.key)) e.key: e.value,
              }}',
        if (items.isEmpty)
          'no invitations yet: the invited user has not registered with this '
              'code, or the server did not link them',
      ],
    );
  }
}

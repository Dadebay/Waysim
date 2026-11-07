import '../../../core/network/api_client.dart';
import '../../../core/network/api_helpers.dart';
import '../../../core/network/api_response.dart';
import '../../../core/utils/result.dart';
import '../domain/entities/chat_message.dart';
import '../domain/repositories/support_repository.dart';

class ApiSupportRepository implements SupportRepository {
  ApiSupportRepository(this.api);
  final ApiClient api;
  @override
  bool get isLive => true;
  ChatMessage _message(Map<String, dynamic> j) => ChatMessage(
    id: j.str('id'),
    role: j.str('sender') == 'user' ? ChatRole.user : ChatRole.assistant,
    text: j.str('text'),
    staffName: j.strOrNull('staffName'),
    createdAt: j.dateOrNull('createdAt'),
  );
  @override
  Future<Result<List<ChatMessage>>> messages({String? after}) =>
      apiResult(() async {
        if (after == null) {
          final j = asMap(await api.get('/v1/support/thread'));
          return j.listOf('messages').map(_message).toList();
        }
        final result = <ChatMessage>[];
        var cursor = after;
        final seen = <String>{};
        while (seen.add(cursor)) {
          final j = asMap(
            await api.get(
              '/v1/support/messages',
              queryParameters: {'after': cursor, 'limit': 50},
            ),
          );
          final items = j.listOf('items');
          result.addAll(items.map(_message));
          final next = j.strOrNull('nextAfter');
          if (items.length < 50 || next == null || next == cursor) break;
          cursor = next;
        }
        return result;
      });
  @override
  Future<Result<ChatMessage>> ask({
    required String text,
    required String language,
  }) => apiResult(
    () async => _message(
      asMap(await api.post('/v1/support/messages', data: {'text': text})),
    ),
  );
  @override
  Future<Result<void>> markRead(String? id) => apiResult(() async {
    await api.post('/v1/support/read', data: {'upToMessageId': ?id});
  });
}

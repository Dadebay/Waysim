import '../../../../core/utils/result.dart';
import '../entities/chat_message.dart';

abstract interface class SupportRepository {
  /// Sends [text] to the AI assistant (via our backend — the model key never
  /// reaches the app). Max 2000 characters, ~30 messages a day.
  Future<Result<ChatMessage>> ask({
    required String text,
    required String language,
  });
}

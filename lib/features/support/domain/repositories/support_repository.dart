import '../../../../core/utils/result.dart';
import '../entities/chat_message.dart';

abstract interface class SupportRepository {
  bool get isLive;
  Future<Result<List<ChatMessage>>> messages({String? after});
  Future<Result<void>> markRead(String? id);

  Future<Result<ChatMessage>> ask({
    required String text,
    required String language,
  });
}

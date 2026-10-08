import 'package:equatable/equatable.dart';

enum ChatRole { user, assistant }

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.role,
    required this.text,
    this.offersHuman = false,
  });

  final ChatRole role;
  final String text;

  /// The assistant could not help: show "Contact support".
  final bool offersHuman;

  @override
  List<Object?> get props => [role, text, offersHuman];
}

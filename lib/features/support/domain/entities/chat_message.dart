import 'package:equatable/equatable.dart';

enum ChatRole { user, assistant }

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.role,
    required this.text,
    this.offersHuman = false,
    this.id,
    this.createdAt,
    this.staffName,
  });

  final String? id;
  final DateTime? createdAt;
  final String? staffName;
  final ChatRole role;
  final String text;

  final bool offersHuman;

  @override
  List<Object?> get props => [
    id,
    role,
    text,
    offersHuman,
    createdAt,
    staffName,
  ];
}

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/support_repository.dart';

class ChatState extends Equatable {
  const ChatState({
    this.messages = const [],
    this.sending = false,
    this.failure,
  });

  final List<ChatMessage> messages;
  final bool sending;
  final Failure? failure;

  @override
  List<Object?> get props => [messages, sending, failure];
}

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(this._repository) : super(const ChatState());

  static const maxLength = 2000;

  final SupportRepository _repository;

  Future<void> send(String text, {required String language}) async {
    final clean = text.trim();
    if (clean.isEmpty || clean.length > maxLength || state.sending) return;

    emit(
      ChatState(
        messages: [
          ...state.messages,
          ChatMessage(role: ChatRole.user, text: clean),
        ],
        sending: true,
      ),
    );
    final result = await _repository.ask(text: clean, language: language);
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(ChatState(messages: [...state.messages, data]));
      case Error(:final failure):
        emit(ChatState(messages: state.messages, failure: failure));
    }
  }
}

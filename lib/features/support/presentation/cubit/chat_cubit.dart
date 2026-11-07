import 'dart:async';
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
  ChatCubit(this._repository, {this.onRead}) : super(const ChatState());

  static const maxLength = 2000;

  final SupportRepository _repository;
  final void Function()? onRead;
  Timer? _timer;
  bool _reading = false;
  bool _visible = true;
  String? _after;
  bool get isLive => _repository.isLive;

  Future<void> load() async {
    if (!_repository.isLive || _reading || !_visible) return;
    _reading = true;
    final result = await _repository.messages(after: _after);
    _reading = false;
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        if (data.isNotEmpty) {
          _after = data.last.id;
        } else {
          _after ??= '';
        }
        _merge(data);
        final id = state.messages.lastOrNull?.id;
        if (id != null && data.isNotEmpty) {
          if ((await _repository.markRead(id)).isSuccess) onRead?.call();
        }
      case Error(:final failure):
        emit(
          ChatState(
            messages: state.messages,
            sending: state.sending,
            failure: failure,
          ),
        );
    }
    if (!isClosed && _visible) {
      _timer?.cancel();
      _timer = Timer(const Duration(seconds: 5), load);
    }
  }

  void _merge(List<ChatMessage> messages) {
    final byId = {
      for (final m in state.messages) m.id: m,
      for (final m in messages) m.id: m,
    };
    final ordered = byId.values.toList()
      ..sort((a, b) => (a.id ?? '').compareTo(b.id ?? ''));
    emit(ChatState(messages: ordered, sending: state.sending));
  }

  void setVisible(bool visible) {
    _visible = visible;
    _timer?.cancel();
    if (visible) unawaited(load());
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  Future<void> send(String text, {required String language}) async {
    final clean = text.trim();
    if (clean.isEmpty || clean.length > maxLength || state.sending) return;

    emit(
      ChatState(
        messages: [
          ...state.messages,
          if (!_repository.isLive)
            ChatMessage(role: ChatRole.user, text: clean),
        ],
        sending: true,
      ),
    );
    final result = await _repository.ask(text: clean, language: language);
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        if (_repository.isLive) {
          _merge([data]);
          emit(ChatState(messages: state.messages));
        } else {
          emit(ChatState(messages: [...state.messages, data]));
        }
      case Error(:final failure):
        emit(ChatState(messages: state.messages, failure: failure));
    }
  }
}

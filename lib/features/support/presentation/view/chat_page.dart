import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../config/presentation/cubit/config_cubit.dart';
import '../../domain/entities/chat_message.dart';
import '../cubit/chat_cubit.dart';
import 'support_sheet.dart';

/// The AI assistant: starter questions, the conversation, a way out to a
/// person. It answers only about Waysim and eSIM and never touches money.
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<ChatCubit>()..load(),
    child: const _View(),
  );
}

class _View extends StatefulWidget {
  const _View();

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  late final AppLifecycleListener _lifecycle;
  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () => context.read<ChatCubit>().setVisible(true),
      onInactive: () => context.read<ChatCubit>().setVisible(false),
      onPause: () => context.read<ChatCubit>().setVisible(false),
    );
  }

  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _lifecycle.dispose();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send(String text) {
    if (text.trim().isEmpty || context.read<ChatCubit>().state.sending) return;
    context.read<ChatCubit>().send(
      text,
      language: Localizations.localeOf(context).languageCode,
    );
    _input.clear();
    setState(() {});
  }

  void _toBottom() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scroll.hasClients) {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final chat = context.watch<ChatCubit>().state;
    _toBottom();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.searchBack,
          onPressed: () => context.pop(),
          icon: HugeIcon(icon: AppIcons.back, size: 24, color: c.textPrimary),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: c.primarySubtle,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Center(
                child: HugeIcon(
                  icon: AppIcons.sparkles,
                  size: 22,
                  color: c.primary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.chatTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.h3,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: c.primarySubtle,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 1,
                      ),
                      child: Text(
                        context.read<ChatCubit>().isLive
                            ? l10n.supportTeam
                            : l10n.chatBadge,
                        style: context.text.caption.copyWith(
                          color: c.link,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.all(AppSpacing.page),
              children: [
                Text(
                  context.read<ChatCubit>().isLive
                      ? l10n.supportLiveDisclaimer
                      : l10n.chatDisclaimer,
                  textAlign: TextAlign.center,
                  style: context.text.caption.copyWith(color: c.textSecondary),
                ),
                const SizedBox(height: AppSpacing.lg),
                _Bubble(
                  text: context.read<ChatCubit>().isLive
                      ? l10n.supportLiveGreeting
                      : l10n.chatGreeting,
                  mine: false,
                ),
                if (chat.messages.isEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final q in [
                        l10n.chatChipInstall,
                        l10n.chatChipChoose,
                        l10n.chatChipNetwork,
                      ])
                        ActionChip(label: Text(q), onPressed: () => _send(q)),
                    ],
                  ),
                ],
                for (final m in chat.messages) ...[
                  const SizedBox(height: AppSpacing.md),
                  _Bubble(text: m.text, mine: m.role == ChatRole.user),
                  if (m.offersHuman)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            '${l10n.chatNotHelped} ',
                            style: context.text.bodySm.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => writeToSupport(
                              context,
                              email: context
                                  .read<ConfigCubit>()
                                  .state
                                  .supportEmail,
                              id: context.read<AuthCubit>().state.publicId,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                l10n.chatContactHuman,
                                style: context.text.bodySm.copyWith(
                                  color: c.link,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
                if (chat.failure != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: Text(
                      chat.failure!.localize(l10n),
                      style: context.text.bodySm.copyWith(color: c.error),
                    ),
                  ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.chatHistoryNote,
                  style: context.text.caption.copyWith(color: c.textSecondary),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 52),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          decoration: BoxDecoration(
                            color: c.surface,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            border: Border.all(color: c.border),
                          ),
                          child: TextField(
                            controller: _input,
                            maxLength: ChatCubit.maxLength,
                            maxLines: 4,
                            minLines: 1,
                            textAlignVertical: TextAlignVertical.center,
                            textInputAction: TextInputAction.send,
                            onSubmitted: _send,
                            onChanged: (_) => setState(() {}),
                            cursorColor: c.primary,
                            style: context.text.bodyMed,
                            decoration: InputDecoration(
                              hintText: l10n.chatInputHint,
                              counterText: '',
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                              hintStyle: context.text.bodyMed.copyWith(
                                color: c.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Material(
                        color: _input.text.trim().isEmpty && !chat.sending
                            ? c.border
                            : c.primary,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: chat.sending ? null : () => _send(_input.text),
                          child: SizedBox.square(
                            dimension: 52,
                            child: Center(
                              child: chat.sending
                                  ? SizedBox.square(
                                      dimension: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: c.textOnPrimary,
                                      ),
                                    )
                                  : HugeIcon(
                                      icon: AppIcons.send,
                                      size: 22,
                                      color: c.textOnPrimary,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, required this.mine});

  final String text;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.82,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: mine ? c.primary : c.surface,
            border: mine ? null : Border.all(color: c.border),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: SelectableText(
            text,
            style: context.text.body.copyWith(
              color: mine ? c.textOnPrimary : c.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

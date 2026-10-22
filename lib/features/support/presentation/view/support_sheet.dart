import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/auth_gate.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_environment.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/services/crash_report.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../config/presentation/cubit/config_cubit.dart';
import '../support_mail.dart';

/// "How can we help?": the AI chat, or an e-mail to the team.
Future<void> showSupportSheet(BuildContext context) {
  final l10n = context.l10n;
  // Resolved before the sheet opens: the sheet has its own route context.
  final router = GoRouter.of(context);
  final auth = context.read<AuthCubit>();
  final email = context.read<ConfigCubit>().state.supportEmail;

  return showAppSheet<void>(
    context,
    title: l10n.supportSheetTitle,
    showClose: false,
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        0,
        AppSpacing.page,
        AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Option(
            icon: AppIcons.aiChat,
            title: AppEnvironment.useMockApi
                ? l10n.supportAiTitle
                : l10n.supportTeam,
            body: AppEnvironment.useMockApi
                ? l10n.supportAiBody
                : l10n.supportLiveGreeting,
            filled: true,
            onTap: () async {
              Navigator.of(sheetContext).pop();
              if (AppEnvironment.useMockApi || await requireSignIn(context)) {
                await router.push<void>(AppRoute.supportChat.path);
              }
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _Option(
            icon: AppIcons.mail,
            title: l10n.supportMailTitle,
            body: l10n.supportMailBody,
            onTap: () {
              Navigator.of(sheetContext).pop();
              writeToSupport(context, email: email, id: auth.state.publicId);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: l10n.actionClose,
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.of(sheetContext).pop(),
          ),
        ],
      ),
    ),
  );
}

/// Lets the customer write without seeing diagnostics, then opens the mail app.
Future<void> writeToSupport(
  BuildContext context, {
  required String email,
  required String? id,
}) async {
  final l10n = context.l10n;
  final device = getIt<DeviceContext>();
  final template = l10n.supportMailTemplate(
    id ?? '—',
    '${device.appVersion} (${device.buildNumber})',
    device.osVersion,
  );
  final promptEnd = template.indexOf('\n\n');
  final prompt = promptEnd < 0 ? template : template.substring(0, promptEnd);
  final message = await showAppSheet<String>(
    context,
    title: l10n.supportMailTitle,
    subtitle: l10n.supportMailBody,
    builder: (_) => _SupportMailComposer(
      prompt: prompt,
      continueLabel: l10n.actionContinue,
    ),
  );
  if (message == null || !context.mounted) return;

  String? deviceId;
  try {
    deviceId = await getIt<SecureStorage>().readDeviceId();
  } on Object {
    // Mail remains available if secure storage is locked.
  }
  final local = getIt<LocalStorage>();
  final body = buildSupportMailBody(
    message: message,
    localizedTemplate: template,
    device: device,
    osBuild: Platform.operatingSystemVersion,
    deviceId: deviceId,
    installId: local.getString(StorageKeys.installId),
    appLanguage: local.getString(StorageKeys.contentLanguage),
  );
  final uri = Uri.parse(
    'mailto:$email?subject=${Uri.encodeComponent(l10n.supportMailSubject(id ?? '—'))}'
    '&body=${Uri.encodeComponent(body)}',
  );
  bool opened = false;
  try {
    opened = await canLaunchUrl(uri) && await launchUrl(uri);
  } on PlatformException {
    // Show the existing copy-address fallback below.
  }
  if (!opened && context.mounted) await _showMailFallback(context, email);
}

class _SupportMailComposer extends StatefulWidget {
  const _SupportMailComposer({
    required this.prompt,
    required this.continueLabel,
  });

  final String prompt;
  final String continueLabel;

  @override
  State<_SupportMailComposer> createState() => _SupportMailComposerState();
}

class _SupportMailComposerState extends State<_SupportMailComposer> {
  final _message = TextEditingController();

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.page,
      0,
      AppSpacing.page,
      AppSpacing.xxl,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _message,
          autofocus: true,
          minLines: 4,
          maxLines: 6,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: widget.prompt,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _message,
          builder: (_, value, _) => AppButton(
            label: widget.continueLabel,
            onPressed: value.text.trim().isEmpty
                ? null
                : () => Navigator.of(context).pop(_message.text.trim()),
          ),
        ),
      ],
    ),
  );
}

Future<void> _showMailFallback(BuildContext context, String email) =>
    showAppSheet<void>(
      context,
      title: context.l10n.supportMailTitle,
      closeLabel: context.l10n.actionClose,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          0,
          AppSpacing.page,
          AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.supportMailFallback(email),
              style: sheetContext.text.body,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: context.l10n.actionCopyAddress,
              icon: AppIcons.copy,
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: email));
                if (sheetContext.mounted) {
                  Navigator.of(sheetContext).pop();
                  AppToast.show(context, context.l10n.toastCopied);
                }
              },
            ),
          ],
        ),
      ),
    );

class _Option extends StatelessWidget {
  const _Option({
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
    this.filled = false,
  });

  final AppIconData icon;
  final String title;
  final String body;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = filled ? c.textOnPrimary : c.textPrimary;
    final sub = filled
        ? c.textOnPrimary.withValues(alpha: 0.8)
        : c.textSecondary;

    return Material(
      color: filled ? c.primary : c.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: filled
              ? null
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: c.border),
                ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: filled
                      ? c.textOnPrimary.withValues(alpha: 0.16)
                      : c.primarySubtle,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Center(
                  child: HugeIcon(
                    icon: icon,
                    size: 24,
                    color: filled ? c.textOnPrimary : c.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.text.bodyMed.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(body, style: context.text.bodySm.copyWith(color: sub)),
                  ],
                ),
              ),
              HugeIcon(icon: AppIcons.chevronRight, size: 20, color: sub),
            ],
          ),
        ),
      ),
    );
  }
}

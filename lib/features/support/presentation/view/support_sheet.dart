import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../config/presentation/cubit/config_cubit.dart';

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
            title: l10n.supportAiTitle,
            body: l10n.supportAiBody,
            filled: true,
            onTap: () {
              Navigator.of(sheetContext).pop();
              router.push(AppRoute.supportChat.path);
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

/// Opens the mail app with the subject and technical details filled in; with
/// no mail app, shows the address to copy.
Future<void> writeToSupport(
  BuildContext context, {
  required String email,
  required String? id,
}) async {
  final l10n = context.l10n;
  final info = await PackageInfo.fromPlatform();
  final subject = l10n.supportMailSubject(id ?? '—');
  final body = l10n.supportMailTemplate(
    id ?? '—',
    '${info.version} (${info.buildNumber})',
    '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
  );
  final uri = Uri.parse(
    'mailto:$email?subject=${Uri.encodeComponent(subject)}'
    '&body=${Uri.encodeComponent(body)}',
  );

  final opened = await canLaunchUrl(uri) && await launchUrl(uri);
  if (opened || !context.mounted) return;

  await showAppSheet<void>(
    context,
    title: l10n.supportMailTitle,
    closeLabel: l10n.actionClose,
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
          Text(l10n.supportMailFallback(email), style: sheetContext.text.body),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: l10n.actionCopyAddress,
            icon: AppIcons.copy,
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: email));
              if (sheetContext.mounted) {
                Navigator.of(sheetContext).pop();
                AppToast.show(context, l10n.toastCopied);
              }
            },
          ),
        ],
      ),
    ),
  );
}

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

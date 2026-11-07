import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/otp_field.dart';
import '../../../support/presentation/view/support_sheet.dart';
import '../../../wallet/presentation/cubit/wallet_cubit.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/delete_account_cubit.dart';

class DeleteAccountPage extends StatelessWidget {
  const DeleteAccountPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => DeleteAccountCubit(getIt(), getIt<AuthCubit>()),
    child: BlocListener<DeleteAccountCubit, DeleteAccountState>(
      listenWhen: (a, b) => b.step == DeleteStep.done,
      listener: (context, _) {
        AppToast.show(context, context.l10n.deleteDone);
        context.go(AppRoute.home.path);
      },
      child: const _View(),
    ),
  );
}

class _View extends StatefulWidget {
  const _View();

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final state = context.watch<DeleteAccountCubit>().state;
    final cubit = context.read<DeleteAccountCubit>();
    final user = context.watch<AuthCubit>().state.user;
    final balance = context.watch<WalletCubit>().state.balance;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.searchBack,
          onPressed: () => context.pop(),
          icon: HugeIcon(icon: AppIcons.back, size: 24, color: c.textPrimary),
        ),
        title: Text(l10n.deleteTitle, style: context.text.h2),
        centerTitle: false,
      ),
      body: state.step == DeleteStep.warning
          ? _WarningStep(
              balance: balance?.format() ?? r'$0.00',
              failure: state.failure?.localize(l10n),
              loading: state.loading,
              onContinue: cubit.requestCode,
              onCancel: () => context.pop(),
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.page),
              children: [
                Text(l10n.codeTitle, style: context.text.h1),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.deleteCodeBody(user?.email ?? ''),
                  style: context.text.body.copyWith(color: c.textSecondary),
                ),
                const SizedBox(height: AppSpacing.xxl),
                OtpField(
                  controller: _code,
                  hasError: state.wrongCode,
                  onCompleted: cubit.confirm,
                ),
                if (state.wrongCode)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Text(
                      l10n.codeErrorWrong,
                      style: context.text.caption.copyWith(color: c.error),
                    ),
                  ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: l10n.deleteConfirm,
                  variant: AppButtonVariant.danger,
                  loading: state.loading,
                  onPressed: () => cubit.confirm(_code.text),
                ),
              ],
            ),
    );
  }
}

class _WarningStep extends StatelessWidget {
  const _WarningStep({
    required this.balance,
    required this.failure,
    required this.loading,
    required this.onContinue,
    required this.onCancel,
  });

  final String balance;
  final String? failure;
  final bool loading;
  final VoidCallback onContinue;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final bullets = [
      (l10n.deleteBullet1(balance), c.error),
      (l10n.deleteBullet2, c.error),
      (l10n.deleteBullet3, c.success),
      (l10n.deleteBullet4, c.textSecondary),
    ];

    return SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.xl,
                AppSpacing.page,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: c.errorSubtle,
                      borderRadius: BorderRadius.circular(AppRadius.button),
                    ),
                    alignment: Alignment.center,
                    child: HugeIcon(
                      icon: AppIcons.delete,
                      size: 26,
                      color: c.error,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(l10n.deleteWarnTitle, style: context.text.h2),
                  const SizedBox(height: AppSpacing.lg),
                  for (final (text, color) in bullets)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 7, right: 12),
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(text, style: context.text.bodySm),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xs),
                  _SupportNote(onTap: () => showSupportSheet(context)),
                  if (failure != null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: Text(
                        failure!,
                        style: context.text.bodySm.copyWith(color: c.error),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.sm,
              AppSpacing.page,
              AppSpacing.lg,
            ),
            child: Column(
              children: [
                AppButton(
                  label: l10n.actionContinue,
                  variant: AppButtonVariant.danger,
                  loading: loading,
                  onPressed: onContinue,
                ),
                const SizedBox(height: AppSpacing.xs),
                AppButton(
                  label: l10n.actionCancel,
                  variant: AppButtonVariant.ghost,
                  onPressed: onCancel,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportNote extends StatelessWidget {
  const _SupportNote({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final note = l10n.deleteRefundNote;
    final link = l10n.deleteSupportLink;
    final index = note.indexOf(link);
    final textStyle = context.text.bodySm.copyWith(color: c.link);
    return Material(
      color: c.primarySubtle,
      borderRadius: BorderRadius.circular(AppRadius.button),
      child: InkWell(
        key: const ValueKey('delete-support-note'),
        borderRadius: BorderRadius.circular(AppRadius.button),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HugeIcon(icon: AppIcons.info, size: 20, color: c.link),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text.rich(
                  index < 0
                      ? TextSpan(text: note)
                      : TextSpan(
                          children: [
                            TextSpan(text: note.substring(0, index)),
                            TextSpan(
                              text: link,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            TextSpan(text: note.substring(index + link.length)),
                          ],
                        ),
                  style: textStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

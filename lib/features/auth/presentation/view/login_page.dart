import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_environment.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/otp_field.dart';
import '../../../../core/services/device_integrity.dart';
import '../../../../mock/demo_credentials.dart';
import '../../../config/presentation/cubit/config_cubit.dart';
import '../cubit/login_cubit.dart';
import '../cubit/auth_cubit.dart';

/// Passwordless sign-in. Pops `true` when the customer ends up signed in, so
/// whatever sent them here carries on.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<LoginCubit>(),
    child: BlocListener<LoginCubit, LoginState>(
      listenWhen: (a, b) => a.step != b.step && b.step == LoginStep.done,
      listener: (context, _) {
        if (context.canPop()) {
          context.pop(true);
        } else {
          context.go(AppRoute.home.path);
        }
      },
      child: const _LoginView(),
    ),
  );
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    final step = context.select((LoginCubit c) => c.state.step);
    final c = context.colors;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: context.l10n.actionClose,
          onPressed: () {
            if (context.canPop()) {
              context.pop(false);
            } else {
              context.go(AppRoute.home.path);
            }
          },
          icon: HugeIcon(icon: AppIcons.close, size: 24, color: c.textPrimary),
        ),
        title: SvgPicture.asset(
          context.isDark
              ? 'assets/brand/logo_white.svg'
              : 'assets/brand/logo.svg',
          height: 24,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: switch (step) {
            LoginStep.email => const _EmailStep(key: ValueKey('email')),
            LoginStep.code => const _CodeStep(key: ValueKey('code')),
            LoginStep.name ||
            LoginStep.done => const _NameStep(key: ValueKey('name')),
          },
        ),
      ),
    );
  }
}

class _EmailStep extends StatefulWidget {
  const _EmailStep({super.key});

  @override
  State<_EmailStep> createState() => _EmailStepState();
}

class _EmailStepState extends State<_EmailStep> {
  late final TextEditingController _email;
  late final TapGestureRecognizer _termsTap;
  late final TapGestureRecognizer _privacyTap;
  late final _invite = TextEditingController(
    text: getIt<LocalStorage>().getString(StorageKeys.pendingInvite) ?? '',
  );
  bool _accepted = false;

  @override
  void initState() {
    super.initState();
    final previousEmail = context.read<LoginCubit>().state.email;
    _email = TextEditingController(text: previousEmail);
    // Reaching the code step required consent; keep it when editing the email.
    _accepted = previousEmail.isNotEmpty;
    _termsTap = TapGestureRecognizer()..onTap = () => _openDocument('terms');
    _privacyTap = TapGestureRecognizer()
      ..onTap = () => _openDocument('privacy');
  }

  void _openDocument(String id) {
    FocusScope.of(context).unfocus();
    context.push(AppRoute.legalDocument.withParams({'id': id}));
  }

  @override
  void dispose() {
    _email.dispose();
    _invite.dispose();
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  void _submit() => context.read<LoginCubit>().submitEmail(
    email: _email.text,
    accepted: _accepted,
    inviteCode: _invite.text,
  );

  void _toggleAccepted() {
    setState(() => _accepted = !_accepted);
    if (_accepted) context.read<LoginCubit>().clearProblem();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final state = context.watch<LoginCubit>().state;
    final showDemo = AppEnvironment.useMockApi && !AppEnvironment.isProd;
    // No invite code on a rooted/jailbroken device: it would not earn a bonus.
    final referralOn =
        context.watch<ConfigCubit>().state.referralEnabled &&
        !context.watch<DeviceIntegrityCubit>().compromised;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: [
        Text(l10n.loginTitle, style: context.text.h1),
        if (context.watch<AuthCubit>().state.signedOutRemotely) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.signedOutOnDevice,
            style: context.text.bodySm.copyWith(color: c.textSecondary),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.loginBody,
          style: context.text.body.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xxl),
        AppTextField(
          label: l10n.emailLabel,
          hint: l10n.emailHint,
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          errorText: state.problem == LoginProblem.invalidEmail
              ? l10n.loginErrorEmail
              : null,
        ),
        if (showDemo) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.demoAccounts,
            style: context.text.caption.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              ActionChip(
                label: Text(
                  '${l10n.demoNewAccount}: ${DemoCredentials.newEmail}',
                ),
                onPressed: () => _email.text = DemoCredentials.newEmail,
              ),
              ActionChip(
                label: Text(
                  '${l10n.demoExistingAccount}: ${DemoCredentials.existingEmail}',
                ),
                onPressed: () => _email.text = DemoCredentials.existingEmail,
              ),
            ],
          ),
        ],
        // The invite field only exists while the referral programme is on.
        if (referralOn) ...[
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: l10n.inviteLabel,
            controller: _invite,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Semantics(
          container: true,
          explicitChildNodes: true,
          checked: _accepted,
          label: l10n.termsConsent,
          onTap: _toggleAccepted,
          child: InkWell(
            key: const ValueKey('age-consent'),
            onTap: _toggleAccepted,
            excludeFromSemantics: true,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    key: const ValueKey('age-checkbox'),
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : AppConstants.animationFast,
                    curve: Curves.easeOutCubic,
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _accepted ? c.primary : Colors.transparent,
                      border: Border.all(
                        color: state.problem == LoginProblem.notAccepted
                            ? c.error
                            : _accepted
                            ? c.primary
                            : c.textSecondary,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: _accepted
                        ? Center(
                            child: HugeIcon(
                              icon: AppIcons.check,
                              size: 17,
                              color: c.textOnPrimary,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: l10n.termsConsentStart),
                          TextSpan(
                            text: l10n.termsOfUseLink,
                            recognizer: _termsTap,
                            style: TextStyle(
                              color: c.link,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                              decorationColor: c.link,
                            ),
                          ),
                          TextSpan(text: l10n.termsConsentMiddle),
                          TextSpan(
                            text: l10n.privacyPolicyLink,
                            recognizer: _privacyTap,
                            style: TextStyle(
                              color: c.link,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                              decorationColor: c.link,
                            ),
                          ),
                          TextSpan(text: l10n.termsConsentEnd),
                        ],
                      ),
                      key: const ValueKey('consent-text'),
                      style: context.text.bodySm.copyWith(color: c.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (state.problem == LoginProblem.notAccepted)
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.sm + 24 + AppSpacing.md,
              top: AppSpacing.sm,
            ),
            child: Text(
              l10n.loginErrorTerms,
              style: context.text.caption.copyWith(color: c.error),
            ),
          ),
        if (state.failure != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Text(
              state.failure!.localize(l10n),
              style: context.text.bodySm.copyWith(color: c.error),
            ),
          ),
        const SizedBox(height: AppSpacing.xl),
        _ContinueAction(loading: state.loading, onPressed: _submit),
      ],
    );
  }
}

class _CodeStep extends StatefulWidget {
  const _CodeStep({super.key});

  @override
  State<_CodeStep> createState() => _CodeStepState();
}

class _CodeStepState extends State<_CodeStep> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final digits = (data?.text ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;
    _code.text = digits.length > 6 ? digits.substring(0, 6) : digits;
  }

  static String _clock(int seconds) =>
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final state = context.watch<LoginCubit>().state;
    final showDemo = AppEnvironment.useMockApi && !AppEnvironment.isProd;
    final cubit = context.read<LoginCubit>();

    final error = switch (state.problem) {
      LoginProblem.wrongCode => l10n.codeErrorWrong,
      LoginProblem.codeExpired => l10n.codeErrorExpired,
      LoginProblem.tooMany => l10n.codeErrorTooMany,
      _ => null,
    };

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: c.primarySubtle,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: HugeIcon(icon: AppIcons.mail, size: 24, color: c.primary),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(l10n.codeTitle, style: context.text.h1),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.codeInstructions,
          style: context.text.body.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xxl),
        DecoratedBox(
          decoration: BoxDecoration(
            color: c.surface,
            border: Border.all(color: c.border),
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.emailLabel,
                        style: context.text.caption.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
                      Text(
                        state.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodyMed.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                TextButton(
                  onPressed: cubit.changeEmail,
                  style: TextButton.styleFrom(foregroundColor: c.link),
                  child: Text(l10n.changeEmail),
                ),
              ],
            ),
          ),
        ),
        if (showDemo) ...[
          const SizedBox(height: AppSpacing.md),
          DecoratedBox(
            decoration: BoxDecoration(
              color: c.primarySubtle,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  HugeIcon(icon: AppIcons.info, size: 18, color: c.link),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      l10n.demoCodeHint(DemoCredentials.code),
                      style: context.text.bodySm.copyWith(color: c.link),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xxl),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.codeLabel,
                style: context.text.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (state.loading)
              SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: c.primary,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        OtpField(
          controller: _code,
          enabled: !state.loading,
          hasError: error != null,
          onChanged: (_) => cubit.clearProblem(),
          onCompleted: cubit.submitCode,
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              error,
              style: context.text.bodySm.copyWith(color: c.error),
            ),
          ),
        if (state.failure != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              state.failure!.localize(l10n),
              style: context.text.bodySm.copyWith(color: c.error),
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: state.loading ? null : _paste,
            style: TextButton.styleFrom(foregroundColor: c.link),
            child: Text(l10n.actionPasteCode),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Divider(color: c.border),
        const SizedBox(height: AppSpacing.md),
        if (!showDemo) ...[
          Text(
            l10n.checkSpam,
            textAlign: TextAlign.center,
            style: context.text.bodySm.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Center(
          child: TextButton(
            onPressed: state.resendIn > 0 || state.loading
                ? null
                : cubit.resend,
            style: TextButton.styleFrom(foregroundColor: c.link),
            child: Text(
              state.resendIn > 0
                  ? l10n.resendIn(_clock(state.resendIn))
                  : l10n.resendNow,
            ),
          ),
        ),
      ],
    );
  }
}

class _NameStep extends StatefulWidget {
  const _NameStep({super.key});

  @override
  State<_NameStep> createState() => _NameStepState();
}

class _NameStepState extends State<_NameStep> {
  late final TextEditingController _name;

  @override
  void initState() {
    super.initState();
    final initialName = context
        .read<LoginCubit>()
        .suggestedName
        .characters
        .take(40)
        .toString();
    _name = TextEditingController(text: initialName)
      ..selection = TextSelection(
        baseOffset: 0,
        extentOffset: initialName.length,
      );
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final state = context.watch<LoginCubit>().state;
    final cubit = context.read<LoginCubit>();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: [
        Text(l10n.nameTitle, style: context.text.h1),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.nameBody,
          style: context.text.body.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xxl),
        AppTextField(
          controller: _name,
          hint: l10n.nameHint,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.givenName],
          onSubmitted: cubit.saveName,
          maxLength: 40,
        ),
        const SizedBox(height: AppSpacing.xl),
        _ContinueAction(
          loading: state.loading,
          onPressed: () => cubit.saveName(_name.text),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: l10n.actionSkip,
          variant: AppButtonVariant.ghost,
          onPressed: cubit.skipName,
        ),
      ],
    );
  }
}

class _ContinueAction extends StatelessWidget {
  const _ContinueAction({required this.loading, required this.onPressed});

  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(AppRadius.button),
      boxShadow: [
        BoxShadow(
          color: context.colors.primary.withValues(alpha: 0.2),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: AppButton(
      label: context.l10n.actionContinue,
      loading: loading,
      onPressed: onPressed,
    ),
  );
}

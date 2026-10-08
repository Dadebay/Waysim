import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/bloc/async_cubit.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters/labels.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../core/services/device_integrity.dart';
import '../../../config/presentation/cubit/config_cubit.dart';
import '../../domain/entities/referral.dart';

/// "Invite friends": the code, the link, the numbers and the rules.
/// Not reachable while the programme is switched off on the server.
class ReferralPage extends StatelessWidget {
  const ReferralPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<AsyncCubit<ReferralInfo>>()..load(),
    child: const _View(),
  );
}

class _View extends StatelessWidget {
  const _View();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final enabled = context.watch<ConfigCubit>().state.referralEnabled;
    final state = context.watch<AsyncCubit<ReferralInfo>>().state;

    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppBar(
        backgroundColor: c.surface,
        leading: IconButton(
          tooltip: l10n.searchBack,
          onPressed: () => context.pop(),
          icon: HugeIcon(icon: AppIcons.back, size: 24, color: c.textPrimary),
        ),
        title: Text(l10n.referralTitle, style: context.text.h2),
        centerTitle: true,
      ),
      body: !enabled
          ? EmptyState(icon: AppIcons.gift, title: l10n.referralEmpty)
          : switch (state) {
              AsyncLoading() => const Padding(
                padding: EdgeInsets.all(AppSpacing.page),
                child: Skeleton(child: SkeletonBox(height: 280, radius: 22)),
              ),
              AsyncFailure(:final failure) => ErrorView(
                failure: failure,
                onRetry: () => context.read<AsyncCubit<ReferralInfo>>().load(),
              ),
              AsyncData(:final data) => _Content(info: data),
            },
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.info});

  final ReferralInfo info;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final reward = info.reward.format(withCents: info.reward.cents % 100 != 0);
    final rules = [
      l10n.referralRule1,
      l10n.referralRule2,
      l10n.referralRule3,
      l10n.referralRule4,
      l10n.referralRule5,
    ];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: [
        if (context.watch<DeviceIntegrityCubit>().compromised) ...[
          DecoratedBox(
            decoration: BoxDecoration(
              color: c.warningSubtle,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.integrityWarningTitle,
                    style: context.text.bodyMed.copyWith(
                      color: c.warning,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(l10n.integrityWarningBody, style: context.text.bodySm),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        Container(
          key: const ValueKey('referral-hero'),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: c.primary,
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: [
              BoxShadow(
                color: c.primary.withValues(alpha: 0.2),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -45,
                top: 70,
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: c.textOnPrimary.withValues(alpha: 0.09),
                      width: 22,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.referralHeroTitle(reward),
                      style: context.text.h1.copyWith(color: c.textOnPrimary),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.referralHeroBody(reward),
                      style: context.text.bodySm.copyWith(
                        color: c.textOnPrimary.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: c.textOnPrimary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                          color: c.textOnPrimary.withValues(alpha: 0.28),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: AppSpacing.lg,
                          top: AppSpacing.sm,
                          bottom: AppSpacing.sm,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.referralYourCode,
                                    style: context.text.caption.copyWith(
                                      color: c.textOnPrimary.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    info.code,
                                    style: context.text.h2.copyWith(
                                      color: c.textOnPrimary,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: l10n.actionCopy,
                              style: IconButton.styleFrom(
                                backgroundColor: c.textOnPrimary.withValues(
                                  alpha: 0.14,
                                ),
                              ),
                              onPressed: () async {
                                await Clipboard.setData(
                                  ClipboardData(text: info.code),
                                );
                                if (context.mounted) {
                                  AppToast.show(context, l10n.toastCopied);
                                }
                              },
                              icon: HugeIcon(
                                icon: AppIcons.copy,
                                size: 20,
                                color: c.textOnPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      info.link.toString().replaceFirst('https://', ''),
                      style: context.text.bodySm.copyWith(
                        color: c.textOnPrimary.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Material(
                      color: c.background,
                      borderRadius: BorderRadius.circular(AppRadius.button),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.button),
                        onTap: () {
                          getIt<AnalyticsService>().shared('referral');
                          SharePlus.instance.share(
                            ShareParams(
                              text: l10n.referralShareText(
                                info.link.toString(),
                              ),
                            ),
                          );
                        },
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 52),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              HugeIcon(
                                icon: AppIcons.share,
                                size: 20,
                                color: c.primary,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                l10n.referralShare,
                                style: context.text.label.copyWith(
                                  color: c.link,
                                ),
                              ),
                            ],
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
        const SizedBox(height: AppSpacing.lg),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          mainAxisExtent: 82,
          children: [
            _Stat(l10n.referralStatInvited, '${info.invited}'),
            _Stat(
              l10n.referralStatCredited,
              info.credited.format(),
              color: c.success,
            ),
            _Stat(l10n.referralStatPending, '${info.pending}'),
            _Stat(l10n.referralStatRejected, '${info.rejected}'),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _ReferralSurface(
          key: const ValueKey('referral-rules-card'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.referralRulesTitle,
                style: context.text.h3.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final rule in rules)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 7,
                          right: AppSpacing.md,
                        ),
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: c.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Expanded(child: Text(rule, style: context.text.bodySm)),
                    ],
                  ),
                ),
              TextButton(
                onPressed: () => context.push(
                  AppRoute.legalDocument.withParams({'id': 'terms'}),
                ),
                style: TextButton.styleFrom(
                  minimumSize: const Size(44, 44),
                  foregroundColor: c.link,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  l10n.referralFullTerms,
                  style: context.text.bodyMed.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.referralYourInvites.toUpperCase(),
          style: context.text.caption.copyWith(
            color: c.textSecondary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (info.invites.isNotEmpty)
          _ReferralSurface(
            key: const ValueKey('referral-invites-card'),
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final (index, invite) in info.invites.indexed) ...[
                  if (index > 0)
                    Divider(height: 1, indent: AppSpacing.lg, color: c.border),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: _InviteTile(invite: invite),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _ReferralSurface extends StatelessWidget {
  const _ReferralSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
            color: c.shadow,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, {this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
            color: c.shadow,
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: context.text.caption.copyWith(color: c.textSecondary),
            ),
            Text(value, style: context.text.h1.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

class _InviteTile extends StatelessWidget {
  const _InviteTile({required this.invite});

  final Invite invite;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final (label, fg, bg) = switch (invite.status) {
      InviteStatus.credited => (
        l10n.referralInviteCredited(
          invite.reward?.format(withCents: false) ?? '',
        ),
        c.successText,
        c.successSubtle,
      ),
      InviteStatus.pending => (
        l10n.referralStatPending,
        c.warning,
        c.warningSubtle,
      ),
      InviteStatus.rejected => (
        l10n.referralStatRejected,
        c.errorText,
        c.errorSubtle,
      ),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invite.maskedEmail,
                  style: context.text.bodyMed.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  l10n.referralInviteSignedUp(
                    l10n.shortDate(invite.registeredAt),
                  ),
                  style: context.text.caption.copyWith(color: c.textSecondary),
                ),
              ],
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 5,
              ),
              child: Text(
                label,
                style: context.text.caption.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

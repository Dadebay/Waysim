import 'package:flutter/material.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/localization/failure_localizer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/auth_gate.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters/money.dart';
import '../../../../core/widgets/app_hero.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../config/presentation/cubit/config_cubit.dart';
import '../../../wallet/presentation/cubit/wallet_cubit.dart';

/// Third tab. A guest is invited to sign up; a signed-in customer sees the
/// account, the balance and the way to everything else.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthCubit>().state;
    final background = _profileBackground(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: background,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
      ),
      child: ColoredBox(
        key: const ValueKey('profile-system-background'),
        color: background,
        child: SafeArea(
          bottom: false,
          child: auth.isSignedIn ? const _SignedIn() : const _Guest(),
        ),
      ),
    );
  }
}

Color _profileBackground(BuildContext context) {
  final c = context.colors;
  return Color.lerp(c.background, c.textPrimary, 0.04)!;
}

class _Guest extends StatelessWidget {
  const _Guest();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ColoredBox(
      key: const ValueKey('profile-background'),
      color: _profileBackground(context),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        children: [
          const SizedBox(height: AppSpacing.xl),
          Text(l10n.profileTitle, style: context.text.h1),
          const SizedBox(height: AppSpacing.xxl),
          _GuestHero(onSignUp: () => requireSignIn(context)),
          const SizedBox(height: AppSpacing.lg),
          _GuestMenu(
            settingsLabel: l10n.settings,
            moreLabel: l10n.more,
            onSettings: () => context.push(AppRoute.settings.path),
            onMore: () => context.push(AppRoute.legal.path),
          ),
          const SizedBox(height: 104),
        ],
      ),
    );
  }
}

class _GuestHero extends StatelessWidget {
  const _GuestHero({required this.onSignUp});

  final VoidCallback onSignUp;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    return Container(
      key: const ValueKey('profile-guest-hero'),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.primary,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(
            color: c.primary.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -42,
            top: -45,
            child: Container(
              width: 190,
              height: 190,
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
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: c.textOnPrimary.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  alignment: Alignment.center,
                  child: HugeIcon(
                    icon: AppIcons.profile,
                    size: 23,
                    color: c.textOnPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.profileGuestTitle,
                  style: context.text.h2.copyWith(color: c.textOnPrimary),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.profileGuestBody,
                  style: context.text.bodySm.copyWith(
                    color: c.textOnPrimary.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Material(
                  color: c.textOnPrimary,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: InkWell(
                    key: const ValueKey('profile-sign-up'),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    onTap: onSignUp,
                    child: SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          l10n.signUp,
                          style: context.text.label.copyWith(color: c.primary),
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
    );
  }
}

class _GuestMenu extends StatelessWidget {
  const _GuestMenu({
    required this.settingsLabel,
    required this.moreLabel,
    required this.onSettings,
    required this.onMore,
  });

  final String settingsLabel;
  final String moreLabel;
  final VoidCallback onSettings;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      key: const ValueKey('profile-guest-menu'),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Column(
          children: [
            _GuestMenuRow(
              icon: AppIcons.settings,
              label: settingsLabel,
              heroTag: AppHeroTags.settingsTitle,
              onTap: onSettings,
            ),
            Divider(height: 1, indent: 62, color: c.border),
            _GuestMenuRow(
              icon: AppIcons.document,
              label: moreLabel,
              heroTag: AppHeroTags.moreTitle,
              onTap: onMore,
            ),
          ],
        ),
      ),
    );
  }
}

class _GuestMenuRow extends StatelessWidget {
  const _GuestMenuRow({
    required this.icon,
    required this.label,
    required this.heroTag,
    required this.onTap,
  });

  final AppIconData icon;
  final String label;
  final String heroTag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: c.primarySubtle,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                alignment: Alignment.center,
                child: HugeIcon(icon: icon, size: 18, color: c.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppHero(
                  tag: heroTag,
                  child: Material(
                    type: MaterialType.transparency,
                    child: Text(label, style: context.text.bodyMed),
                  ),
                ),
              ),
              HugeIcon(
                icon: AppIcons.chevronRight,
                size: 18,
                color: c.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignedIn extends StatelessWidget {
  const _SignedIn();

  Future<void> _confirmSignOut(BuildContext context) async {
    final l10n = context.l10n;
    final auth = context.read<AuthCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _SignOutDialog(email: auth.state.user?.email),
    );
    if (confirmed == true) {
      try {
        await auth.signOut();
      } on AppException catch (e) {
        if (context.mounted) {
          AppToast.show(context, e.toFailure().localize(l10n));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final auth = context.watch<AuthCubit>().state;
    final user = auth.user!;
    final balance = context.watch<WalletCubit>().state.balance;
    final config = context.watch<ConfigCubit>().state;
    final initial = (user.name?.isNotEmpty ?? false)
        ? user.name!.characters.first.toUpperCase()
        : user.email.characters.first.toUpperCase();

    return ColoredBox(
      key: const ValueKey('profile-background'),
      color: _profileBackground(context),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        children: [
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.primarySubtle,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  initial,
                  style: context.text.h2.copyWith(color: c.link),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (user.name?.isNotEmpty ?? false)
                          ? user.name!
                          : user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.h2,
                    ),
                    if (user.name?.isNotEmpty ?? false)
                      Text(
                        user.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySm.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _IdChip(id: user.publicId),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _BalanceCard(balance: balance),
          const SizedBox(height: AppSpacing.lg),
          _ProfileMenuGroup(
            key: const ValueKey('profile-account-menu'),
            rows: [
              _ProfileRow(
                icon: AppIcons.document,
                label: l10n.orders,
                onTap: () => context.push(AppRoute.orders.path),
              ),
              if (config.referralEnabled)
                _ProfileRow(
                  icon: AppIcons.gift,
                  label: l10n.inviteFriends,
                  trailing: _Pill(
                    '+${Money(config.referralRewardCents).format(withCents: config.referralRewardCents % 100 != 0)}',
                  ),
                  onTap: () => context.push(AppRoute.referral.path),
                ),
              _ProfileRow(
                icon: AppIcons.phone,
                label: l10n.myDevices,
                onTap: () => context.push(AppRoute.devices.path),
              ),
              _ProfileRow(
                icon: AppIcons.settings,
                label: l10n.settings,
                heroTag: AppHeroTags.settingsTitle,
                onTap: () => context.push(AppRoute.settings.path),
              ),
              _ProfileRow(
                icon: AppIcons.document,
                label: l10n.more,
                heroTag: AppHeroTags.moreTitle,
                onTap: () => context.push(AppRoute.legal.path),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _ProfileMenuGroup(
            key: const ValueKey('profile-danger-menu'),
            rows: [
              _ProfileRow(
                icon: AppIcons.delete,
                label: l10n.deleteAccount,
                danger: true,
                showChevron: false,
                onTap: () => context.push(AppRoute.deleteAccount.path),
              ),
              _ProfileRow(
                icon: AppIcons.logout,
                label: l10n.signOut,
                showChevron: false,
                onTap: () async {
                  await _confirmSignOut(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 104),
        ],
      ),
    );
  }
}

class _SignOutDialog extends StatelessWidget {
  const _SignOutDialog({this.email});

  final String? email;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    return AlertDialog(
      key: const ValueKey('sign-out-dialog'),
      backgroundColor: c.background,
      surfaceTintColor: Colors.transparent,
      elevation: 12,
      shadowColor: c.shadow,
      constraints: const BoxConstraints(maxWidth: 380),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.xxl,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sheet),
        side: BorderSide(color: c.border),
      ),
      scrollable: true,
      iconPadding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      icon: Center(
        child: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: c.primarySubtle,
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          alignment: Alignment.center,
          child: HugeIcon(icon: AppIcons.logout, size: 34, color: c.link),
        ),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      title: Text(
        l10n.signOutConfirmTitle,
        textAlign: TextAlign.center,
        style: context.text.h2,
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.signOutConfirmBody,
            textAlign: TextAlign.center,
            style: context.text.body.copyWith(color: c.textSecondary),
          ),
          if (email?.isNotEmpty ?? false) ...[
            const SizedBox(height: AppSpacing.xl),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: c.border),
              ),
              child: Row(
                children: [
                  HugeIcon(
                    icon: AppIcons.mail,
                    size: 20,
                    color: c.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      email!,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodyMed,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppButton(
              label: l10n.signOut,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: l10n.actionCancel,
              variant: AppButtonVariant.secondary,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ],
    );
  }
}

class _IdChip extends StatelessWidget {
  const _IdChip({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    return Material(
      color: c.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        side: BorderSide(color: c.border),
      ),
      child: InkWell(
        key: const ValueKey('profile-id-chip'),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: id));
          if (context.mounted &&
              (kIsWeb || defaultTargetPlatform != TargetPlatform.android)) {
            AppToast.show(context, l10n.toastCopied);
          }
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.profileId(id),
                  style: context.text.caption.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                HugeIcon(icon: AppIcons.copy, size: 14, color: c.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance});

  final Money? balance;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    return Container(
      key: const ValueKey('profile-balance-card'),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.primary,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(
            color: c.primary.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -45,
            top: -65,
            child: Container(
              width: 190,
              height: 190,
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
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.balanceLabel,
                        style: context.text.bodySm.copyWith(
                          color: c.textOnPrimary.withValues(alpha: 0.8),
                        ),
                      ),
                      Text(
                        balance?.format() ?? '—',
                        style: context.text.h1.copyWith(color: c.textOnPrimary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Material(
                  color: c.textOnPrimary,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    onTap: () => context.push(AppRoute.balanceTopUp.path),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      child: Text(
                        '+ ${l10n.actionTopUp}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.label.copyWith(color: c.primary),
                      ),
                    ),
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

class _ProfileMenuGroup extends StatelessWidget {
  const _ProfileMenuGroup({super.key, required this.rows});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Column(
          children: [
            for (final (i, row) in rows.indexed) ...[
              if (i > 0) Divider(height: 1, indent: 62, color: c.border),
              row,
            ],
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.successSubtle,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        child: Text(
          text,
          style: context.text.caption.copyWith(
            color: c.success,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.danger = false,
    this.showChevron = true,
    this.heroTag,
  });

  final AppIconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool danger;
  final bool showChevron;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = danger ? c.error : c.textPrimary;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: danger ? c.errorSubtle : c.primarySubtle,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                alignment: Alignment.center,
                child: HugeIcon(
                  icon: icon,
                  size: 18,
                  color: danger ? c.error : c.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: heroTag == null
                    ? Text(
                        label,
                        style: context.text.bodyMed.copyWith(color: color),
                      )
                    : AppHero(
                        tag: heroTag!,
                        child: Material(
                          type: MaterialType.transparency,
                          child: Text(
                            label,
                            style: context.text.bodyMed.copyWith(color: color),
                          ),
                        ),
                      ),
              ),
              ?trailing,
              if (showChevron) ...[
                const SizedBox(width: AppSpacing.sm),
                HugeIcon(
                  icon: AppIcons.chevronRight,
                  size: 18,
                  color: c.textSecondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

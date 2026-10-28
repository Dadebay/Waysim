import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/auth_gate.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../wallet/presentation/cubit/wallet_cubit.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final auth = context.watch<AuthCubit>().state;
    final name = auth.user?.name;
    final greeting = name == null || name.isEmpty
        ? l10n.greeting
        : l10n.greetingNamed(name);

    return Row(
      children: [
        Expanded(
          child: Text(
            greeting,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.text.h1,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        if (auth.isSignedIn)
          const BalancePill()
        else if (auth.status == AuthStatus.guest)
          AppButton(
            label: l10n.signIn,
            size: AppButtonSize.sm,
            expand: false,
            onPressed: () => requireSignIn(context),
          ),
      ],
    );
  }
}

class BalancePill extends StatelessWidget {
  const BalancePill({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final balance = context.watch<WalletCubit>().state.balance;

    return Semantics(
      button: true,
      label: '${context.l10n.balanceLabel} ${balance?.format() ?? ''}',
      excludeSemantics: true,
      child: Material(
        color: c.primarySubtle,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          onTap: () => context.push(AppRoute.balanceTopUp.path),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.only(left: AppSpacing.lg, right: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    balance?.format() ?? '—',
                    style: context.text.bodyMed.copyWith(
                      color: c.link,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: c.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: HugeIcon(
                        icon: AppIcons.add,
                        size: 18,
                        color: c.textOnPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

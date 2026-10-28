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
import '../../../../core/widgets/country_row.dart';
import '../../../../core/widgets/flag_icon.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/error/failure.dart';
import '../../../esim/presentation/esim_installer.dart';
import '../../../esim/presentation/esim_labels.dart';
import '../../../esim/domain/entities/esim.dart';
import '../cubit/purchase_cubit.dart';
import '../../../../core/utils/formatters/money.dart';
import '../purchase_subject.dart';

class PurchasePage extends StatelessWidget {
  const PurchasePage({super.key, required this.subject});

  final PurchaseSubject subject;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<PurchaseCubit>(
      param1: PurchaseArgs(subject.package, esimId: subject.esimId),
    )..run(),
    child: _PurchaseView(subject: subject),
  );
}

class _PurchaseView extends StatelessWidget {
  const _PurchaseView({required this.subject});

  final PurchaseSubject subject;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PurchaseCubit>().state;

    return PopScope(
      canPop: state.phase != PurchasePhase.processing,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.page),
            child: SizedBox.expand(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                layoutBuilder: (current, previous) => Stack(
                  fit: StackFit.expand,
                  children: [...previous, ?current],
                ),
                child: switch (state.phase) {
                  PurchasePhase.processing => _Processing(
                    key: ValueKey('processing-${state.slow}'),
                    slow: state.slow,
                  ),
                  PurchasePhase.success => _Success(
                    key: const ValueKey('success'),
                    subject: subject,
                    esim: state.esim!,
                  ),
                  PurchasePhase.failed => _Failed(
                    key: const ValueKey('failed'),
                    failure: state.failure!,
                    newPrice: state.newPrice,
                  ),
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Processing extends StatelessWidget {
  const _Processing({super.key, required this.slow});

  final bool slow;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    return Column(
      children: [
        const Spacer(),
        const SizedBox.square(
          dimension: 64,
          child: CircularProgressIndicator(strokeWidth: 4),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          l10n.orderPreparing,
          style: context.text.h2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          slow ? l10n.orderSlow : l10n.orderPreparingHint,
          style: context.text.body.copyWith(color: c.textSecondary),
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        if (slow)
          AppButton(
            label: l10n.actionGoToMyEsim,
            onPressed: () => context.go(AppRoute.myEsim.path),
          ),
      ],
    );
  }
}

class _Success extends StatelessWidget {
  const _Success({super.key, required this.subject, required this.esim});

  final PurchaseSubject subject;
  final Esim esim;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final topUp = subject.isTopUp;

    return Column(
      children: [
        const Spacer(),
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: c.successSubtle,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: HugeIcon(icon: AppIcons.check, size: 44, color: c.success),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          topUp ? l10n.topUpAddedTitle : l10n.esimReadyTitle,
          style: context.text.display,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          topUp ? l10n.topUpAddedBody : l10n.esimReadyBody,
          style: context.text.body.copyWith(color: c.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xxl),
        DecoratedBox(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: c.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                subject.flagCode == null
                    ? const RegionIcon(size: 40)
                    : FlagIcon(subject.flagCode!, size: 40),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.esimTitle(esim), style: context.text.h3),
                      Text(
                        l10n.esimPlan(esim),
                        style: context.text.bodySm.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(
                  label: esim.status.label(l10n),
                  tone: esim.status.tone,
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        if (topUp)
          AppButton(label: l10n.actionDone, onPressed: () => context.pop(true))
        else ...[
          AppButton(
            label: l10n.esimInstall,
            onPressed: () => installEsim(context, esim),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.installArrivalNote,
            textAlign: TextAlign.center,
            style: context.text.caption.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: l10n.actionLater,
            variant: AppButtonVariant.ghost,
            onPressed: () => context.go(AppRoute.myEsim.path),
          ),
        ],
      ],
    );
  }
}

class _Failed extends StatelessWidget {
  const _Failed({super.key, required this.failure, required this.newPrice});

  final Failure failure;
  final Money? newPrice;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final priceChanged = failure.code == ApiCodes.priceChanged;
    final body = priceChanged && newPrice != null
        ? l10n.orderPriceChanged(newPrice!.format())
        : failure.code == ApiCodes.insufficientBalance
        ? l10n.insufficientTitle
        : failure.localize(l10n);

    return Column(
      children: [
        const Spacer(),
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: c.errorSubtle,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: HugeIcon(icon: AppIcons.error, size: 44, color: c.error),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          l10n.orderFailedTitle,
          style: context.text.h1,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          body,
          style: context.text.body.copyWith(color: c.textSecondary),
          textAlign: TextAlign.center,
        ),
        if (!priceChanged) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.orderFailedBody,
            style: context.text.bodySm.copyWith(color: c.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
        const Spacer(),
        if (!priceChanged)
          AppButton(
            label: l10n.actionTryAgain,
            onPressed: () => context.read<PurchaseCubit>().run(),
          ),
        if (!priceChanged) const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: l10n.orderBackToPlans,
          variant: priceChanged
              ? AppButtonVariant.primary
              : AppButtonVariant.ghost,
          onPressed: () => context.pop(false),
        ),
      ],
    );
  }
}

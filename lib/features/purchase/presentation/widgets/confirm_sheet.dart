import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters/money.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/country_row.dart';
import '../../../../core/widgets/flag_icon.dart';
import '../../../wallet/presentation/cubit/wallet_cubit.dart';
import '../purchase_subject.dart';

sealed class ConfirmResult {
  const ConfirmResult();
}

class ConfirmPay extends ConfirmResult {
  const ConfirmPay();
}

class ConfirmTopUp extends ConfirmResult {
  const ConfirmTopUp(this.missing);

  final Money missing;
}

Future<ConfirmResult?> showConfirmSheet(
  BuildContext context,
  PurchaseSubject subject,
) {
  final l10n = context.l10n;
  return showAppSheet<ConfirmResult>(
    context,
    title: l10n.confirmTitle,
    closeLabel: l10n.actionClose,
    builder: (_) => _Confirm(subject: subject),
  );
}

class _Confirm extends StatelessWidget {
  const _Confirm({required this.subject});

  final PurchaseSubject subject;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final balance = context.watch<WalletCubit>().state.balance;
    final price = subject.package.price;
    final after = balance == null ? null : balance - price;
    final short = after != null && after.isNegative;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        0,
        AppSpacing.page,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
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
                        Text(subject.title, style: context.text.h3),
                        Text(
                          subject.planLine,
                          style: context.text.bodySm.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _Line(l10n.confirmPrice, price.format()),
          const SizedBox(height: AppSpacing.sm),
          _Line(l10n.confirmBalanceNow, balance?.format() ?? '—'),
          const SizedBox(height: AppSpacing.sm),
          Divider(color: c.border),
          const SizedBox(height: AppSpacing.sm),
          _Line(
            l10n.confirmBalanceAfter,
            after?.format() ?? '—',
            strong: true,
            color: short ? c.error : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (short) ...[
            DecoratedBox(
              decoration: BoxDecoration(
                color: c.errorSubtle,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HugeIcon(icon: AppIcons.error, size: 20, color: c.error),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.insufficientTitle,
                            style: context.text.bodyMed.copyWith(
                              color: c.errorText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            l10n.insufficientBody((-after).format()),
                            style: context.text.bodySm.copyWith(
                              color: c.errorText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: l10n.insufficientAction((-after).format()),
              onPressed: () => Navigator.of(context).pop(ConfirmTopUp(-after)),
            ),
          ] else ...[
            Text(
              l10n.confirmConsent,
              style: context.text.caption.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: l10n.confirmPay(price.format()),

              onPressed: balance == null
                  ? null
                  : () => Navigator.of(context).pop(const ConfirmPay()),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: l10n.actionCancel,
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.value, {this.strong = false, this.color});

  final String label;
  final String value;
  final bool strong;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final weight = strong ? FontWeight.w700 : FontWeight.w500;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: context.text.bodyMed.copyWith(
              color: strong ? c.textPrimary : c.textSecondary,
              fontWeight: weight,
            ),
          ),
        ),
        Text(
          value,
          style: context.text.bodyMed.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

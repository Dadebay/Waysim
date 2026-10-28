import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/bloc/async_cubit.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters/labels.dart';
import '../../../../core/utils/formatters/money.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/wallet_entities.dart';
import '../../domain/repositories/wallet_repository.dart';

class PaymentDetailPage extends StatefulWidget {
  const PaymentDetailPage({super.key, required this.id});

  final String id;

  @override
  State<PaymentDetailPage> createState() => _PaymentDetailPageState();
}

class _PaymentDetailPageState extends State<PaymentDetailPage> {
  late final AsyncCubit<TopUpSession> _payment;
  late final Timer _poll;
  late final AppLifecycleListener _lifecycle;
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    _payment = AsyncCubit<TopUpSession>(
      () => getIt<WalletRepository>().payment(widget.id),
    )..load();
    _poll = Timer.periodic(const Duration(seconds: 10), (_) {
      final session = _payment.state.dataOrNull;
      if (_visible &&
          session != null &&
          (session.status == TopUpStatus.waiting ||
              session.status == TopUpStatus.confirming ||
              session.status == TopUpStatus.review)) {
        unawaited(_payment.load(silent: true));
      }
    });
    _lifecycle = AppLifecycleListener(
      onResume: () {
        _visible = true;
        unawaited(_payment.load(silent: true));
      },
      onPause: () => _visible = false,
      onInactive: () => _visible = false,
    );
  }

  @override
  void dispose() {
    _poll.cancel();
    _lifecycle.dispose();
    _payment.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: _payment,
    child: _PaymentDetailView(payment: _payment),
  );
}

class _PaymentDetailView extends StatelessWidget {
  const _PaymentDetailView({required this.payment});

  final AsyncCubit<TopUpSession> payment;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final state = context.watch<AsyncCubit<TopUpSession>>().state;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.searchBack,
          onPressed: () => context.pop(),
          icon: HugeIcon(icon: AppIcons.back, size: 24, color: c.textPrimary),
        ),
        title: Text(l10n.paymentDetailTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: switch (state) {
          AsyncLoading() => const SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.page),
            child: SkeletonList(count: 5),
          ),
          AsyncFailure(:final failure) => ErrorView(
            failure: failure,
            onRetry: payment.load,
          ),
          AsyncData(:final data) => _PaymentDetails(
            session: data,
            refresh: () => payment.load(silent: true),
          ),
        },
      ),
    );
  }
}

class _PaymentDetails extends StatelessWidget {
  const _PaymentDetails({required this.session, required this.refresh});

  final TopUpSession session;
  final Future<void> Function() refresh;

  String _status(AppLocalizations l10n) => switch (session.status) {
    TopUpStatus.waiting => l10n.cryptoWaitingPayment,
    TopUpStatus.confirming => l10n.cryptoStepConfirmations,
    TopUpStatus.credited => l10n.orderCompleted,
    TopUpStatus.review => l10n.paymentReview,
    TopUpStatus.expired => l10n.topUpExpiredTitle,
    TopUpStatus.failed => l10n.paymentFailed,
  };

  String? _reviewBody(AppLocalizations l10n) => switch (session.rawStatus) {
    'review_overpaid' => l10n.paymentDetailOverpaid,
    'review_underpaid' => l10n.paymentDetailUnderpaid,
    'review_late' => l10n.paymentDetailLate,
    _ when session.status == TopUpStatus.review => l10n.paymentDetailReview,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final crypto = session.crypto;
    final reviewBody = _reviewBody(l10n);
    final paid = crypto?.paidAmountText;
    final hasPaidAmount = paid != null && (num.tryParse(paid) ?? 0) > 0;
    final explanation =
        reviewBody ??
        switch (session.status) {
          TopUpStatus.expired => l10n.topUpExpiredBody,
          TopUpStatus.failed => l10n.paymentFailedBody,
          _ => null,
        };
    final financialRows = <_DetailRow>[
      if (crypto != null)
        _DetailRow(
          label: l10n.paymentDetailExpected,
          value: '${crypto.amountText} ${crypto.coin}',
        ),
      if (crypto != null && hasPaidAmount)
        _DetailRow(
          label: l10n.paymentDetailReceived,
          value: '$paid ${crypto.coin}',
          emphasized: true,
        ),
      if (crypto?.feeCents != null)
        _DetailRow(
          label: l10n.paymentDetailFee,
          value: Money(crypto!.feeCents!).format(),
        ),
      if (crypto?.totalCents != null)
        _DetailRow(
          label: l10n.paymentDetailTotal,
          value: Money(crypto!.totalCents!).format(),
          emphasized: true,
        ),
      if (session.creditedAmount != null)
        _DetailRow(
          label: l10n.paymentDetailCredited,
          value: session.creditedAmount!.format(),
          emphasized: true,
        ),
    ];
    final transactionRows = <_DetailRow>[
      if (session.publicNo != null)
        _DetailRow(
          label: l10n.paymentDetailNumber,
          value: '#${session.publicNo}',
        ),
      if (session.createdAt != null)
        _DetailRow(
          label: l10n.paymentDetailDate,
          value: l10n.orderDate(session.createdAt!.toLocal()),
        ),
      _DetailRow(
        label: l10n.topUpMethod,
        value: session.method == TopUpMethod.crypto
            ? l10n.topUpCryptoTitle
            : l10n.topUpPaypalTitle,
      ),
      if (crypto != null)
        _DetailRow(
          label: l10n.paymentDetailCurrency,
          value: '${crypto.coin} · ${crypto.network}',
        ),
      if (crypto?.providerStatus != null)
        _DetailRow(
          label: l10n.paymentDetailProviderStatus,
          value: crypto!.providerStatus!,
        ),
      if (crypto?.txid != null)
        _DetailRow(
          label: l10n.paymentDetailTransactionId,
          value: crypto!.txid!,
          stacked: true,
        ),
      if (crypto != null && session.status == TopUpStatus.waiting)
        _DetailRow(
          label: l10n.cryptoToAddress,
          value: crypto.address,
          stacked: true,
        ),
      if (session.creditedAt != null)
        _DetailRow(
          label: l10n.paymentDetailCreditedAt,
          value: l10n.orderDate(session.creditedAt!.toLocal()),
        ),
      _DetailRow(label: l10n.paymentDetailId, value: session.id, stacked: true),
    ];

    return RefreshIndicator(
      onRefresh: refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          _StatusCard(
            status: session.status,
            title: _status(l10n),
            amount: session.amount.format(),
            amountLabel: l10n.paymentDetailTopUpAmount,
          ),
          if (explanation != null) ...[
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              color: session.status == TopUpStatus.failed
                  ? c.errorSubtle
                  : c.warningSubtle,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HugeIcon(
                    icon: AppIcons.info,
                    size: 20,
                    color: session.status == TopUpStatus.failed
                        ? c.errorText
                        : c.warning,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(explanation, style: context.text.bodySm),
                  ),
                ],
              ),
            ),
          ],
          if (session.status == TopUpStatus.waiting) ...[
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: l10n.paymentDetailContinue,
              onPressed: () async {
                await context.push(
                  '${AppRoute.balanceTopUp.path}?paymentId=${Uri.encodeComponent(session.id)}',
                );
                if (context.mounted) await refresh();
              },
            ),
          ],
          if (financialRows.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxl),
            _DetailSection(
              title: l10n.paymentDetailBreakdown,
              rows: financialRows,
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),
          _DetailSection(
            title: l10n.paymentDetailTransaction,
            rows: transactionRows,
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.status,
    required this.title,
    required this.amount,
    required this.amountLabel,
  });

  final TopUpStatus status;
  final String title;
  final String amount;
  final String amountLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (fill, accent, icon) = switch (status) {
      TopUpStatus.credited => (c.successSubtle, c.successText, AppIcons.check),
      TopUpStatus.review ||
      TopUpStatus.expired => (c.warningSubtle, c.warning, AppIcons.warning),
      TopUpStatus.failed => (c.errorSubtle, c.errorText, AppIcons.error),
      _ => (c.primarySubtle, c.primary, AppIcons.info),
    };
    return AppCard(
      color: fill,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: c.background.withValues(alpha: 0.75),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: HugeIcon(icon: icon, size: 22, color: accent),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(title, style: context.text.h3)),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(amount, style: context.text.display),
          const SizedBox(height: AppSpacing.xs),
          Text(
            amountLabel,
            style: context.text.bodySm.copyWith(color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.rows});

  final String title;
  final List<_DetailRow> rows;

  @override
  Widget build(BuildContext context) => AppCard(
    color: context.colors.surface,
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.xl,
      vertical: AppSpacing.lg,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.text.h3),
        const SizedBox(height: AppSpacing.sm),
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) Divider(color: context.colors.border, height: 1),
          rows[i],
        ],
      ],
    ),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.emphasized = false,
    this.stacked = false,
  });

  final String label;
  final String value;
  final bool emphasized;
  final bool stacked;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final labelStyle = context.text.bodySm.copyWith(color: c.textSecondary);
    final valueStyle = context.text.bodyMed.copyWith(
      fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: stacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: labelStyle),
                const SizedBox(height: AppSpacing.xs),
                SelectableText(value, style: valueStyle),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(label, style: labelStyle)),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: SelectableText(
                    value,
                    textAlign: TextAlign.end,
                    style: valueStyle,
                  ),
                ),
              ],
            ),
    );
  }
}

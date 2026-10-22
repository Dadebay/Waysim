import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/bloc/async_cubit.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters/labels.dart';
import '../../../../core/utils/formatters/money.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../domain/entities/wallet_entities.dart';
import '../../domain/repositories/wallet_repository.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key, required this.id});

  final String id;

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late final AsyncCubit<WalletOrder> _order = AsyncCubit<WalletOrder>(
    () => getIt<WalletRepository>().order(widget.id),
  )..load();

  @override
  void dispose() {
    _order.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: _order,
    child: _DetailScaffold<WalletOrder>(
      title: context.l10n.orderDetailTitle,
      cubit: _order,
      content: (order) => _OrderContent(order: order),
    ),
  );
}

class ActivityDetailPage extends StatefulWidget {
  const ActivityDetailPage({super.key, required this.id, this.initialEntry});

  final String id;
  final Map<String, dynamic>? initialEntry;

  @override
  State<ActivityDetailPage> createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends State<ActivityDetailPage> {
  late final AsyncCubit<Map<String, dynamic>> _entry =
      AsyncCubit<Map<String, dynamic>>(_loadEntry);

  Future<Result<Map<String, dynamic>>> _loadEntry() async {
    final result = await getIt<WalletRepository>().ledger();
    if (result case Error(:final failure)) return Error(failure);
    final found = result.dataOrNull!
        .where((entry) => '${entry['id']}' == widget.id)
        .firstOrNull;
    return found == null ? const Error(NotFoundFailure()) : Success(found);
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialEntry != null) {
      _entry.put(widget.initialEntry!);
      _entry.load(silent: true);
    } else {
      _entry.load();
    }
  }

  @override
  void dispose() {
    _entry.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: _entry,
    child: _DetailScaffold<Map<String, dynamic>>(
      title: context.l10n.activityDetailTitle,
      cubit: _entry,
      content: (entry) => _ActivityContent(entry: entry),
    ),
  );
}

class _DetailScaffold<T> extends StatelessWidget {
  const _DetailScaffold({
    required this.title,
    required this.cubit,
    required this.content,
  });

  final String title;
  final AsyncCubit<T> cubit;
  final Widget Function(T) content;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final state = context.watch<AsyncCubit<T>>().state;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: context.l10n.searchBack,
          onPressed: () => context.pop(),
          icon: HugeIcon(icon: AppIcons.back, size: 24, color: c.textPrimary),
        ),
        title: Text(title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: switch (state) {
          AsyncLoading() => const SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.page),
            child: SkeletonList(count: 4),
          ),
          AsyncFailure(:final failure) => ErrorView(
            failure: failure,
            onRetry: cubit.load,
          ),
          AsyncData(:final data) => RefreshIndicator(
            onRefresh: () => cubit.load(silent: true),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.page),
              children: [content(data)],
            ),
          ),
        },
      ),
    );
  }
}

class _OrderContent extends StatelessWidget {
  const _OrderContent({required this.order});

  final WalletOrder order;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final completed = order.outcome == OrderOutcome.completed;
    final status = switch (order.outcome) {
      OrderOutcome.completed => l10n.orderCompleted,
      OrderOutcome.failedRefunded => l10n.statusFailedRefunded,
      OrderOutcome.pending => l10n.paymentPending,
      OrderOutcome.review => l10n.paymentReview,
      OrderOutcome.failed => l10n.statusFailed,
    };
    final title = order.serverTitle?.isNotEmpty == true
        ? order.serverTitle!
        : order.addOn
        ? l10n.ordersTabTopUps
        : l10n.ordersTabPurchases;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          color: completed ? c.successSubtle : c.primarySubtle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.text.bodyMed),
              const SizedBox(height: AppSpacing.sm),
              Text(order.amount.format(), style: context.text.display),
              const SizedBox(height: AppSpacing.md),
              Text(
                status,
                style: context.text.bodyMed.copyWith(
                  color: completed ? c.success : c.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (order.outcome == OrderOutcome.failedRefunded) ...[
          const SizedBox(height: AppSpacing.md),
          AppCard(color: c.warningSubtle, child: Text(l10n.orderFailedBody)),
        ],
        const SizedBox(height: AppSpacing.xxl),
        AppCard(
          color: c.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailField(
                label: l10n.detailOrderNumber,
                value: '#${order.number}',
              ),
              _DetailField(
                label: l10n.paymentDetailDate,
                value: l10n.orderDate(order.createdAt.toLocal()),
              ),
              _DetailField(label: l10n.detailStatus, value: status),
              if (order.slug?.isNotEmpty == true)
                _DetailField(label: l10n.detailPackage, value: order.slug!),
              if (order.failedReason?.isNotEmpty == true)
                _DetailField(
                  label: l10n.detailFailureReason,
                  value: order.failedReason!,
                ),
              if (order.doneAt != null)
                _DetailField(
                  label: l10n.detailCompletedAt,
                  value: l10n.orderDate(order.doneAt!.toLocal()),
                ),
              if (order.esimId?.isNotEmpty == true)
                _DetailField(label: l10n.detailEsimId, value: order.esimId!),
              if (order.id?.isNotEmpty == true)
                _DetailField(label: l10n.detailOrderId, value: order.id!),
            ],
          ),
        ),
        if (order.esimId?.isNotEmpty == true) ...[
          const SizedBox(height: AppSpacing.xxl),
          AppButton(
            label: l10n.detailViewEsim,
            onPressed: () =>
                context.push(AppRoute.esim.withParams({'id': order.esimId!})),
          ),
        ],
      ],
    );
  }
}

class _ActivityContent extends StatelessWidget {
  const _ActivityContent({required this.entry});

  final Map<String, dynamic> entry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final cents = (entry['amountCents'] as num?)?.toInt() ?? 0;
    final balance = (entry['balanceAfterCents'] as num?)?.toInt();
    final title = entry['title'] as String?;
    final note = entry['note'] as String?;
    final kind = entry['kind'] as String?;
    final refType = entry['refType'] as String?;
    final refId = entry['refId'] as String?;
    final date = DateTime.tryParse(entry['createdAt'] as String? ?? '');
    final linkedRoute = refId == null || refId.isEmpty
        ? null
        : switch (refType) {
            'payment' => AppRoute.paymentDetail.withParams({'id': refId}),
            'order' => AppRoute.orderDetail.withParams({'id': refId}),
            _ => null,
          };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          color: cents >= 0 ? c.successSubtle : c.primarySubtle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title?.isNotEmpty == true ? title! : l10n.ordersTabActivity,
                style: context.text.bodyMed,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${cents > 0 ? '+' : ''}${Money(cents).format()}',
                style: context.text.display,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        AppCard(
          color: c.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (date != null)
                _DetailField(
                  label: l10n.paymentDetailDate,
                  value: l10n.orderDate(date.toLocal()),
                ),
              if (kind?.isNotEmpty == true)
                _DetailField(label: l10n.detailType, value: kind!),
              if (note?.isNotEmpty == true)
                _DetailField(label: l10n.detailNote, value: note!),
              if (balance != null)
                _DetailField(
                  label: l10n.detailBalanceAfter,
                  value: Money(balance).format(),
                ),
              if (refType?.isNotEmpty == true && refId?.isNotEmpty == true)
                _DetailField(
                  label: l10n.detailReference,
                  value: '$refType · $refId',
                ),
              _DetailField(label: l10n.detailEntryId, value: '${entry['id']}'),
            ],
          ),
        ),
        if (linkedRoute != null) ...[
          const SizedBox(height: AppSpacing.xxl),
          AppButton(
            label: l10n.detailViewReference,
            onPressed: () => context.push(linkedRoute),
          ),
        ],
      ],
    );
  }
}

class _DetailField extends StatelessWidget {
  const _DetailField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.text.caption.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        SelectableText(value, style: context.text.bodyMed),
      ],
    ),
  );
}

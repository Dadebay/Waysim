import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/bloc/async_cubit.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters/labels.dart';
import '../../../../core/utils/formatters/money.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/segmented_tabs.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../core/widgets/tab_switcher.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../app/router/app_routes.dart';
import '../../domain/entities/wallet_entities.dart';
import '../../domain/repositories/wallet_repository.dart';

/// Order history: purchases and balance top-ups.
class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  int _tab = 0;
  late final _purchases = getIt<AsyncCubit<List<WalletOrder>>>(
    param1: OrderType.purchase,
  )..load();
  late final _topUps = getIt<AsyncCubit<List<WalletOrder>>>(
    param1: OrderType.topUp,
  )..load();
  AsyncCubit<List<Map<String, dynamic>>>? _activity;

  void _selectTab(int index) {
    if (index == 2) {
      _activity ??= AsyncCubit<List<Map<String, dynamic>>>(
        getIt<WalletRepository>().ledger,
      )..load();
    }
    setState(() => _tab = index);
  }

  @override
  void dispose() {
    _purchases.close();
    _topUps.close();
    _activity?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.searchBack,
          onPressed: () => context.pop(),
          icon: HugeIcon(icon: AppIcons.back, size: 24, color: c.textPrimary),
        ),
        title: Text(l10n.ordersTitle),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        child: Column(
          children: [
            SegmentedTabs(
              labels: [
                l10n.ordersTabPurchases,
                l10n.ordersTabTopUps,
                l10n.ordersTabActivity,
              ],
              selectedIndex: _tab,
              onChanged: _selectTab,
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: TabSwitcher(
                index: _tab,
                child: _tab == 2
                    ? BlocProvider.value(
                        value: _activity!,
                        child: _ActivityList(cubit: _activity!),
                      )
                    : BlocProvider.value(
                        value: _tab == 0 ? _purchases : _topUps,
                        child: _OrderList(
                          topUps: _tab == 1,
                          cubit: _tab == 0 ? _purchases : _topUps,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityList extends StatelessWidget {
  const _ActivityList({required this.cubit});

  final AsyncCubit<List<Map<String, dynamic>>> cubit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<AsyncCubit<List<Map<String, dynamic>>>>().state;
    return switch (state) {
      AsyncLoading() => const SingleChildScrollView(
        child: SkeletonList(count: 6),
      ),
      AsyncFailure(:final failure) => ErrorView(
        failure: failure,
        onRetry: cubit.load,
      ),
      AsyncData(:final data) =>
        data.isEmpty
            ? _OrdersEmptyState(
                assetPath: 'assets/illustrations/orders_empty_activity.png',
                title: l10n.ordersEmptyActivity,
              )
            : RefreshIndicator(
                onRefresh: () => cubit.load(silent: true),
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
                  itemCount: data.length,
                  separatorBuilder: (_, _) =>
                      Divider(color: context.colors.border, height: 1),
                  itemBuilder: (_, i) => _ActivityTile(
                    entry: data[i],
                    onTap: () => context.push(
                      AppRoute.activityDetail.withParams({
                        'id': '${data[i]['id']}',
                      }),
                      extra: data[i],
                    ),
                  ),
                ),
              ),
    };
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.entry, required this.onTap});

  final Map<String, dynamic> entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final cents = (entry['amountCents'] as num?)?.toInt() ?? 0;
    final date = DateTime.tryParse(entry['createdAt'] as String? ?? '');
    final title = entry['title'] as String?;
    final note = entry['note'] as String?;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title?.isNotEmpty == true ? title! : l10n.ordersTabActivity,
                    style: context.text.bodyMed.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (note?.isNotEmpty == true)
                    Text(
                      note!,
                      style: context.text.caption.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  if (date != null)
                    Text(
                      l10n.orderDate(date),
                      style: context.text.caption.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              '${cents > 0 ? '+' : ''}${Money(cents).format()}',
              style: context.text.bodyMed.copyWith(
                fontWeight: FontWeight.w700,
                color: cents > 0 ? c.success : null,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            HugeIcon(
              icon: AppIcons.chevronRight,
              size: 18,
              color: c.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  const _OrderList({required this.topUps, required this.cubit});

  final bool topUps;
  final AsyncCubit<List<WalletOrder>> cubit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<AsyncCubit<List<WalletOrder>>>().state;

    return switch (state) {
      AsyncLoading() => const SingleChildScrollView(
        child: SkeletonList(count: 6),
      ),
      AsyncFailure(:final failure) => ErrorView(
        failure: failure,
        onRetry: cubit.load,
      ),
      AsyncData(:final data) =>
        data.isEmpty
            ? _OrdersEmptyState(
                assetPath: topUps
                    ? 'assets/illustrations/orders_empty_topups.png'
                    : 'assets/illustrations/orders_empty_purchases.png',
                title: topUps
                    ? l10n.ordersEmptyTopUps
                    : l10n.ordersEmptyPurchases,
              )
            : RefreshIndicator(
                onRefresh: () => cubit.load(silent: true),
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
                  itemCount: data.length,
                  separatorBuilder: (_, _) =>
                      Divider(color: context.colors.border, height: 1),
                  itemBuilder: (_, i) => _OrderTile(
                    order: data[i],
                    onTap: () async {
                      final order = data[i];
                      await context.push(
                        order.method != null
                            ? AppRoute.paymentDetail.withParams({
                                'id': order.id ?? order.number,
                              })
                            : AppRoute.orderDetail.withParams({
                                'id': order.id ?? order.number,
                              }),
                      );
                      if (context.mounted) await cubit.load(silent: true);
                    },
                  ),
                ),
              ),
    };
  }
}

class _OrdersEmptyState extends StatelessWidget {
  const _OrdersEmptyState({required this.assetPath, required this.title});

  final String assetPath;
  final String title;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.page,
              AppSpacing.page,
              AppSpacing.page + constraints.maxHeight * 0.10,
            ),
            child: Column(
              key: const ValueKey('orders-empty-content'),
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 188,
                      height: 188,
                      decoration: BoxDecoration(
                        color: c.primarySubtle.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Image.asset(
                      assetPath,
                      key: const ValueKey('orders-empty-illustration'),
                      width: 240,
                      height: 240,
                      fit: BoxFit.contain,
                      excludeFromSemantics: true,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  title,
                  style: context.text.h2,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order, this.onTap});

  final WalletOrder order;
  final VoidCallback? onTap;

  String _title(AppLocalizations l10n) {
    if (order.serverTitle?.isNotEmpty == true) return order.serverTitle!;
    if (order.type == OrderType.topUp && order.method != null) {
      return order.method == TopUpMethod.paypal
          ? l10n.orderTopUpPaypal
          : l10n.orderTopUpCrypto;
    }
    final place = order.nameFor(l10n.localeName);
    final size = order.volumeBytes == null
        ? l10n.dataUnlimited
        : l10n.dataSize(order.volumeBytes!);
    if (order.addOn) return l10n.orderAddOnTitle(place, size);
    final days = l10n.durationDays(order.days ?? 0);
    return l10n.orderPurchaseTitle(place, '$size · $days');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final failed = order.outcome == OrderOutcome.failedRefunded;
    final credit =
        order.type == OrderType.topUp &&
        order.method != null &&
        order.outcome == OrderOutcome.completed;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _title(l10n),
                    style: context.text.bodyMed.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.orderNumberDate(
                      order.number,
                      l10n.orderDate(order.createdAt),
                    ),
                    style: context.text.caption.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  credit
                      ? '+${order.amount.format()}'
                      : order.outcome != OrderOutcome.completed
                      ? order.amount.format()
                      : '−${order.amount.format()}',
                  style: context.text.bodyMed.copyWith(
                    fontWeight: FontWeight.w700,
                    color: credit ? c.success : null,
                    decoration: failed ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 140),
                  child: Text(
                    switch (order.outcome) {
                      OrderOutcome.completed => l10n.orderCompleted,
                      OrderOutcome.failedRefunded => l10n.statusFailedRefunded,
                      OrderOutcome.pending => l10n.paymentPending,
                      OrderOutcome.review => l10n.paymentReview,
                      OrderOutcome.failed => l10n.statusFailed,
                    },
                    textAlign: TextAlign.end,
                    style: context.text.caption.copyWith(
                      color: order.outcome == OrderOutcome.completed
                          ? c.success
                          : c.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (onTap != null) ...[
              const SizedBox(width: AppSpacing.xs),
              HugeIcon(
                icon: AppIcons.chevronRight,
                size: 18,
                color: c.textSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

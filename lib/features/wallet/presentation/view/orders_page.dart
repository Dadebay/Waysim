import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/bloc/async_cubit.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters/labels.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/segmented_tabs.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../core/widgets/tab_switcher.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/wallet_entities.dart';

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

  @override
  void dispose() {
    _purchases.close();
    _topUps.close();
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
              labels: [l10n.ordersTabPurchases, l10n.ordersTabTopUps],
              selectedIndex: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: TabSwitcher(
                index: _tab,
                child: BlocProvider.value(
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
            ? EmptyState(
                icon: AppIcons.wallet,
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
                  itemBuilder: (_, i) => _OrderTile(order: data[i]),
                ),
              ),
    };
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order});

  final WalletOrder order;

  String _title(AppLocalizations l10n) {
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
    final credit = order.type == OrderType.topUp && order.method != null;

    return Padding(
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
                  style: context.text.caption.copyWith(color: c.textSecondary),
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
                    : failed
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
                  failed ? l10n.statusFailedRefunded : l10n.orderCompleted,
                  textAlign: TextAlign.end,
                  style: context.text.caption.copyWith(
                    color: failed ? c.error : c.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

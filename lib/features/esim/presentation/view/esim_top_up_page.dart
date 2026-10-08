import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/bloc/async_cubit.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters/labels.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/package_tile.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../catalog/domain/entities/esim_package.dart';
import '../../../purchase/presentation/purchase_flow.dart';
import '../../../purchase/presentation/purchase_subject.dart';
import '../cubit/esim_list_cubit.dart';
import '../esim_labels.dart';

/// Add-on plans for an eSIM that is already installed.
class EsimTopUpPage extends StatelessWidget {
  const EsimTopUpPage({super.key, required this.esimId});

  final String esimId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<AsyncCubit<List<EsimPackage>>>(
      instanceName: 'topUpPackages',
      param1: esimId,
    )..load(),
    child: _View(esimId: esimId),
  );
}

class _View extends StatefulWidget {
  const _View({required this.esimId});

  final String esimId;

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final esim = context.watch<EsimListCubit>().byId(widget.esimId);
    final state = context.watch<AsyncCubit<List<EsimPackage>>>().state;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.searchBack,
          onPressed: () => context.pop(),
          icon: HugeIcon(icon: AppIcons.back, size: 24, color: c.textPrimary),
        ),
        title: Text(l10n.topUpPlansTitle),
      ),
      body: switch (state) {
        AsyncLoading() => const Padding(
          padding: EdgeInsets.all(AppSpacing.page),
          child: SkeletonList(count: 4),
        ),
        AsyncFailure(:final failure) => ErrorView(
          failure: failure,
          onRetry: () => context.read<AsyncCubit<List<EsimPackage>>>().load(),
        ),
        AsyncData(:final data) =>
          data.isEmpty || esim == null
              ? EmptyState(icon: AppIcons.myEsim, title: l10n.topUpPlansEmpty)
              : _list(context, data),
      },
    );
  }

  Widget _list(BuildContext context, List<EsimPackage> packages) {
    final l10n = context.l10n;
    final c = context.colors;
    final esim = context.read<EsimListCubit>().byId(widget.esimId)!;
    final selected = packages.firstWhere(
      (p) => p.id == _selectedId,
      orElse: () => packages.first,
    );

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.page),
            children: [
              Text(
                l10n.topUpPlansSubtitle,
                style: context.text.body.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),
              for (final p in packages) ...[
                PackageTile(
                  volume: l10n.packageVolume(p),
                  duration: l10n.packageDuration(p),
                  price: p.price.format(),
                  selected: p.id == selected.id,
                  onTap: () => setState(() => _selectedId = p.id),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.page),
            child: AppButton(
              label: l10n.buyFor(selected.price.format()),
              onPressed: () async {
                final done = await startPurchase(
                  context,
                  PurchaseSubject(
                    package: selected,
                    title: l10n.esimTitle(esim),
                    planLine:
                        '+${l10n.packageVolume(selected)} · ${l10n.packageDuration(selected)}',
                    flagCode: esim.isRegion ? null : esim.destinationCode,
                    esimId: esim.id,
                  ),
                );
                if (done && context.mounted) context.pop();
              },
            ),
          ),
        ),
      ],
    );
  }
}

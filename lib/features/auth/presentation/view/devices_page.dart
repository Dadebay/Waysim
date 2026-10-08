import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/bloc/async_cubit.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters/labels.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../domain/entities/user.dart';

/// The phones that have used this account.
class DevicesPage extends StatelessWidget {
  const DevicesPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<AsyncCubit<List<DeviceInfo>>>()..load(),
    child: const _View(),
  );
}

class _View extends StatelessWidget {
  const _View();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final state = context.watch<AsyncCubit<List<DeviceInfo>>>().state;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.searchBack,
          onPressed: () => context.pop(),
          icon: HugeIcon(icon: AppIcons.back, size: 24, color: c.textPrimary),
        ),
        title: Text(l10n.devicesTitle),
        centerTitle: true,
      ),
      body: switch (state) {
        AsyncLoading() => const Padding(
          padding: EdgeInsets.all(AppSpacing.page),
          child: SkeletonList(count: 2),
        ),
        AsyncFailure(:final failure) => ErrorView(
          failure: failure,
          onRetry: () => context.read<AsyncCubit<List<DeviceInfo>>>().load(),
        ),
        AsyncData(:final data) => ListView(
          padding: const EdgeInsets.all(AppSpacing.page),
          children: [
            Text(
              l10n.devicesNote,
              style: context.text.bodySm.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final d in data)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: c.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: [
                        HugeIcon(
                          icon: AppIcons.phone,
                          size: 28,
                          color: c.primary,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                d.isCurrent
                                    ? '${d.model} · ${l10n.deviceThis}'
                                    : d.model,
                                style: context.text.bodyMed.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                [
                                  d.os,
                                  if (d.lastSeen != null && !d.isCurrent)
                                    l10n.deviceLastSeen(
                                      l10n.ago(d.lastSeen!, DateTime.now()),
                                    ),
                                ].join(' · '),
                                style: context.text.caption.copyWith(
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
              ),
          ],
        ),
      },
    );
  }
}

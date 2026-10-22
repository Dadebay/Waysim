import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/bloc/async_cubit.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters/labels.dart';
import '../../../../core/utils/formatters/device_model.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

/// The phones that have used this account.
class DevicesPage extends StatelessWidget {
  const DevicesPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<AsyncCubit<List<DeviceInfo>>>()..load(),
    child: const _View(),
  );
}

class _View extends StatefulWidget {
  const _View();

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  String? _removingId;

  Future<void> _remove(DeviceInfo device) async {
    if (device.isCurrent || _removingId != null) return;
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deviceRemoveTitle, style: context.text.h2),
        content: Text(l10n.deviceRemoveBody(deviceModelName(device.model))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.actionCancel),
          ),
          AppButton(
            label: l10n.deviceRemove,
            expand: false,
            size: AppButtonSize.sm,
            variant: AppButtonVariant.danger,
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true || _removingId != null) return;
    setState(() => _removingId = device.id);
    final result = await getIt<AuthRepository>().revokeDevice(device.id);
    if (!mounted) return;
    setState(() => _removingId = null);
    switch (result) {
      case Success():
        final cubit = context.read<AsyncCubit<List<DeviceInfo>>>();
        final devices = cubit.state.dataOrNull;
        if (devices != null) {
          cubit.put(devices.where((d) => d.id != device.id).toList());
        }
        AppToast.show(context, l10n.deviceRemoved);
      case Error(:final failure):
        AppToast.show(context, failure.localize(l10n), isError: true);
    }
  }

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
        AsyncData(:final data, :final refreshing) => RefreshIndicator(
          onRefresh: () async {
            if (_removingId == null) {
              await context.read<AsyncCubit<List<DeviceInfo>>>().load(
                silent: true,
              );
            }
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                    key: ValueKey('device-${d.id}'),
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
                                  deviceModelName(d.model),
                                  style: context.text.bodyMed.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (d.isCurrent)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: AppSpacing.xs,
                                    ),
                                    child: Text(
                                      l10n.deviceThis,
                                      style: context.text.caption.copyWith(
                                        color: c.link,
                                        fontWeight: FontWeight.w700,
                                      ),
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
                          if (!d.isCurrent) ...[
                            const SizedBox(width: AppSpacing.sm),
                            if (_removingId == d.id)
                              const SizedBox(
                                width: 48,
                                height: 48,
                                child: Center(
                                  child: SizedBox.square(
                                    dimension: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              )
                            else
                              IconButton(
                                key: ValueKey('remove-device-${d.id}'),
                                tooltip: l10n.deviceRemove,
                                onPressed: _removingId == null && !refreshing
                                    ? () => _remove(d)
                                    : null,
                                icon: HugeIcon(
                                  icon: AppIcons.delete,
                                  size: 22,
                                  color: c.error,
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      },
    );
  }
}

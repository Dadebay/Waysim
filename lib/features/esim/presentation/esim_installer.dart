import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/di/injector.dart';
import '../../../core/localization/failure_localizer.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/esim_compatibility.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/extensions/context_extensions.dart';
import '../../../core/utils/result.dart';
import '../../../core/widgets/app_toast.dart';
import '../domain/entities/esim.dart';
import 'cubit/esim_list_cubit.dart';
import 'esim_install_tracker.dart';

final _installingIds = <String>{};

Future<void> installEsim(
  BuildContext context,
  Esim esim, {
  bool fromDetail = false,
}) async {
  if (!_installingIds.add(esim.id)) return;
  try {
    await _installEsim(context, esim, fromDetail: fromDetail);
  } finally {
    _installingIds.remove(esim.id);
  }
}

Future<void> _installEsim(
  BuildContext context,
  Esim esim, {
  required bool fromDetail,
}) async {
  final compat = getIt<EsimCompatibility>();
  final l10n = context.l10n;
  final router = GoRouter.of(context);

  if (esim.status == EsimStatus.cancelled) {
    AppToast.show(context, l10n.installCancelledByProvider, isError: true);
    return;
  }
  if (esim.status == EsimStatus.installed || esim.status == EsimStatus.active) {
    AppToast.show(context, l10n.installAlreadyIssued, isError: true);
    return;
  }

  final device = await compat.deviceName();
  final result = await getIt<EsimListCubit>().bind(esim, deviceName: device);
  if (!context.mounted) return;

  switch (result) {
    case Error(:final failure):
      AppToast.show(context, failure.localize(l10n), isError: true);
    case Success(:final data):
      if (data.status == EsimStatus.cancelled) {
        AppToast.show(context, l10n.installCancelledByProvider, isError: true);
        return;
      }
      if (data.status == EsimStatus.installed ||
          data.status == EsimStatus.active) {
        AppToast.show(context, l10n.installAlreadyIssued, isError: true);
        return;
      }
      final oneTap = await compat.supportsOneTapInstall();
      getIt<AnalyticsService>().startedEsimInstall(
        method: oneTap ? 'one_tap' : 'qr',
      );
      EsimInstallTracker.setReminderText(
        l10n.installReminderTitle,
        l10n.installReminderBody,
      );
      await EsimInstallTracker.start(
        data.id,
        method: oneTap ? 'one_tap' : 'qr',
        statusAtStart: data.status,
      );
      if (!fromDetail) {
        unawaited(router.push(AppRoute.esim.withParams({'id': data.id})));
      }
      if (oneTap) {
        final opened = await _openAppleInstaller(data.appleInstallUri);
        AppLogger.i(
          '[ESIM-INSTALL] installer link result id=${data.id} opened=$opened',
        );
        if (!opened) {
          await EsimInstallTracker.clear(data.id, reason: 'link_failed');
          if (context.mounted) {
            AppToast.show(context, l10n.installLinkFailed, isError: true);
          }
        }
      }
  }
}

Future<bool> _openAppleInstaller(Uri link) async {
  try {
    return await launchUrl(link, mode: LaunchMode.externalApplication);
  } on Object {
    return false;
  }
}

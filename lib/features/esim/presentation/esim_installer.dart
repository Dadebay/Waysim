import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/di/injector.dart';
import '../../../core/localization/failure_localizer.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/esim_compatibility.dart';
import '../../../core/utils/extensions/context_extensions.dart';
import '../../../core/utils/result.dart';
import '../../../core/widgets/app_toast.dart';
import '../domain/entities/esim.dart';
import 'cubit/esim_list_cubit.dart';

/// "Install" on an eSIM: ties it to this phone, then installs it.
///
/// iOS 17.4+ jumps straight into Apple's installer through a universal link;
/// everywhere else the customer lands on the eSIM's page to scan the QR code
/// or type the details. When called from that page ([fromDetail]) there is
/// nothing further to open.
Future<void> installEsim(
  BuildContext context,
  Esim esim, {
  bool fromDetail = false,
}) async {
  final compat = getIt<EsimCompatibility>();
  final l10n = context.l10n;
  final router = GoRouter.of(context);

  final device = await compat.deviceName();
  final result = await getIt<EsimListCubit>().bind(esim, deviceName: device);
  if (!context.mounted) return;

  switch (result) {
    case Error(:final failure):
      AppToast.show(context, failure.localize(l10n), isError: true);
    case Success(:final data):
      final oneTap = await compat.supportsOneTapInstall();
      getIt<AnalyticsService>().startedEsimInstall(
        method: oneTap ? 'one_tap' : 'qr',
      );
      if (oneTap) {
        await launchUrl(
          data.appleInstallUri,
          mode: LaunchMode.externalApplication,
        );
      } else if (!fromDetail) {
        unawaited(router.push(AppRoute.esim.withParams({'id': data.id})));
      }
  }
}

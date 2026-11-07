import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/auth_gate.dart';
import '../../../app/router/app_routes.dart';
import '../../../core/di/injector.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/esim_compatibility.dart';
import '../../../core/services/esim_support_cubit.dart';
import '../../../core/utils/extensions/context_extensions.dart';
import '../../../core/widgets/app_toast.dart';
import '../../catalog/presentation/widgets/compat_banner.dart';
import '../../config/presentation/cubit/config_cubit.dart';
import '../../wallet/presentation/cubit/wallet_cubit.dart';
import 'purchase_subject.dart';
import 'widgets/confirm_sheet.dart';

Future<bool> startPurchase(
  BuildContext context,
  PurchaseSubject subject,
) async {
  final l10n = context.l10n;
  final support = context.read<EsimSupportCubit>().state;
  final config = context.read<ConfigCubit>().state;

  if (config.maintenance) {
    AppToast.show(context, l10n.maintenanceBanner, isError: true);
    return false;
  }
  if (support != EsimSupport.yes && !await confirmBuyWithoutEsim(context)) {
    return false;
  }
  if (!context.mounted) return false;
  if (!await requireSignIn(context)) return false;
  if (!context.mounted) return false;

  unawaited(getIt<WalletCubit>().refresh());

  while (true) {
    if (!context.mounted) return false;
    final result = await showConfirmSheet(context, subject);
    if (!context.mounted) return false;
    switch (result) {
      case ConfirmPay():
        getIt<AnalyticsService>().startedCheckout(
          packageId: subject.package.id,
          price: subject.package.price,
          addOn: subject.isTopUp,
        );
        final done = await context.push<bool>(
          AppRoute.purchase.path,
          extra: subject,
        );
        return done ?? false;
      case ConfirmTopUp(:final missing):
        final topped = await context.push<bool>(
          AppRoute.balanceTopUp.path,
          extra: missing.cents,
        );
        if (topped != true || !context.mounted) return false;

      case null:
        return false;
    }
  }
}

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

/// Everything between "Buy" and the order screen, in one place:
///
/// 1. a phone that reports no eSIM support gets a warning first;
/// 2. a guest signs in and lands back here;
/// 3. the confirmation sheet shows price and balance; if the balance is short
///    it offers the exact top-up and comes back to the confirmation;
/// 4. the order screen runs the purchase.
///
/// Resolves `true` when an order was placed and finished successfully (used
/// by the eSIM top-up screen to close itself).
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
  if (support == EsimSupport.no && !await confirmBuyWithoutEsim(context)) {
    return false;
  }
  if (!context.mounted) return false;
  if (!await requireSignIn(context)) return false;
  if (!context.mounted) return false;

  // The confirmation needs a current balance, whatever the cache says.
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
      // Back to the confirmation with the new balance.
      case null:
        return false;
    }
  }
}

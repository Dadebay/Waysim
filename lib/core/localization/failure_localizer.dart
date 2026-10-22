import '../../l10n/app_localizations.dart';
import '../error/failure.dart';
import '../utils/formatters/money.dart';

/// Turns a [Failure] into copy the customer can read, in the app language.
/// Blocs carry the [Failure]; only widgets call this.
extension FailureLocalizer on Failure {
  String localize(AppLocalizations l10n) => switch (this) {
    NetworkFailure() => l10n.errorNetwork,
    TimeoutFailure() => l10n.errorTimeout,
    UnauthorizedFailure() => l10n.errorUnauthorized,
    NotFoundFailure() => l10n.errorNotFound,
    ServerFailure() => l10n.errorServer,
    ApiFailure(code: ApiCodes.maintenance) => l10n.errorMaintenance,
    ApiFailure(code: ApiCodes.packageUnavailable) =>
      l10n.errorPackageUnavailable,
    ApiFailure(code: 'invite_code_invalid') => l10n.inviteCodeInvalid,
    ApiFailure(code: ApiCodes.otpRateLimited || ApiCodes.otpTooManyAttempts) =>
      l10n.errorTooManyRequests,
    ApiFailure(code: 'account_disabled' || ApiCodes.userBlocked) =>
      l10n.errorUnauthorized,
    ApiFailure(statusCode: 401) => l10n.errorUnauthorized,
    ApiFailure(code: 'topup_unavailable') => l10n.topUpPlansEmpty,
    ApiFailure(code: 'payment_amount_out_of_range', :final details) =>
      l10n.topUpAmountInvalid(
        Money((details?['minCents'] as num?)?.toInt() ?? 500).format(),
        Money((details?['maxCents'] as num?)?.toInt() ?? 50000).format(),
      ),
    ApiFailure(code: ApiCodes.tooManyRequests) => l10n.errorTooManyRequests,
    ApiFailure(code: 'esim-bound-to-another-device') =>
      l10n.errorBoundToOtherDevice,
    ApiFailure(
      code: 'order-failed' || 'order_failed_refunded' || 'topup_failed',
    ) =>
      l10n.errorOrderFailed,
    ApiFailure(statusCode: final status) when (status ?? 0) >= 500 =>
      l10n.errorServer,
    _ => l10n.errorUnknown,
  };
}

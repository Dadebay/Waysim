import '../../l10n/app_localizations.dart';
import '../error/failure.dart';

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
    ApiFailure(code: ApiCodes.tooManyRequests) => l10n.errorTooManyRequests,
    ApiFailure(code: 'esim-bound-to-another-device') =>
      l10n.errorBoundToOtherDevice,
    ApiFailure(code: 'order-failed') => l10n.errorOrderFailed,
    ApiFailure(statusCode: final status) when (status ?? 0) >= 500 =>
      l10n.errorServer,
    _ => l10n.errorUnknown,
  };
}

import 'package:flutter_bloc/flutter_bloc.dart';

import 'crash_report.dart';

enum IntegrityStatus {
  ok,

  /// Rooted, jailbroken or running on an emulator.
  compromised,

  /// Could not be determined; treated as fine.
  unknown,
}

/// Root / jailbreak / emulator detection. A compromised phone gets a warning
/// and no referral bonuses (docs/01-product-spec.md §10). A RASP package can
/// replace [DeviceContextIntegrity] in the injector (docs/06-roadmap.md T6.2).
abstract interface class DeviceIntegrity {
  Future<IntegrityStatus> check();
}

/// Uses the root / jailbreak answer already read at launch
/// (`root_jailbreak_detector`, see `readDeviceContext`), so the warning and
/// the hidden invite field built for a compromised phone actually appear.
class DeviceContextIntegrity implements DeviceIntegrity {
  const DeviceContextIntegrity(this._context);

  final DeviceContext _context;

  @override
  Future<IntegrityStatus> check() async => _context.platform == 'unknown'
      ? IntegrityStatus.unknown
      : _context.isRooted
      ? IntegrityStatus.compromised
      : IntegrityStatus.ok;
}

/// The result of the check, shared by the screens that react to it.
class DeviceIntegrityCubit extends Cubit<IntegrityStatus> {
  DeviceIntegrityCubit(this._integrity) : super(IntegrityStatus.unknown);

  final DeviceIntegrity _integrity;

  Future<void> check() async => emit(await _integrity.check());

  bool get compromised => state == IntegrityStatus.compromised;
}

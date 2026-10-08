import 'package:flutter_bloc/flutter_bloc.dart';

enum IntegrityStatus {
  ok,

  /// Rooted, jailbroken or running on an emulator.
  compromised,

  /// Could not be determined; treated as fine.
  unknown,
}

/// Root / jailbreak / emulator detection. A compromised phone gets a warning
/// and no referral bonuses (docs/01-product-spec.md §10). The real check
/// (a RASP package) replaces [NoopDeviceIntegrity] in the injector
/// (docs/06-roadmap.md T6.2).
abstract interface class DeviceIntegrity {
  Future<IntegrityStatus> check();
}

class NoopDeviceIntegrity implements DeviceIntegrity {
  @override
  Future<IntegrityStatus> check() async => IntegrityStatus.unknown;
}

/// The result of the check, shared by the screens that react to it.
class DeviceIntegrityCubit extends Cubit<IntegrityStatus> {
  DeviceIntegrityCubit(this._integrity) : super(IntegrityStatus.unknown);

  final DeviceIntegrity _integrity;

  Future<void> check() async => emit(await _integrity.check());

  bool get compromised => state == IntegrityStatus.compromised;
}

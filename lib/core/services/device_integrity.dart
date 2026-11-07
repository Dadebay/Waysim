import 'package:flutter_bloc/flutter_bloc.dart';

import 'crash_report.dart';

enum IntegrityStatus { ok, compromised, unknown }

abstract interface class DeviceIntegrity {
  Future<IntegrityStatus> check();
}

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

class DeviceIntegrityCubit extends Cubit<IntegrityStatus> {
  DeviceIntegrityCubit(this._integrity) : super(IntegrityStatus.unknown);

  final DeviceIntegrity _integrity;

  Future<void> check() async => emit(await _integrity.check());

  bool get compromised => state == IntegrityStatus.compromised;
}

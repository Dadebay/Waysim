import 'package:flutter_bloc/flutter_bloc.dart';

import 'esim_compatibility.dart';

/// Whether this phone supports eSIM, asked once and shared by every
/// destination page. `null` while the check runs.
class EsimSupportCubit extends Cubit<EsimSupport?> {
  EsimSupportCubit(this._compatibility) : super(null);

  final EsimCompatibility _compatibility;

  Future<void> check() async => emit(await _compatibility.check());
}

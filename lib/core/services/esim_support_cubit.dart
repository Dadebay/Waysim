import 'package:flutter_bloc/flutter_bloc.dart';

import '../storage/local_storage.dart';
import 'esim_compatibility.dart';

/// Whether this phone supports eSIM, asked once and shared by every
/// destination page. `null` while the check runs.
class EsimSupportCubit extends Cubit<EsimSupport?> {
  EsimSupportCubit(this._compatibility, this._storage) : super(null);

  final EsimCompatibility _compatibility;
  final LocalStorage _storage;
  String? _eidAnswerKey;
  bool _isModelBased = false;

  /// A model estimate needs the person's EID confirmation to become Yes/No.
  bool get isModelBased => _isModelBased;

  Future<void> check() async {
    final detected = await _compatibility.check();
    _isModelBased = detected == EsimSupport.likely;
    _eidAnswerKey = null;
    if (detected != EsimSupport.likely) {
      emit(detected);
      return;
    }

    final deviceId = await _compatibility.deviceIdentifier();
    if (deviceId != null && deviceId.isNotEmpty) {
      _eidAnswerKey = 'esim.eid-confirmed.$deviceId';
    }
    final answer = _eidAnswerKey == null
        ? null
        : _storage.getBool(_eidAnswerKey!);
    emit(switch (answer) {
      true => EsimSupport.yes,
      false => EsimSupport.no,
      null => EsimSupport.likely,
    });
  }

  Future<void> confirmEid({required bool present}) async {
    if (state != EsimSupport.likely) return;
    if (_eidAnswerKey case final key?) {
      await _storage.setBool(key, value: present);
    }
    emit(present ? EsimSupport.yes : EsimSupport.no);
  }

  Future<void> clearEidConfirmation() async {
    if (!_isModelBased) return;
    if (_eidAnswerKey case final key?) await _storage.remove(key);
    emit(EsimSupport.likely);
  }
}

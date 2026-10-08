import '../../../../core/bloc/async_cubit.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/esim.dart';
import '../../domain/repositories/esim_repository.dart';

/// The customer's eSIMs, shared by the My eSIM tab, the post-purchase screen
/// and the detail page.
class EsimListCubit extends AsyncCubit<List<Esim>> {
  EsimListCubit(this._repository) : super(_repository.list);

  final EsimRepository _repository;

  /// Looks an eSIM up in the loaded list.
  Esim? byId(String id) {
    for (final e in state.dataOrNull ?? const <Esim>[]) {
      if (e.id == id) return e;
    }
    return null;
  }

  /// Swaps one eSIM in the loaded list (after install or top-up).
  void replace(Esim esim) {
    final current = state.dataOrNull;
    if (current == null) return;
    final index = current.indexWhere((e) => e.id == esim.id);
    final next = [...current];
    if (index < 0) {
      next.insert(0, esim);
    } else {
      next[index] = esim;
    }
    put(next);
  }

  /// "Install" was tapped: tie the package to this phone (one package, one
  /// device). Idempotent for the same phone.
  Future<Result<Esim>> bind(Esim esim, {required String deviceName}) async {
    final result = await _repository.bindToDevice(
      esim.id,
      deviceName: deviceName,
    );
    if (result case Success(:final data)) replace(data);
    return result;
  }

  void clear() => put(const []);
}

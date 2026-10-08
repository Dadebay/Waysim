import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/destination.dart';
import '../../domain/repositories/catalog_repository.dart';

enum CatalogStatus { initial, loading, loaded, failure }

class CatalogState extends Equatable {
  const CatalogState({
    this.status = CatalogStatus.initial,
    this.destinations = const [],
    this.failure,
    this.refreshing = false,
  });

  final CatalogStatus status;
  final List<Destination> destinations;
  final Failure? failure;

  /// A fetch is running behind data already on screen.
  final bool refreshing;

  List<Destination> get countries =>
      destinations.where((d) => !d.isRegion).toList();
  List<Destination> get regions =>
      destinations.where((d) => d.isRegion).toList();

  Destination? byCode(String code) {
    for (final d in destinations) {
      if (d.code == code) return d;
    }
    return null;
  }

  @override
  List<Object?> get props => [status, destinations, failure, refreshing];
}

/// The catalog of countries and regions. Persisted, so Home and search work
/// from the last answer while offline and the next launch opens instantly.
class CatalogCubit extends HydratedCubit<CatalogState> {
  CatalogCubit(this._repository) : super(const CatalogState());

  final CatalogRepository _repository;

  Future<void> load() async {
    final cached = state.destinations;
    emit(
      CatalogState(
        status: cached.isEmpty ? CatalogStatus.loading : CatalogStatus.loaded,
        destinations: cached,
        refreshing: cached.isNotEmpty,
      ),
    );

    final result = await _repository.destinations();
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(CatalogState(status: CatalogStatus.loaded, destinations: data));
      case Error(:final failure):
        emit(
          cached.isEmpty
              ? CatalogState(status: CatalogStatus.failure, failure: failure)
              // Offline with a cache: keep showing it.
              : CatalogState(
                  status: CatalogStatus.loaded,
                  destinations: cached,
                ),
        );
    }
  }

  @override
  CatalogState? fromJson(Map<String, dynamic> json) {
    try {
      final list = (json['destinations'] as List)
          .map((e) => Destination.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      return CatalogState(
        status: list.isEmpty ? CatalogStatus.initial : CatalogStatus.loaded,
        destinations: list,
      );
    } on Object {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(CatalogState state) {
    if (state.status != CatalogStatus.loaded || state.destinations.isEmpty) {
      return null;
    }
    return {'destinations': state.destinations.map((d) => d.toJson()).toList()};
  }
}

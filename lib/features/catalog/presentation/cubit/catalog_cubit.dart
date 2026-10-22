import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/catalog_banner.dart';
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
    this.banners,
  });

  final List<CatalogBanner>? banners;
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
  List<Object?> get props => [
    status,
    destinations,
    failure,
    refreshing,
    banners,
  ];
}

/// The catalog of countries and regions. Persisted, so Home and search work
/// from the last answer while offline and the next launch opens instantly.
class CatalogCubit extends HydratedCubit<CatalogState> {
  CatalogCubit(this._repository, {this.cacheKey = 'catalog'})
    : super(const CatalogState());

  final CatalogRepository _repository;
  final String cacheKey;
  int _generation = 0;
  @override
  String get storagePrefix => cacheKey;
  void mergeSearchResults(List<Destination> results) {
    final combined = {
      for (final d in state.destinations) d.code: d,
      for (final d in results) d.code: d,
    };
    emit(
      CatalogState(
        status: CatalogStatus.loaded,
        destinations: combined.values.toList(),
        banners: state.banners,
      ),
    );
  }

  Future<Result<Destination>> ensureLocation(String code) async {
    final cached = state.byCode(code);
    if (cached != null) return Success(cached);
    final result = await _repository.location(code);
    if (!isClosed && result.isSuccess) mergeSearchResults([result.dataOrNull!]);
    return result;
  }

  Future<void> load() async {
    final generation = ++_generation;
    final cached = state.destinations;
    emit(
      CatalogState(
        status: cached.isEmpty ? CatalogStatus.loading : CatalogStatus.loaded,
        destinations: cached,
        banners: state.banners,
        refreshing: cached.isNotEmpty,
      ),
    );

    final result = await _repository.destinations();
    if (isClosed || generation != _generation) return;
    switch (result) {
      case Success(:final data):
        emit(
          CatalogState(
            status: CatalogStatus.loaded,
            destinations: data,
            banners: _repository.banners,
          ),
        );
      case Error(:final failure):
        emit(
          cached.isEmpty
              ? CatalogState(status: CatalogStatus.failure, failure: failure)
              // Offline with a cache: keep showing it.
              : CatalogState(
                  status: CatalogStatus.loaded,
                  destinations: cached,
                  banners: state.banners,
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
        banners: json['banners'] is List
            ? (json['banners'] as List)
                  .map(
                    (b) => CatalogBanner(
                      id: b['id'] as String,
                      imageUrl: b['imageUrl'] as String,
                      width: (b['width'] as num).toDouble(),
                      height: (b['height'] as num).toDouble(),
                      link: b['link'] as String?,
                    ),
                  )
                  .toList()
            : null,
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
    return {
      'destinations': state.destinations.map((d) => d.toJson()).toList(),
      'banners': state.banners
          ?.map(
            (b) => {
              'id': b.id,
              'imageUrl': b.imageUrl,
              'width': b.width,
              'height': b.height,
              'link': b.link,
            },
          )
          .toList(),
    };
  }
}

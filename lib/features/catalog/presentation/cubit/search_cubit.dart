import 'dart:async';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../domain/catalog_search.dart';
import '../../domain/entities/destination.dart';

class SearchState extends Equatable {
  const SearchState({
    this.query = '',
    this.hits = const [],
    this.recent = const [],
  });

  final String query;
  final List<SearchHit> hits;

  /// Submitted search phrases, newest first.
  final List<String> recent;

  bool get isSearching => query.trim().isNotEmpty;

  @override
  List<Object?> get props => [query, hits, recent];
}

/// Type-ahead over the cached catalog, and the "recent searches" chips.
class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._storage, {this.remoteSearch, this.onResults})
    : super(
        SearchState(
          recent: _storage.getStringList(StorageKeys.recentQueries) ?? [],
        ),
      );

  static const maxRecent = 8;

  final LocalStorage _storage;
  final Future<Result<List<Destination>>> Function(String)? remoteSearch;
  final void Function(List<Destination>)? onResults;
  Timer? _debounce;
  int _generation = 0;

  void query(
    String text, {
    required List<Destination> destinations,
    required String language,
  }) {
    _debounce?.cancel();
    final generation = ++_generation;
    emit(
      SearchState(
        query: text,
        hits: CatalogSearch.search(destinations, text, language: language),
        recent: state.recent,
      ),
    );
    if (text.trim().isEmpty || remoteSearch == null) return;
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final result = await remoteSearch!(text.trim());
      if (isClosed || generation != _generation) return;
      if (result case Success(:final data)) {
        onResults?.call(data);
        emit(
          SearchState(
            query: text,
            recent: state.recent,
            hits: data.map((d) => SearchHit(d, 0)).toList(),
          ),
        );
      }
    });
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    _generation++;
    return super.close();
  }

  /// Remembers a completed search without filling history with each keystroke.
  Future<void> rememberQuery(String text) async {
    final phrase = text.trim();
    if (phrase.isEmpty) return;
    final next = [
      phrase,
      ...state.recent.where((old) => old.toLowerCase() != phrase.toLowerCase()),
    ].take(maxRecent).toList();
    emit(SearchState(query: state.query, hits: state.hits, recent: next));
    await _storage.setStringList(StorageKeys.recentQueries, next);
  }

  Future<void> clearRecent() async {
    emit(SearchState(query: state.query, hits: state.hits));
    await _storage.remove(StorageKeys.recentQueries);
  }
}

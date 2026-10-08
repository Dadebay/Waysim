import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:waysim/core/error/failure.dart';
import 'package:waysim/core/utils/result.dart';
import 'package:waysim/features/catalog/data/mock/catalog_fixtures.dart';
import 'package:waysim/features/catalog/domain/catalog_search.dart';
import 'package:waysim/features/catalog/domain/entities/destination.dart';
import 'package:waysim/features/catalog/domain/entities/esim_package.dart';
import 'package:waysim/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:waysim/features/catalog/presentation/cubit/catalog_cubit.dart';

import '../helpers/test_dependencies.dart';

/// A catalog that answers from a queue of results.
class _ScriptedCatalog implements CatalogRepository {
  _ScriptedCatalog(this.results);

  final List<Result<List<Destination>>> results;

  @override
  Future<Result<List<Destination>>> destinations() async => results.removeAt(0);

  @override
  Future<Result<List<EsimPackage>>> packages(String destinationCode) =>
      throw UnimplementedError();

  @override
  Future<Result<List<EsimPackage>>> topUpPackages(String esimId) =>
      throw UnimplementedError();
}

void main() {
  setUp(() => HydratedBloc.storage = MemoryStorage());

  final destinations = CatalogFixtures.destinations();

  test('offline with a cached catalog keeps showing it', () async {
    final cubit = CatalogCubit(
      _ScriptedCatalog([Success(destinations), const Error(NetworkFailure())]),
    );

    await cubit.load();
    expect(cubit.state.status, CatalogStatus.loaded);

    await cubit.load(); // the network is gone
    expect(cubit.state.status, CatalogStatus.loaded);
    expect(cubit.state.destinations, destinations);
    expect(cubit.state.failure, isNull);
  });

  test(
    'offline with nothing cached shows the failure, not an empty list',
    () async {
      final cubit = CatalogCubit(
        _ScriptedCatalog([const Error(NetworkFailure())]),
      );

      await cubit.load();

      expect(cubit.state.status, CatalogStatus.failure);
      expect(cubit.state.failure, isA<NetworkFailure>());
    },
  );

  test('the catalog survives a restart and opens instantly', () async {
    final first = CatalogCubit(_ScriptedCatalog([Success(destinations)]));
    await first.load();
    await first.close();

    // A new process: the cubit hydrates from storage before any request.
    final second = CatalogCubit(
      _ScriptedCatalog([const Error(NetworkFailure())]),
    );
    expect(second.state.status, CatalogStatus.loaded);
    expect(second.state.destinations.length, destinations.length);

    // And search works from that cache, with the network still down.
    await second.load();
    final hits = CatalogSearch.search(
      second.state.destinations,
      'turk',
      language: 'en',
    );
    expect(hits.first.destination.code, 'TR');
  });

  group('search', () {
    List<String> codes(String query, {String language = 'en'}) =>
        CatalogSearch.search(
          destinations,
          query,
          language: language,
        ).map((h) => h.destination.code).toList();

    test('finds by name in any language, alias and country code', () {
      expect(codes('США'), contains('US'));
      expect(codes('usa'), contains('US'));
      expect(codes('us').first, 'US');
      expect(codes('Tür'), contains('TR'));
      expect(codes('турц'), contains('TR'));
      expect(codes('turquia'), contains('TR'));
      expect(codes('土耳其'), contains('TR'));
      expect(codes('emirates'), contains('AE'));
    });

    test('prefix beats substring, countries beat regions', () {
      final result = codes('a');
      expect(result.isNotEmpty, isTrue);
      expect(codes('asia').first, 'ASIA');
    });

    test('empty and unknown queries find nothing', () {
      expect(codes(''), isEmpty);
      expect(codes('   '), isEmpty);
      expect(codes('zzzzzz'), isEmpty);
    });
  });
}

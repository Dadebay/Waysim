import '../error/exceptions.dart';
import '../error/failure.dart';
import '../utils/result.dart';
import 'api_client.dart';
import 'api_response.dart';

Future<Result<T>> apiResult<T>(Future<T> Function() request) async {
  try {
    return Success(await request());
  } on AppException catch (e) {
    return Error(e.toFailure());
  } on Object {
    return const Error(UnknownFailure(message: 'Invalid API response'));
  }
}

/// Exhaust the cursor API for existing list screens, guarding repeated cursors.
Future<List<Map<String, dynamic>>> apiPages(
  ApiClient api,
  String path, {
  Map<String, dynamic>? query,
}) async {
  final items = <Map<String, dynamic>>[];
  final seen = <String>{};
  String? cursor;
  do {
    final page = asMap(
      await api.get(path, queryParameters: {...?query, 'cursor': cursor}),
    );
    items.addAll(page.listOf('items'));
    cursor = page.strOrNull('nextCursor');
    if (cursor != null && !seen.add(cursor)) {
      throw const ParsingException('Repeated pagination cursor');
    }
  } while (cursor != null);
  return items;
}

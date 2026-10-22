import '../error/exceptions.dart';

/// Every response — success or error — has the same envelope:
///
/// ```json
/// { "statusCode": 200, "message": "success", "data": { } }
/// ```
///
/// Data sources only ever see `data`; [ApiClient] unwraps it.
abstract final class ApiEnvelope {
  /// Pulls `data` out of [body]. A response that is not enveloped (a bare
  /// list or object) is passed through unchanged, so a backend tweak cannot
  /// break every call at once.
  static dynamic unwrap(dynamic body) {
    if (body is Map<String, dynamic> && body.containsKey('data')) {
      return body['data'];
    }
    return body;
  }
}

/// Small guards so `fromJson` bodies stay readable.
extension JsonMap on Map<String, dynamic> {
  String str(String key, [String fallback = '']) =>
      this[key] is String ? this[key] as String : fallback;

  String? strOrNull(String key) {
    final value = this[key];
    if (value is! String) return null;
    return value.trim().isEmpty ? null : value;
  }

  int intVal(String key, [int fallback = 0]) =>
      (this[key] as num?)?.toInt() ?? fallback;

  int? intOrNull(String key) => (this[key] as num?)?.toInt();

  num numVal(String key, [num fallback = 0]) => (this[key] as num?) ?? fallback;

  num? numOrNull(String key) => this[key] as num?;

  bool boolVal(String key, {bool fallback = false}) =>
      this[key] is bool ? this[key] as bool : fallback;

  DateTime? dateOrNull(String key) {
    final value = this[key];
    if (value is! String) return null;
    return DateTime.tryParse(value);
  }

  Map<String, dynamic>? mapOrNull(String key) {
    final value = this[key];
    return value is Map<String, dynamic> ? value : null;
  }

  List<Map<String, dynamic>> listOf(String key) =>
      (this[key] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList();
}

/// Parses a payload the API returns as a bare list.
List<T> parseList<T>(
  dynamic json,
  T Function(Map<String, dynamic> item) fromItem,
) {
  if (json is! List) throw const ParsingException('Expected a list');
  return json.whereType<Map<String, dynamic>>().map(fromItem).toList();
}

/// Parses a payload the API returns as a single object.
Map<String, dynamic> asMap(dynamic json) {
  if (json is! Map<String, dynamic>) {
    throw const ParsingException('Expected an object');
  }
  return json;
}

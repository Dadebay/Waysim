import '../error/exceptions.dart';

abstract final class ApiEnvelope {
  static dynamic unwrap(dynamic body) {
    if (body is Map<String, dynamic> && body.containsKey('data')) {
      return body['data'];
    }
    return body;
  }
}

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

List<T> parseList<T>(
  dynamic json,
  T Function(Map<String, dynamic> item) fromItem,
) {
  if (json is! List) throw const ParsingException('Expected a list');
  return json.whereType<Map<String, dynamic>>().map(fromItem).toList();
}

Map<String, dynamic> asMap(dynamic json) {
  if (json is! Map<String, dynamic>) {
    throw const ParsingException('Expected an object');
  }
  return json;
}

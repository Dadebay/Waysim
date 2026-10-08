/// Compares dotted version strings such as `1.4.2`.
abstract final class AppVersion {
  /// `true` when [current] is lower than [minimum]. Missing parts count as 0
  /// (`1.4` == `1.4.0`); anything unparsable is treated as 0 rather than
  /// locking the customer out over a typo on the server.
  static bool isOlder(String current, String minimum) {
    final a = _parts(current);
    final b = _parts(minimum);
    for (var i = 0; i < 3; i++) {
      if (a[i] != b[i]) return a[i] < b[i];
    }
    return false;
  }

  static List<int> _parts(String version) {
    final core = version.split(RegExp(r'[+-]')).first.split('.');
    return [
      for (var i = 0; i < 3; i++)
        i < core.length ? int.tryParse(core[i]) ?? 0 : 0,
    ];
  }
}

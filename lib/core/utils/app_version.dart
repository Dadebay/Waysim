abstract final class AppVersion {
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

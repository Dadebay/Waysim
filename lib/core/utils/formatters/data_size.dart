abstract final class DataSize {
  static const _mb = 1024 * 1024;
  static const _gb = 1024 * _mb;

  static ({String value, bool inGigabytes}) of(int bytes) {
    if (bytes >= _gb) {
      final gb = bytes / _gb;
      final text = gb >= 10 || gb == gb.roundToDouble()
          ? gb.round().toString()
          : gb.toStringAsFixed(1);
      return (value: text, inGigabytes: true);
    }
    return (value: (bytes / _mb).round().toString(), inGigabytes: false);
  }
}

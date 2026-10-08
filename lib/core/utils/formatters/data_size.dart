/// Byte counts as the app shows them: `5 GB`, `3.2 GB`, `850 MB`.
///
/// The supplier reports binary gigabytes (5 GB = 5 368 709 120 bytes), so this
/// divides by 1024. The unit label is passed in because it is translated.
abstract final class DataSize {
  static const _mb = 1024 * 1024;
  static const _gb = 1024 * _mb;

  /// Whole megabytes below 1 GB, otherwise gigabytes with at most one decimal
  /// (a trailing `.0` is dropped).
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

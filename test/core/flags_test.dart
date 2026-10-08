import 'dart:async';
import 'dart:io';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every flag in `assets/flags` has to draw in flutter_svg, which silently
/// skips elements it does not implement (`<marker>`, `<image>`, …) and would
/// leave a half-drawn flag in the app.
void main() {
  test('all flag SVGs parse without unsupported elements', () async {
    final files = Directory('assets/flags')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.svg'))
        .toList();
    expect(files.length, greaterThan(200));

    final warnings = <String>[];
    await runZoned(
      () async {
        for (final file in files) {
          final svg = file.readAsStringSync();
          final loader = SvgStringLoader(svg);
          await vg.loadPicture(loader, null);
        }
      },
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) => warnings.add(line),
      ),
    );

    expect(warnings, isEmpty, reason: warnings.toSet().join('\n'));
  });
}

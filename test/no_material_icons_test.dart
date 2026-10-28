import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lib/ never uses Material Icons', () {
    final offenders = <String>[];
    final pattern = RegExp(r'(?<![A-Za-z])Icons\.[a-z]');
    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      if (file.path.contains('lib/l10n/app_localizations')) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (pattern.hasMatch(lines[i]) &&
            !lines[i].trimLeft().startsWith('//')) {
          offenders.add('${file.path}:${i + 1}');
        }
      }
    }
    expect(offenders, isEmpty, reason: 'Use AppIcons + HugeIcon instead.');
  });
}

import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/core/theme/app_color_tokens.dart';

double contrast(Color a, Color b) {
  double lum(Color c) {
    double channel(double v) => v <= 0.03928
        ? v / 12.92
        : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * channel(c.r) +
        0.7152 * channel(c.g) +
        0.0722 * channel(c.b);
  }

  final l1 = lum(a);
  final l2 = lum(b);
  final hi = math.max(l1, l2);
  final lo = math.min(l1, l2);
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  List<(String, Color, Color)> pairs(AppColorTokens t) => [
    ('textPrimary on background', t.textPrimary, t.background),
    ('textPrimary on surface', t.textPrimary, t.surface),
    ('textSecondary on background', t.textSecondary, t.background),
    ('textSecondary on surface', t.textSecondary, t.surface),
    ('textOnPrimary on primary', t.textOnPrimary, t.primary),
    ('textOnPrimary on primaryPressed', t.textOnPrimary, t.primaryPressed),
    ('link on primarySubtle', t.link, t.primarySubtle),
    ('link on background', t.link, t.background),
    ('error on background', t.error, t.background),
    ('errorText on errorSubtle', t.errorText, t.errorSubtle),
    ('successText on successSubtle', t.successText, t.successSubtle),
    ('success on background', t.success, t.background),
    ('warning on warningSubtle', t.warning, t.warningSubtle),
    ('warning on background', t.warning, t.background),
  ];

  for (final (name, tokens) in [
    ('light', AppColorTokens.light),
    ('dark', AppColorTokens.dark),
  ]) {
    test('$name theme text reaches 4.5:1', () {
      final failures = <String>[];
      for (final (label, fg, bg) in pairs(tokens)) {
        final ratio = contrast(fg, bg);
        if (ratio < 4.5) failures.add('$label = ${ratio.toStringAsFixed(2)}');
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });
  }
}

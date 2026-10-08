import 'package:flutter/material.dart';

/// Type scale from the design system (sizes and line heights are the
/// design's), set in **Gilroy** throughout — chosen by the project owner over
/// the design file's Unbounded + Onest. Weights ship as static files
/// (400/500/600/700), so there is no variable-font plumbing.
///
/// Gilroy has no Chinese glyphs; [_cjkFallback] hands those characters to the
/// platform's CJK face.
abstract final class AppTypography {
  static const family = 'Gilroy';

  static const _cjkFallback = [
    'PingFang SC',
    'Noto Sans SC',
    'Noto Sans CJK SC',
    'Roboto',
  ];

  static TextStyle _style({
    required double size,
    required double height,
    required FontWeight weight,
    double letterSpacing = 0,
  }) => TextStyle(
    fontFamily: family,
    fontFamilyFallback: _cjkFallback,
    fontSize: size,
    // Flutter's `height` is a multiple of the font size; the spec gives
    // pixel line heights.
    height: height / size,
    fontWeight: weight,
    letterSpacing: letterSpacing,
  );

  static TextStyle get display => _style(
    size: 32,
    height: 38,
    weight: FontWeight.w700,
    letterSpacing: -0.4,
  );
  static TextStyle get h1 => _style(
    size: 26,
    height: 32,
    weight: FontWeight.w700,
    letterSpacing: -0.3,
  );
  static TextStyle get h2 =>
      _style(size: 20, height: 26, weight: FontWeight.w700);
  static TextStyle get h3 =>
      _style(size: 17, height: 24, weight: FontWeight.w600);
  static TextStyle get body =>
      _style(size: 16, height: 24, weight: FontWeight.w400);
  static TextStyle get bodyMedium =>
      _style(size: 15, height: 22, weight: FontWeight.w500);
  static TextStyle get bodySmall =>
      _style(size: 14, height: 20, weight: FontWeight.w400);
  static TextStyle get caption =>
      _style(size: 12, height: 16, weight: FontWeight.w400);

  /// Buttons and tabs.
  static TextStyle get label =>
      _style(size: 16, height: 24, weight: FontWeight.w600);
}

/// The design system's names on top of Material's [TextTheme] slots, so a
/// widget writes `context.text.h2` rather than `textTheme.headlineMedium`.
extension AppTextStyles on TextTheme {
  TextStyle get display => displayLarge!;
  TextStyle get h1 => headlineLarge!;
  TextStyle get h2 => headlineMedium!;
  TextStyle get h3 => headlineSmall!;
  TextStyle get body => bodyLarge!;
  TextStyle get bodyMed => titleMedium!;
  TextStyle get bodySm => bodyMedium!;
  TextStyle get caption => labelSmall!;
  TextStyle get label => labelLarge!;
}

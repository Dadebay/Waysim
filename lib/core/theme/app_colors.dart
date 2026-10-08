import 'package:flutter/material.dart';

/// Raw palette, straight from the design system (docs/02-design-system.md).
/// Never reference these from widgets — go through [AppColorTokens]
/// (`context.colors`) so light and dark stay in step.
abstract final class AppColors {
  // Brand mark accent (the map pin in the logo). Not a UI token.
  static const brandAccent = Color(0xFFF2B84B);

  // ------------------------------------------------------------- light --
  static const primaryLight = Color(0xFF2F4E8F);
  static const primaryPressedLight = Color(0xFF26406F);
  static const primarySubtleLight = Color(0xFFEAEFF8);
  static const linkLight = Color(0xFF2F4E8F);
  static const backgroundLight = Color(0xFFFFFFFF);
  static const surfaceLight = Color(0xFFF5F7FA);
  static const textPrimaryLight = Color(0xFF161D2B);
  static const textSecondaryLight = Color(0xFF667085);
  static const borderLight = Color(0xFFE3E8EF);
  static const successLight = Color(0xFF12855A);
  static const warningLight = Color(0xFFB54708);
  static const errorLight = Color(0xFFD92D20);
  static const errorSubtleLight = Color(0xFFFEF3F2);

  // Not in the spec's token table: the tinted fills behind the green and
  // orange status badges, read off the design renders.
  static const successSubtleLight = Color(0xFFE7F5EE);

  // Darker shades of success / error for small text on their tinted fills:
  // the spec colours reach only 4.1–4.4:1 there (WCAG AA wants 4.5:1).
  static const successTextLight = Color(0xFF0E6B49);
  static const errorTextLight = Color(0xFFB42318);
  static const warningSubtleLight = Color(0xFFFDF0E1);

  // -------------------------------------------------------------- dark --
  static const primaryDark = Color(0xFF4A6CB8);
  static const primaryPressedDark = Color(0xFF3D5A9C);
  static const primarySubtleDark = Color(0xFF1C2740);
  static const linkDark = Color(0xFF8FA9E0);
  static const backgroundDark = Color(0xFF0E121A);
  static const surfaceDark = Color(0xFF161B25);
  static const textPrimaryDark = Color(0xFFF2F4F8);
  static const textSecondaryDark = Color(0xFF98A2B3);
  static const borderDark = Color(0xFF2A3242);
  static const successDark = Color(0xFF3CCB8A);
  static const warningDark = Color(0xFFF79009);
  static const errorDark = Color(0xFFF97066);
  static const errorSubtleDark = Color(0xFF3A1714);
  static const successSubtleDark = Color(0xFF12281F);
  static const successTextDark = Color(0xFF3CCB8A);
  static const errorTextDark = Color(0xFFF97066);
  static const warningSubtleDark = Color(0xFF33220F);

  static const textOnPrimary = Color(0xFFFFFFFF);
}

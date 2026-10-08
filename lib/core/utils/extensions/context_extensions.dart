import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/app_color_tokens.dart';

/// Re-exported so `context.text.h2` works from this one import.
export '../../theme/app_typography.dart' show AppTextStyles;

/// Shorthands that cut the boilerplate in every widget build method.
extension BuildContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  ThemeData get theme => Theme.of(this);

  /// The design system's text styles — `context.text.h2`, `context.text.body`.
  TextTheme get text => Theme.of(this).textTheme;

  /// Semantic color tokens for the current brightness.
  AppColorTokens get colors => Theme.of(this).extension<AppColorTokens>()!;

  Size get screenSize => MediaQuery.sizeOf(this);
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/app_color_tokens.dart';

export '../../theme/app_typography.dart' show AppTextStyles;

extension BuildContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  ThemeData get theme => Theme.of(this);

  TextTheme get text => Theme.of(this).textTheme;

  AppColorTokens get colors => Theme.of(this).extension<AppColorTokens>()!;

  Size get screenSize => MediaQuery.sizeOf(this);
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

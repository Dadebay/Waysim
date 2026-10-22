import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;

import 'app_color_tokens.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// The two [ThemeData]s. Everything visual derives from [AppColorTokens].
abstract final class AppTheme {
  static ThemeData get light => _build(AppColorTokens.light, Brightness.light);
  static ThemeData get dark => _build(AppColorTokens.dark, Brightness.dark);

  static ThemeData _build(AppColorTokens c, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.textOnPrimary,
      primaryContainer: c.primarySubtle,
      onPrimaryContainer: c.primary,
      secondary: c.primary,
      onSecondary: c.textOnPrimary,
      error: c.error,
      onError: c.textOnPrimary,
      errorContainer: c.errorSubtle,
      onErrorContainer: c.error,
      surface: c.background,
      onSurface: c.textPrimary,
      onSurfaceVariant: c.textSecondary,
      surfaceContainerHighest: c.surface,
      outline: c.border,
      outlineVariant: c.border,
      shadow: c.shadow,
    );

    final textTheme = TextTheme(
      displayLarge: AppTypography.display,
      headlineLarge: AppTypography.h1,
      headlineMedium: AppTypography.h2,
      headlineSmall: AppTypography.h3,
      bodyLarge: AppTypography.body,
      titleMedium: AppTypography.bodyMedium,
      bodyMedium: AppTypography.bodySmall,
      labelSmall: AppTypography.caption,
      labelLarge: AppTypography.label,
    ).apply(bodyColor: c.textPrimary, displayColor: c.textPrimary);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      fontFamily: AppTypography.family,
      textTheme: textTheme,
      extensions: [c],
      dividerTheme: DividerThemeData(color: c.border, space: 1, thickness: 1),
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.h3,
        foregroundColor: c.textPrimary,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
        showDragHandle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheet),
          ),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}

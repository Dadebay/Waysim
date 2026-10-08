import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Semantic color tokens, one set per brightness. Widgets read these through
/// `context.colors`; they never touch [AppColors] or a `Color(0x…)` literal.
@immutable
class AppColorTokens extends ThemeExtension<AppColorTokens> {
  const AppColorTokens({
    required this.primary,
    required this.primaryPressed,
    required this.primarySubtle,
    required this.link,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textOnPrimary,
    required this.border,
    required this.success,
    required this.successText,
    required this.successSubtle,
    required this.warning,
    required this.warningSubtle,
    required this.error,
    required this.errorText,
    required this.errorSubtle,
    required this.shadow,
  });

  final Color primary;
  final Color primaryPressed;
  final Color primarySubtle;
  final Color link;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color textOnPrimary;
  final Color border;
  final Color success;

  /// [success] darkened for small text on [successSubtle].
  final Color successText;
  final Color successSubtle;
  final Color warning;
  final Color warningSubtle;
  final Color error;

  /// [error] darkened for small text on [errorSubtle].
  final Color errorText;
  final Color errorSubtle;

  /// Base color of card and accent shadows.
  final Color shadow;

  static const light = AppColorTokens(
    primary: AppColors.primaryLight,
    primaryPressed: AppColors.primaryPressedLight,
    primarySubtle: AppColors.primarySubtleLight,
    link: AppColors.linkLight,
    background: AppColors.backgroundLight,
    surface: AppColors.surfaceLight,
    textPrimary: AppColors.textPrimaryLight,
    textSecondary: AppColors.textSecondaryLight,
    textOnPrimary: AppColors.textOnPrimary,
    border: AppColors.borderLight,
    success: AppColors.successLight,
    successText: AppColors.successTextLight,
    successSubtle: AppColors.successSubtleLight,
    warning: AppColors.warningLight,
    warningSubtle: AppColors.warningSubtleLight,
    error: AppColors.errorLight,
    errorText: AppColors.errorTextLight,
    errorSubtle: AppColors.errorSubtleLight,
    shadow: Color(0x1A161D2B),
  );

  static const dark = AppColorTokens(
    primary: AppColors.primaryDark,
    primaryPressed: AppColors.primaryPressedDark,
    primarySubtle: AppColors.primarySubtleDark,
    link: AppColors.linkDark,
    background: AppColors.backgroundDark,
    surface: AppColors.surfaceDark,
    textPrimary: AppColors.textPrimaryDark,
    textSecondary: AppColors.textSecondaryDark,
    textOnPrimary: AppColors.textOnPrimary,
    border: AppColors.borderDark,
    success: AppColors.successDark,
    successText: AppColors.successTextDark,
    successSubtle: AppColors.successSubtleDark,
    warning: AppColors.warningDark,
    warningSubtle: AppColors.warningSubtleDark,
    error: AppColors.errorDark,
    errorText: AppColors.errorTextDark,
    errorSubtle: AppColors.errorSubtleDark,
    shadow: Color(0x66000000),
  );

  @override
  AppColorTokens copyWith({
    Color? primary,
    Color? primaryPressed,
    Color? primarySubtle,
    Color? link,
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? textOnPrimary,
    Color? border,
    Color? success,
    Color? successText,
    Color? successSubtle,
    Color? warning,
    Color? warningSubtle,
    Color? error,
    Color? errorText,
    Color? errorSubtle,
    Color? shadow,
  }) => AppColorTokens(
    primary: primary ?? this.primary,
    primaryPressed: primaryPressed ?? this.primaryPressed,
    primarySubtle: primarySubtle ?? this.primarySubtle,
    link: link ?? this.link,
    background: background ?? this.background,
    surface: surface ?? this.surface,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textOnPrimary: textOnPrimary ?? this.textOnPrimary,
    border: border ?? this.border,
    success: success ?? this.success,
    successText: successText ?? this.successText,
    successSubtle: successSubtle ?? this.successSubtle,
    warning: warning ?? this.warning,
    warningSubtle: warningSubtle ?? this.warningSubtle,
    error: error ?? this.error,
    errorText: errorText ?? this.errorText,
    errorSubtle: errorSubtle ?? this.errorSubtle,
    shadow: shadow ?? this.shadow,
  );

  @override
  AppColorTokens lerp(ThemeExtension<AppColorTokens>? other, double t) {
    if (other is! AppColorTokens) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColorTokens(
      primary: mix(primary, other.primary),
      primaryPressed: mix(primaryPressed, other.primaryPressed),
      primarySubtle: mix(primarySubtle, other.primarySubtle),
      link: mix(link, other.link),
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
      textPrimary: mix(textPrimary, other.textPrimary),
      textSecondary: mix(textSecondary, other.textSecondary),
      textOnPrimary: mix(textOnPrimary, other.textOnPrimary),
      border: mix(border, other.border),
      success: mix(success, other.success),
      successText: mix(successText, other.successText),
      successSubtle: mix(successSubtle, other.successSubtle),
      warning: mix(warning, other.warning),
      warningSubtle: mix(warningSubtle, other.warningSubtle),
      error: mix(error, other.error),
      errorText: mix(errorText, other.errorText),
      errorSubtle: mix(errorSubtle, other.errorSubtle),
      shadow: mix(shadow, other.shadow),
    );
  }
}

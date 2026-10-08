import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

/// Persists the user's theme choice across launches (hydrated_bloc).
///
/// Light is the default (docs/01-product-spec.md); the settings screen offers
/// Light and Dark.
class ThemeCubit extends HydratedCubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light);

  void setThemeMode(ThemeMode mode) => emit(mode);

  @override
  ThemeMode? fromJson(Map<String, dynamic> json) =>
      ThemeMode.values.asNameMap()[json['themeMode'] as String?];

  @override
  Map<String, dynamic>? toJson(ThemeMode state) => {'themeMode': state.name};
}

import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// Builds the light/dark [ThemeData] from [AppColors]. Feature pages should
/// still read colors via `context.colors` (see app_colors.dart) rather than
/// `Theme.of(context).colorScheme` — this ThemeData mainly wires up
/// scaffold/background defaults and the app-wide font family.
class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(AppColors.light, Brightness.light);
  static ThemeData get dark => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors colors, Brightness brightness) {
    final base = ColorScheme.fromSeed(
      seedColor: colors.textPrimary,
      brightness: brightness,
    ).copyWith(
      primary: colors.primaryAction,
      onPrimary: colors.onPrimaryAction,
      surface: colors.surface,
      onSurface: colors.textPrimary,
      error: colors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: AppTextStyles.fontFamily,
      scaffoldBackgroundColor: colors.background,
      colorScheme: base,
      dividerColor: colors.border,
      splashFactory: InkRipple.splashFactory,
    );
  }
}

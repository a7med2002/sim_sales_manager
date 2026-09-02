import 'package:flutter/material.dart';

/// Full color palette for one brightness mode. See design/DESIGN_SYSTEM.md
/// for the source-of-truth values — do not introduce new colors here without
/// updating that file first.
class AppColors {
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color success;
  final Color danger;
  final Color warning;

  /// Primary action fill (solid buttons, active nav item, active filter pill).
  /// Inverts between light/dark so it always reads as the highest-contrast
  /// "ink" color against [background].
  final Color primaryAction;

  /// Text/icon color to use on top of [primaryAction].
  final Color onPrimaryAction;

  const AppColors({
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.success,
    required this.danger,
    required this.warning,
    required this.primaryAction,
    required this.onPrimaryAction,
  });

  static const light = AppColors(
    background: Color(0xFFFAFAFA),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF0A0A0A),
    textSecondary: Color(0xFF6B6B6B),
    border: Color(0xFFE5E5E5),
    success: Color(0xFF16A34A),
    danger: Color(0xFFDC2626),
    warning: Color(0xFFD97706),
    primaryAction: Color(0xFF0A0A0A),
    onPrimaryAction: Color(0xFFFFFFFF),
  );

  static const dark = AppColors(
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    textPrimary: Color(0xFFF5F5F5),
    textSecondary: Color(0xFFA0A0A0),
    border: Color(0xFF2A2A2A),
    success: Color(0xFF16A34A),
    danger: Color(0xFFDC2626),
    warning: Color(0xFFD97706),
    primaryAction: Color(0xFFF5F5F5),
    onPrimaryAction: Color(0xFF0A0A0A),
  );
}

/// Convenience accessor: `context.colors.textPrimary`.
extension AppColorsX on BuildContext {
  AppColors get colors =>
      Theme.of(this).brightness == Brightness.dark ? AppColors.dark : AppColors.light;
}

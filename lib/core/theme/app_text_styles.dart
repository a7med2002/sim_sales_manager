import 'package:flutter/material.dart';

/// Typography scale. See design/DESIGN_SYSTEM.md.
/// Every style takes an explicit color so pages never hardcode one inline —
/// callers pass `context.colors.textPrimary` / `.textSecondary` / etc.
class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'IBMPlexSansArabic';

  static TextStyle pageTitle(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle sectionHeader(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
      );

  /// Small uppercase label used above grouped sections (e.g. "SALES & PROFIT").
  static TextStyle overline(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        color: color,
      );

  static TextStyle cardTitle(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle body(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: color,
      );

  /// A text field's placeholder — deliberately smaller than [body] (13px,
  /// the size every field's label above it already uses) and lighter
  /// than whatever color is passed in, so a hint never competes visually
  /// with its own label or the value the user actually types. Callers
  /// still pass `colors.textSecondary` like any other secondary text —
  /// the extra fade is baked in here, not something each call site needs
  /// to remember.
  static TextStyle hint(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color.withValues(alpha: 0.65),
      );

  static TextStyle statNumber(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle badge(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: color,
      );
}

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'circular_icon_button.dart';
import 'sync_status_indicator.dart';

/// Page header: title (+ optional subtitle) on the leading side, an optional
/// dark/light mode toggle on the trailing side. Main nav pages have no back
/// arrow; sub-pages inside "More" pass [showBack]. [showBrandMark] shows a
/// small app-icon badge instead — only meant for Home, the app's one true
/// "front door" screen, so the brand identity shows up somewhere inside the
/// app itself and not only on Login/the launcher icon. [showSyncStatus]
/// defaults on, but the pre-login auth flow (Forgot/Reset Password — Login
/// itself doesn't use this widget) passes it off: "sync" is a signed-in
/// account concept, and showing/tapping it before anyone's signed in
/// exposed a raw, alarming-looking network exception instead of anything
/// meaningful.
class AppTopBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBack;
  final VoidCallback? onBack;
  final bool showBrandMark;
  final bool showSyncStatus;
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;
  final List<Widget>? actions;

  /// Overrides the default `AppTextStyles.pageTitle` size — Home's own
  /// "Welcome back, {name}" greeting is a full sentence rather than a
  /// short page label, so it wrapped to two lines and looked off at the
  /// default 24px; passing `AppTextStyles.sectionHeader` there keeps
  /// every other page's title untouched.
  final TextStyle? titleStyle;

  const AppTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = false,
    this.onBack,
    this.showBrandMark = false,
    this.showSyncStatus = true,
    this.isDarkMode = false,
    this.onThemeToggle,
    this.actions,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showBack)
          IconButton(
            onPressed: onBack ?? () => Navigator.maybePop(context),
            icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        if (showBack) const SizedBox(width: 8),
        if (showBrandMark) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset('assets/icons/icon.png', width: 40, height: 40, fit: BoxFit.cover),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: titleStyle ?? AppTextStyles.pageTitle(colors.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: AppTextStyles.body(colors.textSecondary)),
              ],
            ],
          ),
        ),
        // Every trailing icon (sync, theme toggle, notifications, ...)
        // shares `CircularIconButton`'s look — same 40x40 bordered circle,
        // same 18px icon size, same level — so none of them can drift out
        // of visual sync with each other again. `_trailingGap` between
        // each one that's actually present, none before the first.
        for (final (index, widget) in _trailingIcons.indexed) ...[
          if (index > 0) const SizedBox(width: _trailingGap),
          widget,
        ],
      ],
    );
  }

  static const _trailingGap = 6.0;

  List<Widget> get _trailingIcons => [
        if (showSyncStatus) const SyncStatusIndicator(),
        if (onThemeToggle != null) _ThemeToggleButton(isDark: isDarkMode, onTap: onThemeToggle!),
        ...?actions,
      ];
}

class _ThemeToggleButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _ThemeToggleButton({required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CircularIconButton(
      icon: isDark ? Icons.dark_mode_rounded : Icons.wb_sunny_outlined,
      iconColor: colors.textPrimary,
      onTap: onTap,
    );
  }
}

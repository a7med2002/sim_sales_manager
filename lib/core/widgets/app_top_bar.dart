import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Page header: title (+ optional subtitle) on the leading side, an optional
/// dark/light mode toggle on the trailing side. Main nav pages have no back
/// arrow; sub-pages inside "More" pass [showBack].
class AppTopBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBack;
  final VoidCallback? onBack;
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const AppTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = false,
    this.onBack,
    this.isDarkMode = false,
    this.onThemeToggle,
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: AppTextStyles.pageTitle(colors.textPrimary)),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: AppTextStyles.body(colors.textSecondary)),
              ],
            ],
          ),
        ),
        if (onThemeToggle != null) _ThemeToggleButton(isDark: isDarkMode, onTap: onThemeToggle!),
      ],
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _ThemeToggleButton({required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: colors.border),
        ),
        child: Icon(
          isDark ? Icons.dark_mode_rounded : Icons.wb_sunny_outlined,
          color: colors.textPrimary,
          size: 18,
        ),
      ),
    );
  }
}

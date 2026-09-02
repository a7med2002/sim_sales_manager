import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Settings/menu-style navigation row: leading icon, title, trailing
/// chevron. Full-width tap target. Used on More and its sub-pages.
class ListRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;
  final bool showChevron;

  const ListRow({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.titleColor,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        child: Row(
          children: [
            Icon(icon, size: 22, color: iconColor ?? colors.textPrimary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(title, style: AppTextStyles.cardTitle(titleColor ?? colors.textPrimary)),
            ),
            if (showChevron) Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }
}

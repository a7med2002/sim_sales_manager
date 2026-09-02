import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Icon in a tinted circular background, a secondary-text title, a bold big
/// number, and an optional caption. See design/DESIGN_SYSTEM.md.
class StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final Color? valueColor;
  final String? caption;

  const StatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    this.valueColor,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body(colors.textSecondary).copyWith(letterSpacing: 0.3),
          ),
          const SizedBox(height: 4),
          // Scales long values (e.g. a 6-digit currency amount) down to fit
          // one line instead of wrapping to two — keeps every StatCard's
          // number reading at the same visual weight regardless of how
          // long the formatted value happens to be, rather than some
          // cards' numbers looking "bigger" than others just because they
          // wrapped and others didn't.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, maxLines: 1, style: AppTextStyles.statNumber(valueColor ?? colors.textPrimary)),
          ),
          if (caption != null) ...[
            const SizedBox(height: 4),
            Text(caption!, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.body(colors.textSecondary)),
          ],
        ],
      ),
    );
  }
}

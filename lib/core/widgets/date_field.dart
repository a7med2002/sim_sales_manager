import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Labeled tappable date box (label above, "d/m/yyyy" + calendar icon)
/// that opens the platform date picker on tap. Used by any Add/Edit form
/// with a purchase/expiry-style date pair.
class DateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const DateField({super.key, required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.body(colors.textSecondary)),
        const SizedBox(height: AppSpacing.xs),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadii.button),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '${date.day}/${date.month}/${date.year}',
                    style: AppTextStyles.cardTitle(colors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(Icons.calendar_today_outlined, size: 16, color: colors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Centered icon + title + description, with an optional CTA. Used whenever
/// a list has no data yet so the UI never looks broken.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // `width: double.infinity` forces this to claim the full width its
    // parent allows, even when that parent is a `Column` with
    // `crossAxisAlignment: start` (the common case — most pages wrap
    // their content in a start-aligned Column) — without it, this widget
    // shrinks to the width of its widest child (the description text)
    // and that whole narrow block then sits pinned to the left edge
    // instead of centered across the screen.
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl, horizontal: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: colors.border.withValues(alpha: 0.4), shape: BoxShape.circle),
              child: Icon(icon, color: colors.textSecondary, size: 28),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: AppTextStyles.cardTitle(colors.textPrimary), textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text(
              description,
              style: AppTextStyles.body(colors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.md),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

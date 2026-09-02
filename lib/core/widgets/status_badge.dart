import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum StatusBadgeType { success, warning, danger, neutral }

/// Small colored pill for payment/line/device statuses (paid, unpaid,
/// expiring soon, blocked, etc). See design/DESIGN_SYSTEM.md.
class StatusBadge extends StatelessWidget {
  final String label;
  final StatusBadgeType type;

  const StatusBadge({super.key, required this.label, required this.type});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final Color accent = switch (type) {
      StatusBadgeType.success => colors.success,
      StatusBadgeType.warning => colors.warning,
      StatusBadgeType.danger => colors.danger,
      StatusBadgeType.neutral => colors.textSecondary,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(label, style: AppTextStyles.badge(accent)),
    );
  }
}

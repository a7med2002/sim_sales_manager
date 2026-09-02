import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// A single pill button. Active = solid [AppColors.primaryAction] fill with
/// [AppColors.onPrimaryAction] text. Inactive = outlined, secondary text.
class FilterPill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const FilterPill({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isActive ? colors.primaryAction : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: isActive ? colors.primaryAction : colors.border),
        ),
        child: Text(
          label,
          style: AppTextStyles.body(isActive ? colors.onPrimaryAction : colors.textPrimary)
              .copyWith(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

/// Horizontally scrollable row of [FilterPill]s — used for period/status
/// filters (Today/Week/Month..., All/Active/Expired...).
class FilterPillRow extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const FilterPillRow({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: labels.length,
      separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
      itemBuilder: (context, index) {
        return FilterPill(
          label: labels[index],
          isActive: index == selectedIndex,
          onTap: () => onSelected(index),
        );
      },
    );
  }
}

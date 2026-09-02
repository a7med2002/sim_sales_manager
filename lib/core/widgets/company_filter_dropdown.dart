import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../catalog/company_summary.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// "All Companies" + one entry per company dropdown filter — shared by
/// Numbers and Reports (both filter a table by supplier company).
class CompanyFilterDropdown extends StatelessWidget {
  final List<CompanySummary> companies;
  final String? value;
  final ValueChanged<String?> onChanged;

  const CompanyFilterDropdown({super.key, required this.companies, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PopupMenuButton<String?>(
      initialValue: value,
      color: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button), side: BorderSide(color: colors.border)),
      onSelected: onChanged,
      itemBuilder: (context) => [
        PopupMenuItem<String?>(value: null, child: Text('common.allCompanies'.tr(), style: AppTextStyles.body(colors.textPrimary))),
        ...companies.map((c) => PopupMenuItem<String?>(value: c.name, child: Text(c.name, style: AppTextStyles.body(colors.textPrimary)))),
      ],
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
            Flexible(child: Text(value ?? 'common.allCompanies'.tr(), style: AppTextStyles.body(colors.textPrimary), overflow: TextOverflow.ellipsis)),
            Icon(Icons.keyboard_arrow_down_rounded, color: colors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

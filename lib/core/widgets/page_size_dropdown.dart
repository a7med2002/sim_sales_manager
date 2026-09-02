import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../constants/page_size_options.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// "Show: 50/100/200/All" dropdown for capping a table/log's visible row
/// count. Shared by Numbers, Activity Log, and any future table page.
class PageSizeDropdown extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const PageSizeDropdown({super.key, required this.value, required this.onChanged});

  String _labelFor(int size) => size == -1 ? 'common.all'.tr() : '$size';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PopupMenuButton<int>(
      initialValue: value,
      color: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button), side: BorderSide(color: colors.border)),
      onSelected: onChanged,
      itemBuilder: (context) =>
          pageSizeOptions.map((s) => PopupMenuItem<int>(value: s, child: Text(_labelFor(s), style: AppTextStyles.body(colors.textPrimary)))).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadii.button),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${'common.show'.tr()}: ${_labelFor(value)}', style: AppTextStyles.body(colors.textPrimary)),
            Icon(Icons.keyboard_arrow_down_rounded, color: colors.textSecondary, size: 16),
          ],
        ),
      ),
    );
  }
}

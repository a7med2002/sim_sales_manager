import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// New Sale sheet header: drag handle, title/step subtitle (+ back arrow
/// from step 2 onward), and a 4-segment progress bar.
class StepProgressHeader extends StatelessWidget {
  final int stepNumber; // 1-4
  final String stepLabel;
  final bool showBack;
  final VoidCallback? onBack;
  final VoidCallback onClose;

  const StepProgressHeader({
    super.key,
    required this.stepNumber,
    required this.stepLabel,
    required this.showBack,
    required this.onClose,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            decoration: BoxDecoration(color: colors.border, borderRadius: BorderRadius.circular(AppRadii.pill)),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showBack)
              GestureDetector(
                onTap: onBack,
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm, top: 2),
                  child: Icon(Icons.chevron_left_rounded, color: colors.textPrimary, size: 24),
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('nav.newSale'.tr(), style: AppTextStyles.sectionHeader(colors.textPrimary)),
                  Text('$stepNumber/4 · $stepLabel', style: AppTextStyles.body(colors.textSecondary)),
                ],
              ),
            ),
            GestureDetector(
              onTap: onClose,
              child: Icon(Icons.close_rounded, color: colors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: List.generate(4, (i) {
            final isFilled = i < stepNumber;
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: i == 3 ? 0 : 4),
                decoration: BoxDecoration(
                  color: isFilled ? colors.primaryAction : colors.border,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

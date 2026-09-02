import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/currency_formatter.dart';

/// Company logo (initials circle) + name, a usage % pill, a progress bar,
/// then consumed / available / owed data rows. See design/DESIGN_SYSTEM.md.
class BalanceProgressCard extends StatelessWidget {
  final String name;
  final String initials;
  final String typeLabel;
  final int usagePercent;
  final double consumed;
  final double availableToSell;
  final double owedToCompany;

  const BalanceProgressCard({
    super.key,
    required this.name,
    required this.initials,
    required this.typeLabel,
    required this.usagePercent,
    required this.consumed,
    required this.availableToSell,
    required this.owedToCompany,
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
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: colors.background, shape: BoxShape.circle, border: Border.all(color: colors.border)),
                alignment: Alignment.center,
                child: Text(initials, style: AppTextStyles.cardTitle(colors.textPrimary)),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTextStyles.cardTitle(colors.textPrimary)),
                    Text(typeLabel, style: AppTextStyles.body(colors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  border: Border.all(color: colors.border),
                ),
                child: Text('common.balanceUsedPercent'.tr(namedArgs: {'percent': '$usagePercent'}), style: AppTextStyles.badge(colors.textPrimary)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: LinearProgressIndicator(
              value: (usagePercent / 100).clamp(0, 1).toDouble(),
              minHeight: 6,
              backgroundColor: colors.border,
              valueColor: AlwaysStoppedAnimation(colors.primaryAction),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _DataColumn(label: 'companies.card.consumed'.tr(), value: formatCurrency(consumed), color: colors.textPrimary),
              _DataColumn(label: 'companies.card.availableToSell'.tr(), value: formatCurrency(availableToSell), color: colors.textPrimary),
              _DataColumn(
                label: 'companies.card.owedToCompany'.tr(),
                value: formatCurrency(owedToCompany),
                color: owedToCompany > 0 ? colors.danger : colors.textPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DataColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DataColumn({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.body(colors.textSecondary)),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.cardTitle(color)),
        ],
      ),
    );
  }
}

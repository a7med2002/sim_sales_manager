import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/customer.dart';

/// Customer list row: star (if pinned) + name + status badge, contact
/// number, lines/spent/owed summary, last purchase date, tag chips, and a
/// trailing chevron. Tap navigates to Customer Detail.
class CustomerCard extends StatelessWidget {
  final Customer customer;
  final int lineCount;
  final double totalSpent;
  final double totalOwed;
  final DateTime? lastPurchase;
  final VoidCallback onTap;

  const CustomerCard({
    super.key,
    required this.customer,
    required this.lineCount,
    required this.totalSpent,
    required this.totalOwed,
    required this.lastPurchase,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (customer.pinned) ...[
                        Icon(Icons.star_rounded, size: 16, color: colors.warning),
                        const SizedBox(width: 4),
                      ],
                      Flexible(child: Text(customer.name, style: AppTextStyles.cardTitle(colors.textPrimary))),
                      const SizedBox(width: AppSpacing.xs),
                      _statusBadge(customer.status),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(customer.contactNumber, style: AppTextStyles.body(colors.textSecondary)),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('customers.card.lines'.tr(namedArgs: {'count': '$lineCount'}), style: AppTextStyles.body(colors.textSecondary)),
                      Text('customers.card.totalSpent'.tr(namedArgs: {'amount': formatCurrency(totalSpent)}), style: AppTextStyles.body(colors.textSecondary)),
                      Text(
                        'customers.card.owed'.tr(namedArgs: {'amount': formatCurrency(totalOwed)}),
                        style: AppTextStyles.body(totalOwed > 0 ? colors.danger : colors.textSecondary),
                      ),
                    ],
                  ),
                  if (lastPurchase != null) ...[
                    const SizedBox(height: 2),
                    Text('customers.card.lastPurchase'.tr(namedArgs: {'date': formatDate(lastPurchase!)}), style: AppTextStyles.body(colors.textSecondary)),
                  ],
                  if (customer.tags.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: customer.tags.map((tag) => _TagChip(label: tag)).toList(),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(CustomerStatus status) {
    switch (status) {
      case CustomerStatus.normal:
        return StatusBadge(label: status.label, type: StatusBadgeType.success);
      case CustomerStatus.troubled:
        return StatusBadge(label: status.label, type: StatusBadgeType.warning);
      case CustomerStatus.blocked:
        return StatusBadge(label: status.label, type: StatusBadgeType.danger);
    }
  }
}

class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: colors.border),
      ),
      child: Text(label, style: AppTextStyles.badge(colors.textSecondary)),
    );
  }
}

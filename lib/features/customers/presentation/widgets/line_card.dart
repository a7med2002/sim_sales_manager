import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/package_display.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/line.dart';

/// A single Line/SIM card on the Customer Detail page: company avatar,
/// package name, payment-status + expiry-status badges, sim/company
/// subtitle, then purchase/expiry/price/profit/remaining rows, plus a
/// 3-dot Edit/Delete menu.
class LineCard extends StatelessWidget {
  final Line line;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddPayment;

  const LineCard({
    super.key,
    required this.line,
    required this.onEdit,
    required this.onDelete,
    required this.onAddPayment,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final lineStatus = line.statusAt(DateTime.now());

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: colors.background, shape: BoxShape.circle, border: Border.all(color: colors.border)),
                alignment: Alignment.center,
                child: Text(line.companyInitials, style: AppTextStyles.cardTitle(colors.textPrimary)),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(packageDisplayLabel(line.packageName, line.packageSimType), style: AppTextStyles.cardTitle(colors.textPrimary)),
                    Text('${line.companyName} · ${line.simNumber}', style: AppTextStyles.body(colors.textSecondary)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _paymentBadge(line.paymentStatus),
                  const SizedBox(height: 4),
                  _lineStatusBadge(lineStatus),
                ],
              ),
              PopupMenuButton<VoidCallback>(
                icon: Icon(Icons.more_vert_rounded, color: colors.textSecondary, size: 20),
                padding: EdgeInsets.zero,
                color: colors.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button), side: BorderSide(color: colors.border)),
                onSelected: (action) => action(),
                itemBuilder: (context) => [
                  PopupMenuItem<VoidCallback>(
                    value: onEdit,
                    child: Row(children: [
                      Icon(Icons.edit_outlined, size: 18, color: colors.textPrimary),
                      const SizedBox(width: AppSpacing.sm),
                      Text('customers.line.edit'.tr(), style: AppTextStyles.body(colors.textPrimary)),
                    ]),
                  ),
                  PopupMenuItem<VoidCallback>(
                    value: onDelete,
                    child: Row(children: [
                      Icon(Icons.delete_outline_rounded, size: 18, color: colors.danger),
                      const SizedBox(width: AppSpacing.sm),
                      Text('customers.line.delete'.tr(), style: AppTextStyles.body(colors.danger)),
                    ]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(height: 1, color: colors.border),
          const SizedBox(height: AppSpacing.sm),
          _row(context, 'customers.line.purchaseDate'.tr(), formatDate(line.purchaseDate)),
          _row(context, 'customers.line.expiryDate'.tr(), formatDate(line.expiryDate)),
          _row(context, 'customers.line.retailSalePrice'.tr(), formatCurrency(line.retailPrice)),
          _row(context, 'customers.line.profit'.tr(), formatCurrency(line.profit), valueColor: colors.success),
          _row(
            context,
            'customers.line.remaining'.tr(),
            formatCurrency(line.amountRemaining),
            valueColor: line.amountRemaining > 0 ? colors.danger : colors.textPrimary,
          ),
          if (line.amountRemaining > 0) ...[
            const SizedBox(height: AppSpacing.xs),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton.icon(
                onPressed: onAddPayment,
                icon: Icon(Icons.payments_outlined, size: 16, color: colors.textPrimary),
                label: Text('customers.line.addPayment'.tr(), style: AppTextStyles.body(colors.textPrimary).copyWith(fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.textPrimary,
                  side: BorderSide(color: colors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value, {Color? valueColor}) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body(colors.textSecondary)),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.body(valueColor ?? colors.textPrimary).copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentBadge(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return StatusBadge(label: status.label, type: StatusBadgeType.success);
      case PaymentStatus.partial:
        return StatusBadge(label: status.label, type: StatusBadgeType.warning);
      case PaymentStatus.unpaid:
        return StatusBadge(label: status.label, type: StatusBadgeType.danger);
    }
  }

  Widget _lineStatusBadge(LineStatus status) {
    switch (status) {
      case LineStatus.active:
        return StatusBadge(label: status.label, type: StatusBadgeType.success);
      case LineStatus.expiringSoon:
        return StatusBadge(label: status.label, type: StatusBadgeType.warning);
      case LineStatus.expired:
        return StatusBadge(label: status.label, type: StatusBadgeType.danger);
    }
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/catalog/line_summary.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/status_badge.dart';
import '../cubit/new_sale_state.dart';

/// Step 4: read-only summary of everything entered so far, before saving.
class ConfirmStep extends StatelessWidget {
  final NewSaleState state;

  const ConfirmStep({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final customerName = state.showNewCustomerForm ? state.newCustomerName : (state.selectedCustomer?.name ?? '');
    final customerContact = state.showNewCustomerForm ? state.newCustomerContact : (state.selectedCustomer?.contactNumber ?? '');
    final paymentStatus = state.paymentStatus;

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
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: colors.background, shape: BoxShape.circle, border: Border.all(color: colors.border)),
                alignment: Alignment.center,
                child: Text(_initialsFor(customerName), style: AppTextStyles.cardTitle(colors.textPrimary)),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customerName, style: AppTextStyles.cardTitle(colors.textPrimary)),
                    Text(customerContact, style: AppTextStyles.body(colors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(height: 1, color: colors.border),
          const SizedBox(height: AppSpacing.sm),
          _row(context, 'newSale.confirmStep.companyLabel'.tr(), state.selectedCompany?.name ?? ''),
          _row(context, 'newSale.confirmStep.packageLabel'.tr(), state.selectedPackage?.name ?? ''),
          _row(context, 'newSale.confirmStep.simLabel'.tr(), state.simNumber),
          _row(context, 'newSale.confirmStep.expiryDateLabel'.tr(), _formatDate(state.expiryDate)),
          _row(context, 'newSale.confirmStep.wholesaleCostLabel'.tr(), formatCurrency(state.wholesaleCost)),
          _row(context, 'newSale.confirmStep.retailSalePriceLabel'.tr(), formatCurrency(state.retailPrice)),
          _row(context, 'newSale.confirmStep.profitLabel'.tr(), formatCurrency(state.profit), valueColor: colors.success),
          _row(context, 'newSale.confirmStep.amountPaidNowLabel'.tr(), formatCurrency(state.amountPaid)),
          _row(context, 'newSale.confirmStep.remainingLabel'.tr(), formatCurrency(state.remaining), valueColor: state.remaining > 0 ? colors.danger : colors.success),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('newSale.confirmStep.statusLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
                StatusBadge(
                  label: paymentStatus.label,
                  type: paymentStatus == LinePaymentStatus.paid
                      ? StatusBadgeType.success
                      : paymentStatus == LinePaymentStatus.partial
                          ? StatusBadgeType.warning
                          : StatusBadgeType.danger,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value, {Color? valueColor}) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body(colors.textSecondary)),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.cardTitle(valueColor ?? colors.textPrimary),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _initialsFor(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return (words.first.substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/catalog/line_summary.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/status_badge.dart';

/// Read-only operation detail sheet — tapping a row in the Operations
/// table "opens operation detail" per APP_CONTEXT.md, without needing a
/// full separate page (the same information already lives in Customer
/// Detail's LineCard; this is just a focused read view from Shipments &
/// Operations' own table).
class OperationDetailSheet {
  static Future<void> show(BuildContext context, LineSummary line) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _OperationDetailContent(line: line),
    );
  }
}

class _OperationDetailContent extends StatelessWidget {
  final LineSummary line;

  const _OperationDetailContent({required this.line});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.card)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('shipmentsOperations.operationDetail.title'.tr(), style: AppTextStyles.sectionHeader(colors.textPrimary)),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(Icons.close_rounded, color: colors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _row(context, 'shipmentsOperations.operationDetail.simLabel'.tr(), line.simNumber),
                _row(context, 'shipmentsOperations.operationDetail.customer'.tr(), line.customerName),
                _row(context, 'shipmentsOperations.operationDetail.contact'.tr(), line.customerContact),
                _row(context, 'shipmentsOperations.operationDetail.company'.tr(), line.companyName),
                _row(context, 'shipmentsOperations.operationDetail.package'.tr(), line.packageName),
                _row(context, 'shipmentsOperations.operationDetail.purchaseDate'.tr(), formatDate(line.purchaseDate)),
                _row(context, 'shipmentsOperations.operationDetail.expiryDate'.tr(), formatDate(line.expiryDate)),
                _row(context, 'shipmentsOperations.operationDetail.wholesaleCost'.tr(), formatCurrency(line.wholesaleCost)),
                _row(context, 'shipmentsOperations.operationDetail.retailSalePrice'.tr(), formatCurrency(line.retailPrice)),
                _row(context, 'shipmentsOperations.operationDetail.profit'.tr(), formatCurrency(line.profit), valueColor: colors.success),
                _row(context, 'shipmentsOperations.operationDetail.amountPaid'.tr(), formatCurrency(line.amountPaid)),
                _row(
                  context,
                  'shipmentsOperations.operationDetail.remaining'.tr(),
                  formatCurrency(line.amountRemaining),
                  valueColor: line.amountRemaining > 0 ? colors.danger : colors.success,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('shipmentsOperations.operationDetail.paymentStatus'.tr(), style: AppTextStyles.body(colors.textSecondary)),
                    _paymentBadge(line.paymentStatus),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value, {Color? valueColor}) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
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

  Widget _paymentBadge(LinePaymentStatus status) {
    switch (status) {
      case LinePaymentStatus.paid:
        return StatusBadge(label: status.label, type: StatusBadgeType.success);
      case LinePaymentStatus.partial:
        return StatusBadge(label: status.label, type: StatusBadgeType.warning);
      case LinePaymentStatus.unpaid:
        return StatusBadge(label: status.label, type: StatusBadgeType.danger);
    }
  }
}

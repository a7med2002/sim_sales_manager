import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/package_display.dart';
import '../../domain/entities/line.dart';

/// Quick "collect a payment" sheet for one specific line — separate from
/// the full Edit Line form since this is the common case: a customer
/// comes back and pays off some or all of what they still owe on that
/// one line, independent of any other lines they have.
class AddPaymentSheet extends StatefulWidget {
  final Line line;
  final void Function(double amount) onAdd;

  const AddPaymentSheet({super.key, required this.line, required this.onAdd});

  static Future<void> show(BuildContext context, {required Line line, required void Function(double) onAdd}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddPaymentSheet(line: line, onAdd: onAdd),
    );
  }

  @override
  State<AddPaymentSheet> createState() => _AddPaymentSheetState();
}

class _AddPaymentSheetState extends State<AddPaymentSheet> {
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    final remaining = widget.line.amountRemaining;
    _amountController = TextEditingController(
      text: remaining == remaining.roundToDouble() ? remaining.toStringAsFixed(0) : remaining.toString(),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get _amount => double.tryParse(_amountController.text.trim()) ?? 0;

  bool get _canSave => _amount > 0 && _amount <= widget.line.amountRemaining;

  void _save() {
    if (!_canSave) return;
    widget.onAdd(_amount);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final line = widget.line;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.card)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('customers.addPaymentSheet.title'.tr(), style: AppTextStyles.sectionHeader(colors.textPrimary)),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(Icons.close_rounded, color: colors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('${packageDisplayLabel(line.packageName, line.packageSimType)} · ${line.simNumber}', style: AppTextStyles.body(colors.textSecondary)),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
                decoration: BoxDecoration(color: colors.background, borderRadius: BorderRadius.circular(AppRadii.button)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('customers.addPaymentSheet.currentlyOwed'.tr(), style: AppTextStyles.body(colors.textSecondary)),
                    Text(formatCurrency(line.amountRemaining), style: AppTextStyles.cardTitle(colors.danger)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('customers.addPaymentSheet.amountToPayNow'.tr(), style: AppTextStyles.body(colors.textSecondary)),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: AppTextStyles.cardTitle(colors.textPrimary),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: colors.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.button), borderSide: BorderSide(color: colors.border)),
                  enabledBorder:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.button), borderSide: BorderSide(color: colors.border)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.button),
                    borderSide: BorderSide(color: colors.primaryAction, width: 1.5),
                  ),
                ),
              ),
              if (_amount > line.amountRemaining) ...[
                const SizedBox(height: 4),
                Text('customers.addPaymentSheet.exceedsOwed'.tr(), style: AppTextStyles.body(colors.danger)),
              ],
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _canSave ? _save : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primaryAction,
                    foregroundColor: colors.onPrimaryAction,
                    disabledBackgroundColor: colors.primaryAction.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button)),
                    elevation: 0,
                  ),
                  child: Text('customers.addPaymentSheet.submit'.tr(), style: AppTextStyles.cardTitle(colors.onPrimaryAction)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

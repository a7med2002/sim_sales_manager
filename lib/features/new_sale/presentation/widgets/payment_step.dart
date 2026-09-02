import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../cubit/new_sale_cubit.dart';
import '../cubit/new_sale_state.dart';

const _paymentMethods = ['Cash', 'Transfer', 'Wallet'];

/// Step 3: amount paid now (+ quick Paid/Unpaid shortcuts), payment
/// method, optional reference number and notes. Remaining is live.
class PaymentStep extends StatefulWidget {
  final NewSaleState state;

  const PaymentStep({super.key, required this.state});

  @override
  State<PaymentStep> createState() => _PaymentStepState();
}

class _PaymentStepState extends State<PaymentStep> {
  late final TextEditingController _amountController;
  late final TextEditingController _referenceController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: _fmt(widget.state.amountPaid));
    _referenceController = TextEditingController(text: widget.state.referenceNumber);
    _notesController = TextEditingController(text: widget.state.notes);
  }

  String _fmt(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  void _setAmount(double value) {
    _amountController.text = _fmt(value);
    context.read<NewSaleCubit>().amountPaidChanged(value);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cubit = context.read<NewSaleCubit>();
    final state = widget.state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('newSale.paymentStep.amountPaidNowLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: AppTextStyles.cardTitle(colors.textPrimary),
          onChanged: (v) => cubit.amountPaidChanged(double.tryParse(v) ?? 0),
          decoration: _decoration(colors),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            OutlinedButton(
              onPressed: () => _setAmount(state.retailPrice),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.textPrimary,
                side: BorderSide(color: colors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button)),
              ),
              child: Text('newSale.paymentStep.paidShortcut'.tr(), style: AppTextStyles.body(colors.textPrimary)),
            ),
            const SizedBox(width: AppSpacing.sm),
            OutlinedButton(
              onPressed: () => _setAmount(0),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.textPrimary,
                side: BorderSide(color: colors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button)),
              ),
              child: Text('newSale.paymentStep.unpaidShortcut'.tr(), style: AppTextStyles.body(colors.textPrimary)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('newSale.paymentStep.retailSalePriceLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
                  Text(formatCurrency(state.retailPrice), style: AppTextStyles.cardTitle(colors.textPrimary)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('newSale.paymentStep.remainingLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
                  Text(
                    formatCurrency(state.remaining),
                    style: AppTextStyles.cardTitle(state.remaining > 0 ? colors.danger : colors.success),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text('newSale.paymentStep.paymentMethodLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
        const SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<String>(
          initialValue: state.paymentMethod,
          style: AppTextStyles.cardTitle(colors.textPrimary),
          dropdownColor: colors.surface,
          decoration: _decoration(colors),
          items: _paymentMethods.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
          onChanged: (value) {
            if (value != null) cubit.paymentMethodChanged(value);
          },
        ),
        const SizedBox(height: AppSpacing.md),
        Text('newSale.paymentStep.referenceNumberLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _referenceController,
          style: AppTextStyles.cardTitle(colors.textPrimary),
          onChanged: cubit.referenceNumberChanged,
          decoration: _decoration(colors),
        ),
        const SizedBox(height: AppSpacing.md),
        Text('newSale.paymentStep.notesLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _notesController,
          minLines: 2,
          maxLines: 4,
          style: AppTextStyles.cardTitle(colors.textPrimary),
          onChanged: cubit.notesChanged,
          decoration: _decoration(colors),
        ),
      ],
    );
  }

  InputDecoration _decoration(AppColors colors) {
    return InputDecoration(
      filled: true,
      fillColor: colors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.button), borderSide: BorderSide(color: colors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.button), borderSide: BorderSide(color: colors.border)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.button),
        borderSide: BorderSide(color: colors.primaryAction, width: 1.5),
      ),
    );
  }
}

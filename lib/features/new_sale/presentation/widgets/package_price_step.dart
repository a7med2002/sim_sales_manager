import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/package_display.dart';
import '../../../../core/widgets/date_field.dart';
import '../cubit/new_sale_cubit.dart';
import '../cubit/new_sale_state.dart';

/// Step 2: pick supplier company -> package/bundle, adjust cost/price,
/// SIM number, and purchase/expiry dates. Profit shown live.
class PackagePriceStep extends StatefulWidget {
  final NewSaleState state;

  const PackagePriceStep({super.key, required this.state});

  @override
  State<PackagePriceStep> createState() => _PackagePriceStepState();
}

class _PackagePriceStepState extends State<PackagePriceStep> {
  late TextEditingController _simController;
  late TextEditingController _wholesaleController;
  late TextEditingController _retailController;

  @override
  void initState() {
    super.initState();
    _simController = TextEditingController(text: widget.state.simNumber);
    _wholesaleController = TextEditingController(text: _fmt(widget.state.wholesaleCost));
    _retailController = TextEditingController(text: _fmt(widget.state.retailPrice));
  }

  @override
  void didUpdateWidget(covariant PackagePriceStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Package selection auto-fills cost/price — resync only when it
    // changed externally (not from this widget's own onChanged).
    if (oldWidget.state.selectedPackageId != widget.state.selectedPackageId) {
      _wholesaleController.text = _fmt(widget.state.wholesaleCost);
      _retailController.text = _fmt(widget.state.retailPrice);
    }
  }

  String _fmt(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  @override
  void dispose() {
    _simController.dispose();
    _wholesaleController.dispose();
    _retailController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isExpiry}) async {
    final cubit = context.read<NewSaleCubit>();
    final initial = isExpiry ? widget.state.expiryDate : widget.state.purchaseDate;
    final picked = await showDatePicker(context: context, initialDate: initial, firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (picked == null) return;
    if (isExpiry) {
      cubit.expiryDateChanged(picked);
    } else {
      cubit.purchaseDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cubit = context.read<NewSaleCubit>();
    final state = widget.state;
    final selectedCompany = state.selectedCompany;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('newSale.packagePriceStep.companyLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
        const SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<String>(
          initialValue: state.selectedCompanyId,
          isExpanded: true,
          hint: Text('newSale.packagePriceStep.companyLabel'.tr(), style: AppTextStyles.cardTitle(colors.textSecondary)),
          style: AppTextStyles.cardTitle(colors.textPrimary),
          dropdownColor: colors.surface,
          decoration: _decoration(colors),
          items: state.companies
              .map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Text('${c.name} — ${formatCurrency(c.availableToSell)}', overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) cubit.selectCompany(value);
          },
        ),
        if (selectedCompany != null) ...[
          const SizedBox(height: 4),
          Text(
            'newSale.packagePriceStep.availableBalance'.tr(namedArgs: {'amount': formatCurrency(selectedCompany.availableToSell)}),
            style: AppTextStyles.body(colors.textSecondary),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Text('newSale.packagePriceStep.packageLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
        const SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<String>(
          initialValue: state.selectedPackageId,
          hint: Text('newSale.packagePriceStep.packageLabel'.tr(), style: AppTextStyles.cardTitle(colors.textSecondary)),
          style: AppTextStyles.cardTitle(colors.textPrimary),
          dropdownColor: colors.surface,
          decoration: _decoration(colors),
          items: (selectedCompany?.packages ?? [])
              .map((p) => DropdownMenuItem(value: p.id, child: Text(packageDisplayLabel(p.name, p.simType), overflow: TextOverflow.ellipsis)))
              .toList(),
          onChanged: selectedCompany == null
              ? null
              : (value) {
                  if (value != null) cubit.selectPackage(value);
                },
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('newSale.packagePriceStep.wholesaleCostLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
                  const SizedBox(height: AppSpacing.xs),
                  TextField(
                    controller: _wholesaleController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: AppTextStyles.cardTitle(colors.textPrimary),
                    onChanged: (v) => cubit.wholesaleCostChanged(double.tryParse(v) ?? 0),
                    decoration: _decoration(colors),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('newSale.packagePriceStep.retailSalePriceLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
                  const SizedBox(height: AppSpacing.xs),
                  TextField(
                    controller: _retailController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: AppTextStyles.cardTitle(colors.textPrimary),
                    onChanged: (v) => cubit.retailPriceChanged(double.tryParse(v) ?? 0),
                    decoration: _decoration(colors),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (state.exceedsCompanyBalance) ...[
          const SizedBox(height: 4),
          Text(
            'newSale.packagePriceStep.insufficientBalance'.tr(),
            style: AppTextStyles.body(colors.danger),
          ),
        ] else if (state.willDipCompanyBalanceNegative) ...[
          const SizedBox(height: 4),
          Text(
            'newSale.packagePriceStep.willGoNegative'.tr(),
            style: AppTextStyles.body(colors.warning),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
          decoration: BoxDecoration(color: colors.background, borderRadius: BorderRadius.circular(AppRadii.button)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('newSale.packagePriceStep.profitLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
              Text(formatCurrency(state.profit), style: AppTextStyles.cardTitle(colors.textPrimary)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text('newSale.packagePriceStep.simLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _simController,
          keyboardType: TextInputType.phone,
          style: AppTextStyles.cardTitle(colors.textPrimary),
          onChanged: cubit.simNumberChanged,
          decoration: _decoration(colors),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(child: DateField(label: 'newSale.packagePriceStep.purchaseDateLabel'.tr(), date: state.purchaseDate, onTap: () => _pickDate(isExpiry: false))),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: DateField(label: 'newSale.packagePriceStep.expiryDateLabel'.tr(), date: state.expiryDate, onTap: () => _pickDate(isExpiry: true))),
          ],
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

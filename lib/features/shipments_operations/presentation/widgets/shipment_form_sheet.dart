import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/catalog/company_summary.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/date_field.dart';
import '../../domain/entities/shipment.dart';

typedef ShipmentSaveCallback = void Function(
  CompanySummary company,
  ShipmentType type,
  double totalAmount,
  double amountPaid,
  String paymentMethod,
  DateTime date,
  String referenceNumber,
  String notes,
);

/// "+ New Shipment" form. Per APP_CONTEXT.md's Shipments spec: company
/// dropdown, Prepaid/Credit Limit type cards, total/paid with an
/// auto-calculated remaining box, payment method, date, optional
/// reference number and notes.
class ShipmentFormSheet extends StatefulWidget {
  final List<CompanySummary> companies;
  final ShipmentSaveCallback onSave;

  const ShipmentFormSheet({super.key, required this.companies, required this.onSave});

  static Future<void> show(BuildContext context, {required List<CompanySummary> companies, required ShipmentSaveCallback onSave}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ShipmentFormSheet(companies: companies, onSave: onSave),
    );
  }

  @override
  State<ShipmentFormSheet> createState() => _ShipmentFormSheetState();
}

class _ShipmentFormSheetState extends State<ShipmentFormSheet> {
  CompanySummary? _selectedCompany;
  ShipmentType _type = ShipmentType.prepaid;
  final _totalController = TextEditingController();
  final _paidController = TextEditingController();
  final _paymentMethodController = TextEditingController(text: 'Cash');
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    for (final c in [_totalController, _paidController, _paymentMethodController]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _totalController.dispose();
    _paidController.dispose();
    _paymentMethodController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _total => double.tryParse(_totalController.text.trim()) ?? 0;
  double get _paid => double.tryParse(_paidController.text.trim()) ?? 0;
  double get _remaining => (_total - _paid).clamp(0, double.infinity).toDouble();

  bool get _canSave => _selectedCompany != null && _total > 0 && _paymentMethodController.text.trim().isNotEmpty;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    if (!_canSave) return;
    widget.onSave(
      _selectedCompany!,
      _type,
      _total,
      _paid,
      _paymentMethodController.text.trim(),
      _date,
      _referenceController.text.trim(),
      _notesController.text.trim(),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.card)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('shipmentsOperations.form.title'.tr(), style: AppTextStyles.sectionHeader(colors.textPrimary)),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(Icons.close_rounded, color: colors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('shipmentsOperations.form.companyLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
              const SizedBox(height: AppSpacing.xs),
              DropdownButtonFormField<CompanySummary>(
                initialValue: _selectedCompany,
                hint: Text('shipmentsOperations.form.selectCompanyHint'.tr(), style: AppTextStyles.cardTitle(colors.textSecondary)),
                style: AppTextStyles.cardTitle(colors.textPrimary),
                dropdownColor: colors.surface,
                decoration: _decoration(colors),
                items: widget.companies.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                onChanged: (value) => setState(() => _selectedCompany = value),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('shipmentsOperations.form.typeLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Expanded(
                    child: _TypeCard(
                      label: ShipmentType.prepaid.label,
                      description: 'shipmentsOperations.form.prepaidDescription'.tr(),
                      isSelected: _type == ShipmentType.prepaid,
                      onTap: () => setState(() => _type = ShipmentType.prepaid),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _TypeCard(
                      label: ShipmentType.creditLimit.label,
                      description: 'shipmentsOperations.form.creditLimitDescription'.tr(),
                      isSelected: _type == ShipmentType.creditLimit,
                      onTap: () => setState(() => _type = ShipmentType.creditLimit),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('shipmentsOperations.form.totalAmountLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
                        const SizedBox(height: AppSpacing.xs),
                        TextField(
                          controller: _totalController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: AppTextStyles.cardTitle(colors.textPrimary),
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
                        Text('shipmentsOperations.form.amountPaidLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
                        const SizedBox(height: AppSpacing.xs),
                        TextField(
                          controller: _paidController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: AppTextStyles.cardTitle(colors.textPrimary),
                          decoration: _decoration(colors),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
                decoration: BoxDecoration(color: colors.background, borderRadius: BorderRadius.circular(AppRadii.button)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('shipmentsOperations.form.remainingLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
                    Text(
                      formatCurrency(_remaining),
                      style: AppTextStyles.cardTitle(_remaining > 0 ? colors.danger : colors.textPrimary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('shipmentsOperations.form.paymentMethodLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _paymentMethodController,
                style: AppTextStyles.cardTitle(colors.textPrimary),
                decoration: _decoration(colors, hint: 'shipmentsOperations.form.paymentMethodHint'.tr()),
              ),
              const SizedBox(height: AppSpacing.md),
              DateField(label: 'shipmentsOperations.form.shipmentDateLabel'.tr(), date: _date, onTap: _pickDate),
              const SizedBox(height: AppSpacing.md),
              Text('shipmentsOperations.form.referenceNumberLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
              const SizedBox(height: AppSpacing.xs),
              TextField(controller: _referenceController, style: AppTextStyles.cardTitle(colors.textPrimary), decoration: _decoration(colors)),
              const SizedBox(height: AppSpacing.md),
              Text('shipmentsOperations.form.notesLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _notesController,
                minLines: 2,
                maxLines: 4,
                style: AppTextStyles.cardTitle(colors.textPrimary),
                decoration: _decoration(colors),
              ),
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
                  child: Text('shipmentsOperations.form.save'.tr(), style: AppTextStyles.cardTitle(colors.onPrimaryAction)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(AppColors colors, {String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.cardTitle(colors.textSecondary),
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

class _TypeCard extends StatelessWidget {
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeCard({required this.label, required this.description, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? colors.primaryAction : colors.surface,
          borderRadius: BorderRadius.circular(AppRadii.button),
          border: Border.all(color: isSelected ? colors.primaryAction : colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.cardTitle(isSelected ? colors.onPrimaryAction : colors.textPrimary)),
            const SizedBox(height: 2),
            Text(
              description,
              style: AppTextStyles.body(isSelected ? colors.onPrimaryAction.withValues(alpha: 0.8) : colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

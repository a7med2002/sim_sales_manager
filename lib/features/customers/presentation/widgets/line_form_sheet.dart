import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/date_field.dart';
import '../../data/customers_mock_data.dart';
import '../../domain/entities/line.dart';

typedef LineSaveCallback = void Function(
  String simNumber,
  String companyName,
  String companyInitials,
  String packageName,
  DateTime purchaseDate,
  DateTime expiryDate,
  double wholesaleCost,
  double retailPrice,
  PaymentStatus paymentStatus,
  double amountPaid,
  double amountRemaining,
);

/// Add/Edit Line sheet — a scoped-down stand-in for the full "New Sale"
/// flow (company -> package -> price -> payment) from APP_CONTEXT.md,
/// reachable here as "+ Add Line" with the customer pre-selected. Company
/// is a free-text field with quick-pick chips rather than importing the
/// Companies feature's entities (no cross-feature imports allowed).
class LineFormSheet extends StatefulWidget {
  final Line? line;
  final LineSaveCallback onSave;

  const LineFormSheet({super.key, this.line, required this.onSave});

  static Future<void> show(BuildContext context, {Line? line, required LineSaveCallback onSave}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LineFormSheet(line: line, onSave: onSave),
    );
  }

  @override
  State<LineFormSheet> createState() => _LineFormSheetState();
}

class _LineFormSheetState extends State<LineFormSheet> {
  late final TextEditingController _companyController;
  late final TextEditingController _packageController;
  late final TextEditingController _simController;
  late final TextEditingController _wholesaleController;
  late final TextEditingController _retailController;
  late final TextEditingController _paidController;
  late DateTime _purchaseDate;
  late DateTime _expiryDate;

  bool get _isEditing => widget.line != null;

  @override
  void initState() {
    super.initState();
    final line = widget.line;
    _companyController = TextEditingController(text: line?.companyName ?? '');
    _packageController = TextEditingController(text: line?.packageName ?? '');
    _simController = TextEditingController(text: line?.simNumber ?? '');
    _wholesaleController = TextEditingController(text: _formatNum(line?.wholesaleCost));
    _retailController = TextEditingController(text: _formatNum(line?.retailPrice));
    _paidController = TextEditingController(text: _formatNum(line?.amountPaid));
    _purchaseDate = line?.purchaseDate ?? DateTime.now();
    _expiryDate = line?.expiryDate ?? DateTime.now().add(const Duration(days: 30));

    for (final c in [_companyController, _packageController, _simController, _wholesaleController, _retailController, _paidController]) {
      c.addListener(() => setState(() {}));
    }
  }

  String _formatNum(double? value) {
    if (value == null) return '';
    return value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString();
  }

  @override
  void dispose() {
    _companyController.dispose();
    _packageController.dispose();
    _simController.dispose();
    _wholesaleController.dispose();
    _retailController.dispose();
    _paidController.dispose();
    super.dispose();
  }

  double get _wholesale => double.tryParse(_wholesaleController.text.trim()) ?? 0;
  double get _retail => double.tryParse(_retailController.text.trim()) ?? 0;
  double get _paid => double.tryParse(_paidController.text.trim()) ?? 0;
  double get _profit => _retail - _wholesale;
  double get _remaining => (_retail - _paid).clamp(0, double.infinity);

  PaymentStatus get _paymentStatus {
    if (_paid <= 0) return PaymentStatus.unpaid;
    if (_paid >= _retail) return PaymentStatus.paid;
    return PaymentStatus.partial;
  }

  String _initialsFor(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return (words.first.substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
  }

  Future<void> _pickDate({required bool isExpiry}) async {
    final initial = isExpiry ? _expiryDate : _purchaseDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isExpiry) {
        _expiryDate = picked;
      } else {
        _purchaseDate = picked;
      }
    });
  }

  bool get _canSave =>
      _companyController.text.trim().isNotEmpty &&
      _packageController.text.trim().isNotEmpty &&
      _simController.text.trim().isNotEmpty &&
      _retail > 0;

  void _save() {
    if (!_canSave) return;
    final companyName = _companyController.text.trim();
    widget.onSave(
      _simController.text.trim(),
      companyName,
      _initialsFor(companyName),
      _packageController.text.trim(),
      _purchaseDate,
      _expiryDate,
      _wholesale,
      _retail,
      _paymentStatus,
      _paid,
      _remaining,
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
                  Text(_isEditing ? 'customers.lineForm.editTitle'.tr() : 'customers.lineForm.addTitle'.tr(), style: AppTextStyles.sectionHeader(colors.textPrimary)),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(Icons.close_rounded, color: colors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('customers.lineForm.companyLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
              const SizedBox(height: AppSpacing.xs),
              TextField(controller: _companyController, style: AppTextStyles.cardTitle(colors.textPrimary), decoration: _decoration(colors)),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: CustomersMockData.commonCompanyNames
                    .map((name) => GestureDetector(
                          onTap: () => _companyController.text = name,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              border: Border.all(color: colors.border),
                              borderRadius: BorderRadius.circular(AppRadii.pill),
                            ),
                            child: Text(name, style: AppTextStyles.badge(colors.textPrimary)),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('customers.lineForm.packageLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _packageController,
                style: AppTextStyles.cardTitle(colors.textPrimary),
                decoration: _decoration(colors, hint: 'customers.lineForm.packageHint'.tr()),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('customers.lineForm.simLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _simController,
                keyboardType: TextInputType.phone,
                style: AppTextStyles.cardTitle(colors.textPrimary),
                decoration: _decoration(colors, hint: '0599123456'),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(child: DateField(label: 'customers.line.purchaseDate'.tr(), date: _purchaseDate, onTap: () => _pickDate(isExpiry: false))),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: DateField(label: 'customers.line.expiryDate'.tr(), date: _expiryDate, onTap: () => _pickDate(isExpiry: true))),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('customers.lineForm.wholesaleCostLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
                        const SizedBox(height: AppSpacing.xs),
                        TextField(
                          controller: _wholesaleController,
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
                        Text('customers.lineForm.retailSalePriceLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
                        const SizedBox(height: AppSpacing.xs),
                        TextField(
                          controller: _retailController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: AppTextStyles.cardTitle(colors.textPrimary),
                          decoration: _decoration(colors),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('customers.lineForm.profitLine'.tr(namedArgs: {'amount': formatCurrency(_profit)}), style: AppTextStyles.body(colors.success)),
              const SizedBox(height: AppSpacing.md),
              Text('customers.lineForm.amountPaidNow'.tr(), style: AppTextStyles.body(colors.textSecondary)),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _paidController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: AppTextStyles.cardTitle(colors.textPrimary),
                decoration: _decoration(colors),
              ),
              const SizedBox(height: 4),
              Text(
                'customers.lineForm.remainingLine'.tr(namedArgs: {'amount': formatCurrency(_remaining), 'status': _paymentStatus.label}),
                style: AppTextStyles.body(_remaining > 0 ? colors.danger : colors.success),
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
                  child: Text('customers.lineForm.save'.tr(), style: AppTextStyles.cardTitle(colors.onPrimaryAction)),
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

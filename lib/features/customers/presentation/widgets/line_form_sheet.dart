import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/catalog/company_summary.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/package_display.dart';
import '../../../../core/widgets/date_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/line.dart';

typedef LineSaveCallback = void Function(
  String simNumber,
  String companyId,
  String companyName,
  String companyInitials,
  String? packageId,
  String packageName,
  String? packageSimType,
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
/// and package are picked from [companies] — this seller's own real
/// companies (same `CompanyCatalog.activeCompanies` New Sale reads) —
/// rather than free-typed, so the Line this creates has a real
/// `companyId`/`packageId` and can persist for real (see
/// `CustomersCubit.addLine`). If [companies] is empty there's nothing
/// to pick, so the sheet shows an explanatory empty state instead of a
/// form — a seller has to add at least one company first.
class LineFormSheet extends StatefulWidget {
  final Line? line;
  final List<CompanySummary> companies;
  final LineSaveCallback onSave;

  const LineFormSheet({super.key, this.line, required this.companies, required this.onSave});

  static Future<void> show(
    BuildContext context, {
    Line? line,
    required List<CompanySummary> companies,
    required LineSaveCallback onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LineFormSheet(line: line, companies: companies, onSave: onSave),
    );
  }

  @override
  State<LineFormSheet> createState() => _LineFormSheetState();
}

class _LineFormSheetState extends State<LineFormSheet> {
  late final TextEditingController _simController;
  late final TextEditingController _wholesaleController;
  late final TextEditingController _retailController;
  late final TextEditingController _paidController;
  late DateTime _purchaseDate;
  late DateTime _expiryDate;
  String? _selectedCompanyId;
  String? _selectedPackageId;

  bool get _isEditing => widget.line != null;

  CompanySummary? get _selectedCompany {
    final id = _selectedCompanyId;
    if (id == null) return null;
    final matches = widget.companies.where((c) => c.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  @override
  void initState() {
    super.initState();
    final line = widget.line;
    _simController = TextEditingController(text: line?.simNumber ?? '');
    _wholesaleController = TextEditingController(text: _formatNum(line?.wholesaleCost));
    _retailController = TextEditingController(text: _formatNum(line?.retailPrice));
    _paidController = TextEditingController(text: _formatNum(line?.amountPaid));
    _purchaseDate = line?.purchaseDate ?? DateTime.now();
    _expiryDate = line?.expiryDate ?? DateTime.now().add(const Duration(days: 30));

    // Prefill from the existing line's ids when editing, only if that
    // company still exists in the current list (it always should, but
    // don't crash the sheet if a company was deleted meanwhile).
    if (line != null && widget.companies.any((c) => c.id == line.companyId)) {
      _selectedCompanyId = line.companyId;
      _selectedPackageId = line.packageId;
    }

    for (final c in [_simController, _wholesaleController, _retailController, _paidController]) {
      c.addListener(() => setState(() {}));
    }
  }

  String _formatNum(double? value) {
    if (value == null) return '';
    return value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString();
  }

  @override
  void dispose() {
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

  void _selectCompany(String? companyId) {
    setState(() {
      _selectedCompanyId = companyId;
      _selectedPackageId = null;
      _wholesaleController.clear();
      _retailController.clear();
    });
  }

  void _selectPackage(String? packageId) {
    setState(() {
      _selectedPackageId = packageId;
      final company = _selectedCompany;
      if (company == null || packageId == null) return;
      final matches = company.packages.where((p) => p.id == packageId);
      if (matches.isEmpty) return;
      final package = matches.first;
      _wholesaleController.text = _formatNum(package.wholesaleCost);
      // Deliberately not pre-filled from the package — a package no
      // longer carries its own retail price (see CompanyPackage's doc
      // comment), so the seller always types it fresh per sale.
      _retailController.clear();
    });
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

  /// Selling a line consumes from the company's shipment balance at
  /// wholesale price (design/APP_CONTEXT.md). Only checked when adding a
  /// new line, not editing one — an existing line's own wholesale cost
  /// was already deducted when it was first created, so re-checking it
  /// against the current balance here (without adding it back first)
  /// would incorrectly block a same-price edit.
  bool get _exceedsBalance {
    if (_isEditing) return false;
    final company = _selectedCompany;
    if (company == null) return false;
    if (_wholesale <= company.availableToSell) return false;
    // See NewSaleState.exceedsCompanyBalance's doc comment — same
    // negative-balance-allowance rule applies here too, since this is
    // just another way of recording a sale.
    if (company.allowNegativeBalance && company.availableToSell > 0) return false;
    return true;
  }

  /// Mirrors `NewSaleState.willDipCompanyBalanceNegative` — a heads-up,
  /// not a block, shown only when `_exceedsBalance` is false.
  bool get _willDipNegative {
    if (_isEditing) return false;
    final company = _selectedCompany;
    if (company == null || !company.allowNegativeBalance) return false;
    return _wholesale > company.availableToSell && company.availableToSell > 0;
  }

  bool get _canSave =>
      _selectedCompany != null && _simController.text.trim().isNotEmpty && _retail > 0 && !_exceedsBalance;

  void _save() {
    final company = _selectedCompany;
    if (!_canSave || company == null) return;
    final matchingPackages = company.packages.where((p) => p.id == _selectedPackageId);
    final packageName = matchingPackages.isEmpty ? '' : matchingPackages.first.name;
    final packageSimType = matchingPackages.isEmpty ? null : matchingPackages.first.simType;
    widget.onSave(
      _simController.text.trim(),
      company.id,
      company.name,
      company.initials,
      _selectedPackageId,
      packageName,
      packageSimType,
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
              if (widget.companies.isEmpty)
                EmptyState(
                  icon: Icons.apartment_rounded,
                  title: 'customers.lineForm.noCompaniesTitle'.tr(),
                  description: 'customers.lineForm.noCompaniesDescription'.tr(),
                )
              else ...[
                Text('customers.lineForm.companyLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
                const SizedBox(height: AppSpacing.xs),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCompanyId,
                  isExpanded: true,
                  style: AppTextStyles.cardTitle(colors.textPrimary),
                  decoration: _decoration(colors, hint: 'customers.lineForm.companyHint'.tr()),
                  items: widget.companies
                      .map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(
                              '${c.name} — ${formatCurrency(c.availableToSell)}',
                              style: AppTextStyles.cardTitle(colors.textPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                  onChanged: _selectCompany,
                ),
                if (!_isEditing && _selectedCompany != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'customers.lineForm.availableBalance'.tr(namedArgs: {'amount': formatCurrency(_selectedCompany!.availableToSell)}),
                    style: AppTextStyles.body(colors.textSecondary),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                Text('customers.lineForm.packageLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
                const SizedBox(height: AppSpacing.xs),
                DropdownButtonFormField<String>(
                  initialValue: _selectedPackageId,
                  style: AppTextStyles.cardTitle(colors.textPrimary),
                  decoration: _decoration(colors, hint: 'customers.lineForm.packageHint'.tr()),
                  items: (_selectedCompany?.packages ?? const [])
                      .map((p) => DropdownMenuItem(
                            value: p.id,
                            child: Text(packageDisplayLabel(p.name, p.simType), style: AppTextStyles.cardTitle(colors.textPrimary), overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: _selectedCompany == null ? null : _selectPackage,
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
                if (_exceedsBalance) ...[
                  const SizedBox(height: 4),
                  Text('customers.lineForm.insufficientBalance'.tr(), style: AppTextStyles.body(colors.danger)),
                ] else if (_willDipNegative) ...[
                  const SizedBox(height: 4),
                  Text('customers.lineForm.willGoNegative'.tr(), style: AppTextStyles.body(colors.warning)),
                ],
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

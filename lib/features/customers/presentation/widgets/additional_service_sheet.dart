import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/catalog/company_summary.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/package_display.dart';
import '../../domain/entities/additional_service.dart';
import '../../domain/entities/line.dart';

/// "Additional Service" — a data top-up when a line's GB runs out before
/// month's end. Deducts a seller-chosen amount from the supplying
/// company's balance and, optionally, adds a seller-chosen amount to the
/// customer's debt — deliberately never touches the line's own
/// `retailPrice`. See `additional_services_table.dart`'s doc comment for
/// why this is tracked separately from the line itself.
///
/// Doubles as the *edit* form when [existing] is non-null — same shell,
/// pre-filled fields, and the balance-exceeded check accounts for the
/// existing row's own deduction already being reflected in
/// [company]'s current balance (see [_effectiveAvailable]'s doc comment).
class AdditionalServiceSheet extends StatefulWidget {
  final Line line;
  final CompanySummary? company;
  final AdditionalService? existing;
  final void Function(double gbAdded, double amountDeducted, double amountCharged) onSave;

  const AdditionalServiceSheet({super.key, required this.line, required this.company, this.existing, required this.onSave});

  static Future<void> show(
    BuildContext context, {
    required Line line,
    required CompanySummary? company,
    AdditionalService? existing,
    required void Function(double gbAdded, double amountDeducted, double amountCharged) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AdditionalServiceSheet(line: line, company: company, existing: existing, onSave: onSave),
    );
  }

  @override
  State<AdditionalServiceSheet> createState() => _AdditionalServiceSheetState();
}

class _AdditionalServiceSheetState extends State<AdditionalServiceSheet> {
  late final TextEditingController _gbController;
  late final TextEditingController _deductController;
  late final TextEditingController _chargeController;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _gbController = TextEditingController(text: existing != null ? _trimZeros(existing.gbAdded) : '30');
    _deductController = TextEditingController(text: existing != null ? _trimZeros(existing.amountDeducted) : '');
    _chargeController = TextEditingController(text: existing != null && existing.amountCharged > 0 ? _trimZeros(existing.amountCharged) : '');
  }

  String _trimZeros(double value) => value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString();

  @override
  void dispose() {
    _gbController.dispose();
    _deductController.dispose();
    _chargeController.dispose();
    super.dispose();
  }

  double get _gb => double.tryParse(_gbController.text.trim()) ?? 0;
  double get _deduct => double.tryParse(_deductController.text.trim()) ?? 0;
  double get _charge => double.tryParse(_chargeController.text.trim()) ?? 0;

  /// The company's balance as if this row's *own* current deduction had
  /// never happened — when editing, [company]'s live balance already has
  /// the old `amountDeducted` taken out, so validating the new amount
  /// straight against it would incorrectly block "no real change"/
  /// smaller edits. Equal to `company.availableToSell` (no adjustment)
  /// when adding a brand new one.
  double get _effectiveAvailable => (widget.company?.availableToSell ?? 0) + (widget.existing?.amountDeducted ?? 0);

  /// Same rule `line_form_sheet.dart`'s `_exceedsBalance` enforces for a
  /// new sale — blocked unless the company opted into "allow negative
  /// balance" (and even then, only while its balance is still above 0).
  bool get _exceedsBalance {
    final company = widget.company;
    if (company == null) return false;
    if (_deduct <= _effectiveAvailable) return false;
    if (company.allowNegativeBalance && _effectiveAvailable > 0) return false;
    return true;
  }

  bool get _willDipNegative {
    final company = widget.company;
    if (company == null || !company.allowNegativeBalance) return false;
    return _deduct > _effectiveAvailable && _effectiveAvailable > 0;
  }

  bool get _canSave => widget.company != null && _gb > 0 && _deduct > 0 && !_exceedsBalance;

  void _save() {
    if (!_canSave) return;
    widget.onSave(_gb, _deduct, _charge);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final line = widget.line;
    final company = widget.company;

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
                  Text(
                    (_isEditing ? 'customers.line.additionalService.editTitle' : 'customers.line.additionalService.sheetTitle').tr(),
                    style: AppTextStyles.sectionHeader(colors.textPrimary),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(Icons.close_rounded, color: colors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('${packageDisplayLabel(line.packageName, line.packageSimType)} · ${line.simNumber}', style: AppTextStyles.body(colors.textSecondary)),
              if (!_isEditing) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(color: colors.background, borderRadius: BorderRadius.circular(AppRadii.button)),
                  child: Text('customers.line.additionalService.explanation'.tr(), style: AppTextStyles.body(colors.textSecondary)),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              if (company == null)
                Text('customers.line.additionalService.noCompany'.tr(), style: AppTextStyles.body(colors.danger))
              else ...[
                Text('customers.line.additionalService.gbLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
                const SizedBox(height: AppSpacing.xs),
                _numberField(context, _gbController),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
                  decoration: BoxDecoration(color: colors.background, borderRadius: BorderRadius.circular(AppRadii.button)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('customers.line.additionalService.availableBalanceLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
                      Text(formatCurrency(_effectiveAvailable), style: AppTextStyles.cardTitle(colors.textPrimary)),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('customers.line.additionalService.deductLabel'.tr(namedArgs: {'company': company.name}), style: AppTextStyles.body(colors.textSecondary)),
                const SizedBox(height: AppSpacing.xs),
                _numberField(context, _deductController),
                if (_exceedsBalance) ...[
                  const SizedBox(height: 4),
                  Text('customers.line.additionalService.exceedsBalance'.tr(), style: AppTextStyles.body(colors.danger)),
                ] else if (_willDipNegative) ...[
                  const SizedBox(height: 4),
                  Text('customers.line.additionalService.willDipNegative'.tr(), style: AppTextStyles.body(colors.warning)),
                ],
                const SizedBox(height: AppSpacing.md),
                Text('customers.line.additionalService.chargeLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
                const SizedBox(height: AppSpacing.xs),
                _numberField(context, _chargeController, hintText: 'customers.line.additionalService.chargeHint'.tr()),
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
                    child: Text(
                      (_isEditing ? 'customers.line.additionalService.editSubmit' : 'customers.line.additionalService.submit').tr(),
                      style: AppTextStyles.cardTitle(colors.onPrimaryAction),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _numberField(BuildContext context, TextEditingController controller, {String? hintText}) {
    final colors = context.colors;
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: AppTextStyles.cardTitle(colors.textPrimary),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.hint(colors.textSecondary),
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.button), borderSide: BorderSide(color: colors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.button), borderSide: BorderSide(color: colors.border)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.button),
          borderSide: BorderSide(color: colors.primaryAction, width: 1.5),
        ),
      ),
    );
  }
}

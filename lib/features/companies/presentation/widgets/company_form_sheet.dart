import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/number_update/number_update_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/company.dart';
import '../../domain/entities/company_package.dart';

typedef CompanySaveCallback = void Function(
  String name,
  String notes,
  List<CompanyPackage> packages,
  NumberUpdateProviderKey? numberUpdateProvider,
);

/// Add/Edit Company bottom sheet. Pass [company] to prefill for editing —
/// omit it to add a new company. Every field — name, notes, packages,
/// Number Update provider — is freely editable: a seller owns their
/// companies completely, whether typed from scratch or started from
/// "Import Ready-Made" (see `CompaniesCubit`'s doc comment). The Number
/// Update provider is optional and only meaningful for a handful of
/// known suppliers (see `features/number_update/`); leave it unset for
/// any company Number Update has nothing automated for.
class CompanyFormSheet extends StatefulWidget {
  final Company? company;
  final CompanySaveCallback onSave;

  const CompanyFormSheet({super.key, this.company, required this.onSave});

  static Future<void> show(BuildContext context, {Company? company, required CompanySaveCallback onSave}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CompanyFormSheet(company: company, onSave: onSave),
    );
  }

  @override
  State<CompanyFormSheet> createState() => _CompanyFormSheetState();
}

class _PackageRow {
  final String id;
  final TextEditingController nameController;
  final TextEditingController costController;
  final TextEditingController priceController;

  _PackageRow({String? id, String name = '', String cost = '', String price = ''})
      : id = id ?? UniqueKey().toString(),
        nameController = TextEditingController(text: name),
        costController = TextEditingController(text: cost),
        priceController = TextEditingController(text: price);
}

class _CompanyFormSheetState extends State<CompanyFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _notesController;
  late final List<_PackageRow> _packageRows;
  NumberUpdateProviderKey? _numberUpdateProvider;

  bool get _isEditing => widget.company != null;

  @override
  void initState() {
    super.initState();
    final company = widget.company;
    _nameController = TextEditingController(text: company?.name ?? '');
    _notesController = TextEditingController(text: company?.notes ?? '');
    _numberUpdateProvider = company?.numberUpdateProvider;
    _packageRows = company?.packages
            .map((p) => _PackageRow(
                  id: p.id,
                  name: p.name,
                  cost: p.wholesaleCost == p.wholesaleCost.roundToDouble() ? p.wholesaleCost.toStringAsFixed(0) : p.wholesaleCost.toString(),
                  price: p.retailPrice == p.retailPrice.roundToDouble() ? p.retailPrice.toStringAsFixed(0) : p.retailPrice.toString(),
                ))
            .toList() ??
        [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    for (final row in _packageRows) {
      row.nameController.dispose();
      row.costController.dispose();
      row.priceController.dispose();
    }
    super.dispose();
  }

  void _addPackageRow() {
    setState(() => _packageRows.add(_PackageRow()));
  }

  void _removePackageRow(_PackageRow row) {
    setState(() => _packageRows.remove(row));
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final packages = _packageRows
        .where((row) => row.nameController.text.trim().isNotEmpty)
        .map((row) => CompanyPackage(
              id: row.id,
              name: row.nameController.text.trim(),
              wholesaleCost: double.tryParse(row.costController.text.trim()) ?? 0,
              retailPrice: double.tryParse(row.priceController.text.trim()) ?? 0,
            ))
        .toList();

    widget.onSave(name, _notesController.text.trim(), packages, _numberUpdateProvider);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final canSave = _nameController.text.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
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
                  Text(_isEditing ? 'companies.form.editTitle'.tr() : 'companies.form.addTitle'.tr(), style: AppTextStyles.sectionHeader(colors.textPrimary)),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(Icons.close_rounded, color: colors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _isEditing ? 'companies.form.editSubtitle'.tr() : 'companies.form.addSubtitle'.tr(),
                style: AppTextStyles.body(colors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('companies.form.nameLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _nameController,
                style: AppTextStyles.cardTitle(colors.textPrimary),
                onChanged: (_) => setState(() {}),
                decoration: _inputDecoration(colors),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('companies.form.notesLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _notesController,
                style: AppTextStyles.cardTitle(colors.textPrimary),
                minLines: 3,
                maxLines: 5,
                decoration: _inputDecoration(colors),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('companies.form.numberUpdateProviderLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
              const SizedBox(height: AppSpacing.xs),
              DropdownButtonFormField<NumberUpdateProviderKey?>(
                initialValue: _numberUpdateProvider,
                isExpanded: true,
                style: AppTextStyles.cardTitle(colors.textPrimary),
                decoration: _inputDecoration(colors),
                items: [
                  DropdownMenuItem(value: null, child: Text('numberUpdateProvider.none'.tr(), overflow: TextOverflow.ellipsis)),
                  ...NumberUpdateProviderKey.values.map(
                    (key) => DropdownMenuItem(value: key, child: Text(key.label, overflow: TextOverflow.ellipsis)),
                  ),
                ],
                onChanged: (value) => setState(() => _numberUpdateProvider = value),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('companies.form.packagesSection'.tr(), style: AppTextStyles.overline(colors.textSecondary)),
              const SizedBox(height: AppSpacing.sm),
              ..._packageRows.map((row) => _PackageRowFields(
                    key: ValueKey(row.id),
                    row: row,
                    onRemove: () => _removePackageRow(row),
                  )),
              OutlinedButton.icon(
                onPressed: _addPackageRow,
                icon: Icon(Icons.add_rounded, color: colors.textPrimary, size: 18),
                label: Text('companies.form.addPackage'.tr(), style: AppTextStyles.body(colors.textPrimary)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.textPrimary,
                  side: BorderSide(color: colors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: canSave ? _save : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primaryAction,
                    foregroundColor: colors.onPrimaryAction,
                    disabledBackgroundColor: colors.primaryAction.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button)),
                    elevation: 0,
                  ),
                  child: Text('companies.form.save'.tr(), style: AppTextStyles.cardTitle(colors.onPrimaryAction)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(AppColors colors) {
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

class _PackageRowFields extends StatelessWidget {
  final _PackageRow row;
  final VoidCallback onRemove;

  const _PackageRowFields({super.key, required this.row, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final decoration = InputDecoration(
      filled: true,
      fillColor: colors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.button), borderSide: BorderSide(color: colors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.button), borderSide: BorderSide(color: colors.border)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.button),
        borderSide: BorderSide(color: colors.primaryAction, width: 1.5),
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border.all(color: colors.border, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(AppRadii.button),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: row.nameController,
                  style: AppTextStyles.body(colors.textPrimary),
                  decoration: decoration.copyWith(hintText: 'companies.form.packageNamePlaceholder'.tr()),
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: Icon(Icons.close_rounded, size: 18, color: colors.textSecondary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: row.costController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: AppTextStyles.body(colors.textPrimary),
                  decoration: decoration.copyWith(hintText: 'companies.form.wholesaleCostPlaceholder'.tr()),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: TextField(
                  controller: row.priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: AppTextStyles.body(colors.textPrimary),
                  decoration: decoration.copyWith(hintText: 'companies.form.retailPricePlaceholder'.tr()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

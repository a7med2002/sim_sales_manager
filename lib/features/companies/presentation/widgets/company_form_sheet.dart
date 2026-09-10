import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  String? logoLocalPath,
  bool removeLogo,
  String? numberUpdateUrl,
  bool allowNegativeBalance,
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
  final TextEditingController simTypeController;
  final TextEditingController costController;

  _PackageRow({String? id, String name = '', String simType = '', String cost = ''})
      : id = id ?? UniqueKey().toString(),
        nameController = TextEditingController(text: name),
        simTypeController = TextEditingController(text: simType),
        costController = TextEditingController(text: cost);
}

class _CompanyFormSheetState extends State<CompanyFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _notesController;
  late final TextEditingController _numberUpdateUrlController;
  late final List<_PackageRow> _packageRows;
  NumberUpdateProviderKey? _numberUpdateProvider;
  late bool _allowNegativeBalance;

  /// The company's current logo URL (remote, from a prior save) —
  /// shown as the starting preview when editing. Untouched by picking a
  /// new local file or removing it; `_save` decides what to actually
  /// send based on `_newLogoPath`/`_removeLogo` instead.
  String? _existingLogoUrl;
  String? _newLogoPath;
  bool _removeLogo = false;
  final _imagePicker = ImagePicker();

  bool get _isEditing => widget.company != null;

  @override
  void initState() {
    super.initState();
    final company = widget.company;
    _nameController = TextEditingController(text: company?.name ?? '');
    _notesController = TextEditingController(text: company?.notes ?? '');
    _numberUpdateUrlController = TextEditingController(text: company?.numberUpdateUrl ?? '');
    _numberUpdateProvider = company?.numberUpdateProvider;
    _allowNegativeBalance = company?.allowNegativeBalance ?? false;
    _existingLogoUrl = company?.logoUrl;
    _packageRows = company?.packages
            .map((p) => _PackageRow(
                  id: p.id,
                  name: p.name,
                  simType: p.simType ?? '',
                  cost: p.wholesaleCost == p.wholesaleCost.roundToDouble() ? p.wholesaleCost.toStringAsFixed(0) : p.wholesaleCost.toString(),
                ))
            .toList() ??
        [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _numberUpdateUrlController.dispose();
    for (final row in _packageRows) {
      row.nameController.dispose();
      row.simTypeController.dispose();
      row.costController.dispose();
    }
    super.dispose();
  }

  void _addPackageRow() {
    setState(() => _packageRows.add(_PackageRow()));
  }

  void _removePackageRow(_PackageRow row) {
    setState(() => _packageRows.remove(row));
  }

  Future<void> _pickLogo() async {
    final file = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 512, maxHeight: 512);
    if (file == null) return;
    setState(() {
      _newLogoPath = file.path;
      _removeLogo = false;
    });
  }

  void _removeLogoTapped() {
    setState(() {
      _newLogoPath = null;
      _existingLogoUrl = null;
      _removeLogo = true;
    });
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final packages = _packageRows
        .where((row) => row.nameController.text.trim().isNotEmpty && row.simTypeController.text.trim().isNotEmpty)
        .map((row) => CompanyPackage(
              id: row.id,
              name: row.nameController.text.trim(),
              simType: row.simTypeController.text.trim(),
              wholesaleCost: double.tryParse(row.costController.text.trim()) ?? 0,
              // Retail price is no longer set at the package/company
              // level — a seller may want to charge different customers
              // differently for the same package, so it's entered fresh
              // every time a line is actually sold (New Sale / "+ Add
              // Line") instead. See CompanyPackage's doc comment.
              retailPrice: 0,
            ))
        .toList();

    widget.onSave(
      name,
      _notesController.text.trim(),
      packages,
      _numberUpdateProvider,
      _newLogoPath,
      _removeLogo,
      _numberUpdateUrlController.text.trim(),
      _allowNegativeBalance,
    );
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
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickLogo,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(color: colors.surface, shape: BoxShape.circle, border: Border.all(color: colors.border)),
                        clipBehavior: Clip.antiAlias,
                        child: _newLogoPath != null
                            ? Image.file(File(_newLogoPath!), fit: BoxFit.cover)
                            : (_existingLogoUrl != null
                                ? Image.network(_existingLogoUrl!, fit: BoxFit.cover)
                                : Icon(Icons.apartment_rounded, color: colors.textSecondary, size: 28)),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(onPressed: _pickLogo, child: Text('companies.form.logoChoose'.tr())),
                        if (_newLogoPath != null || _existingLogoUrl != null) ...[
                          const SizedBox(width: AppSpacing.xs),
                          TextButton(
                            onPressed: _removeLogoTapped,
                            child: Text('companies.form.logoRemove'.tr(), style: TextStyle(color: colors.danger)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
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
              const SizedBox(height: AppSpacing.md),
              Text('companies.form.numberUpdateUrlLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _numberUpdateUrlController,
                keyboardType: TextInputType.url,
                style: AppTextStyles.cardTitle(colors.textPrimary),
                decoration: _inputDecoration(colors).copyWith(hintText: 'https://...'),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
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
                        Expanded(
                          child: Text(
                            'companies.form.allowNegativeBalanceLabel'.tr(),
                            style: AppTextStyles.cardTitle(colors.textPrimary),
                          ),
                        ),
                        Switch(
                          value: _allowNegativeBalance,
                          activeThumbColor: colors.primaryAction,
                          onChanged: (value) => setState(() => _allowNegativeBalance = value),
                        ),
                      ],
                    ),
                    if (_allowNegativeBalance) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'companies.form.allowNegativeBalanceExplanation'.tr(),
                        style: AppTextStyles.body(colors.textSecondary),
                      ),
                    ],
                  ],
                ),
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
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: TextField(
                  controller: row.simTypeController,
                  style: AppTextStyles.body(colors.textPrimary),
                  decoration: decoration.copyWith(hintText: 'companies.form.simTypePlaceholder'.tr()),
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
          TextField(
            controller: row.costController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: AppTextStyles.body(colors.textPrimary),
            decoration: decoration.copyWith(hintText: 'companies.form.wholesaleCostPlaceholder'.tr()),
          ),
        ],
      ),
    );
  }
}

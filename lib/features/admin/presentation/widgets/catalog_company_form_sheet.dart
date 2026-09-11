import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/number_update/number_update_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/catalog_company_admin.dart';

typedef CatalogCompanySaveCallback = void Function(
  String name,
  String notes,
  String numberUpdateUrl,
  NumberUpdateProviderKey? numberUpdateProvider,
  String? logoLocalPath,
  bool removeLogo,
  List<CatalogPackageAdmin> packages,
);

/// Add/Edit a `company_catalog` template — admin-only. Package rows are
/// freely add/removable, same shape as the seller-facing
/// `CompanyFormSheet`, plus the number-update URL field that only exists
/// at the catalog level (see design/APP_CONTEXT.md).
class CatalogCompanyFormSheet extends StatefulWidget {
  final CatalogCompanyAdmin? company;
  final CatalogCompanySaveCallback onSave;

  const CatalogCompanyFormSheet({super.key, this.company, required this.onSave});

  static Future<void> show(BuildContext context, {CatalogCompanyAdmin? company, required CatalogCompanySaveCallback onSave}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CatalogCompanyFormSheet(company: company, onSave: onSave),
    );
  }

  @override
  State<CatalogCompanyFormSheet> createState() => _CatalogCompanyFormSheetState();
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

class _CatalogCompanyFormSheetState extends State<CatalogCompanyFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _notesController;
  late final TextEditingController _urlController;
  late final List<_PackageRow> _packageRows;
  NumberUpdateProviderKey? _numberUpdateProvider;
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
    _urlController = TextEditingController(text: company?.numberUpdateUrl ?? '');
    _numberUpdateProvider = company?.numberUpdateProvider;
    _existingLogoUrl = company?.logoUrl;
    _packageRows = company?.packages
            .map((p) => _PackageRow(
                  id: p.id,
                  name: p.name,
                  simType: p.simType ?? '',
                  cost: _fmt(p.wholesaleCost),
                ))
            .toList() ??
        [];

    _nameController.addListener(() => setState(() {}));
  }

  String _fmt(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _urlController.dispose();
    for (final row in _packageRows) {
      row.nameController.dispose();
      row.simTypeController.dispose();
      row.costController.dispose();
    }
    super.dispose();
  }

  void _addPackageRow() => setState(() => _packageRows.add(_PackageRow()));
  void _removePackageRow(_PackageRow row) => setState(() => _packageRows.remove(row));

  bool get _canSave => _nameController.text.trim().isNotEmpty;

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
    if (!_canSave) return;
    final packages = _packageRows
        .where((row) => row.nameController.text.trim().isNotEmpty && row.simTypeController.text.trim().isNotEmpty)
        .map((row) => CatalogPackageAdmin(
              id: row.id,
              name: row.nameController.text.trim(),
              simType: row.simTypeController.text.trim(),
              wholesaleCost: double.tryParse(row.costController.text.trim()) ?? 0,
              // The seller is free to set their own retail price per
              // sale — see CompanyPackage's doc comment. The catalog
              // (and imported companies' packages) no longer carry one.
              suggestedRetailPrice: 0,
            ))
        .toList();

    widget.onSave(
      _nameController.text.trim(),
      _notesController.text.trim(),
      _urlController.text.trim(),
      _numberUpdateProvider,
      _newLogoPath,
      _removeLogo,
      packages,
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
                  Text(_isEditing ? 'admin.catalogForm.editTitle'.tr() : 'admin.catalogForm.addTitle'.tr(), style: AppTextStyles.sectionHeader(colors.textPrimary)),
                  GestureDetector(onTap: () => Navigator.of(context).pop(), child: Icon(Icons.close_rounded, color: colors.textSecondary)),
                ],
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
              Text('admin.catalogForm.nameLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
              const SizedBox(height: AppSpacing.xs),
              TextField(controller: _nameController, style: AppTextStyles.cardTitle(colors.textPrimary), decoration: _decoration(colors)),
              const SizedBox(height: AppSpacing.md),
              Text('admin.catalogForm.numberUpdateUrlLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _urlController,
                keyboardType: TextInputType.url,
                style: AppTextStyles.cardTitle(colors.textPrimary),
                decoration: _decoration(colors, hint: 'https://...'),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('admin.catalogForm.numberUpdateProviderLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
              const SizedBox(height: AppSpacing.xs),
              DropdownButtonFormField<NumberUpdateProviderKey?>(
                initialValue: _numberUpdateProvider,
                isExpanded: true,
                style: AppTextStyles.cardTitle(colors.textPrimary),
                decoration: _decoration(colors),
                items: [
                  DropdownMenuItem(value: null, child: Text('numberUpdateProvider.none'.tr(), overflow: TextOverflow.ellipsis)),
                  ...NumberUpdateProviderKey.values.map(
                    (key) => DropdownMenuItem(value: key, child: Text(key.label, overflow: TextOverflow.ellipsis)),
                  ),
                ],
                onChanged: (value) => setState(() => _numberUpdateProvider = value),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('admin.catalogForm.notesLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
              const SizedBox(height: AppSpacing.xs),
              TextField(controller: _notesController, style: AppTextStyles.cardTitle(colors.textPrimary), minLines: 2, maxLines: 4, decoration: _decoration(colors)),
              const SizedBox(height: AppSpacing.lg),
              Text('admin.catalogForm.packagesSection'.tr(), style: AppTextStyles.overline(colors.textSecondary)),
              const SizedBox(height: AppSpacing.sm),
              ..._packageRows.map((row) => _PackageRowFields(key: ValueKey(row.id), row: row, onRemove: () => _removePackageRow(row))),
              OutlinedButton.icon(
                onPressed: _addPackageRow,
                icon: Icon(Icons.add_rounded, color: colors.textPrimary, size: 18),
                label: Text('admin.catalogForm.addPackage'.tr(), style: AppTextStyles.body(colors.textPrimary)),
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
                  onPressed: _canSave ? _save : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primaryAction,
                    foregroundColor: colors.onPrimaryAction,
                    disabledBackgroundColor: colors.primaryAction.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button)),
                    elevation: 0,
                  ),
                  child: Text('admin.catalogForm.save'.tr(), style: AppTextStyles.cardTitle(colors.onPrimaryAction)),
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
      hintStyle: AppTextStyles.hint(colors.textSecondary),
      filled: true,
      fillColor: colors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.button), borderSide: BorderSide(color: colors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.button), borderSide: BorderSide(color: colors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.button), borderSide: BorderSide(color: colors.primaryAction, width: 1.5)),
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
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.button), borderSide: BorderSide(color: colors.primaryAction, width: 1.5)),
      hintStyle: AppTextStyles.hint(colors.textSecondary),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(border: Border.all(color: colors.border), borderRadius: BorderRadius.circular(AppRadii.button)),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: row.nameController,
                  style: AppTextStyles.body(colors.textPrimary),
                  decoration: decoration.copyWith(hintText: 'admin.catalogForm.packageNamePlaceholder'.tr()),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: TextField(
                  controller: row.simTypeController,
                  style: AppTextStyles.body(colors.textPrimary),
                  decoration: decoration.copyWith(hintText: 'admin.catalogForm.simTypePlaceholder'.tr()),
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
            decoration: decoration.copyWith(hintText: 'admin.catalogForm.wholesaleCostPlaceholder'.tr()),
          ),
        ],
      ),
    );
  }
}

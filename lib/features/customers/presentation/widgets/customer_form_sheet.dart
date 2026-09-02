import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/customer.dart';

/// Add/Edit Customer bottom sheet. Pass [customer] to prefill for editing —
/// omit it to add a new customer. Matches design/screenshots/new customer.png.
class CustomerFormSheet extends StatefulWidget {
  final Customer? customer;
  final void Function(String name, String contactNumber, List<String> tags, CustomerStatus status, bool pinned, String notes) onSave;

  const CustomerFormSheet({super.key, this.customer, required this.onSave});

  static Future<void> show(
    BuildContext context, {
    Customer? customer,
    required void Function(String, String, List<String>, CustomerStatus, bool, String) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomerFormSheet(customer: customer, onSave: onSave),
    );
  }

  @override
  State<CustomerFormSheet> createState() => _CustomerFormSheetState();
}

class _CustomerFormSheetState extends State<CustomerFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _contactController;
  late final TextEditingController _tagsController;
  late final TextEditingController _notesController;
  late CustomerStatus _status;
  late bool _pinned;

  bool get _isEditing => widget.customer != null;

  @override
  void initState() {
    super.initState();
    final customer = widget.customer;
    _nameController = TextEditingController(text: customer?.name ?? '');
    _contactController = TextEditingController(text: customer?.contactNumber ?? '');
    _tagsController = TextEditingController(text: customer?.tags.join(', ') ?? '');
    _notesController = TextEditingController(text: customer?.notes ?? '');
    _status = customer?.status ?? CustomerStatus.normal;
    _pinned = customer?.pinned ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _tagsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final tags = _tagsController.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

    widget.onSave(name, _contactController.text.trim(), tags, _status, _pinned, _notesController.text.trim());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final canSave = _nameController.text.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
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
                  Text(_isEditing ? 'customers.form.editTitle'.tr() : 'customers.form.addTitle'.tr(), style: AppTextStyles.sectionHeader(colors.textPrimary)),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(Icons.close_rounded, color: colors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('customers.form.contactHint'.tr(), style: AppTextStyles.body(colors.textSecondary)),
              const SizedBox(height: AppSpacing.lg),
              Text('customers.form.nameLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _nameController,
                style: AppTextStyles.cardTitle(colors.textPrimary),
                onChanged: (_) => setState(() {}),
                decoration: _decoration(colors),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('customers.form.contactLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                style: AppTextStyles.cardTitle(colors.textPrimary),
                decoration: _decoration(colors, hint: '0599123456'),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('customers.form.tagsLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _tagsController,
                style: AppTextStyles.cardTitle(colors.textPrimary),
                decoration: _decoration(colors),
              ),
              const SizedBox(height: 4),
              Text('customers.form.tagsHelper'.tr(), style: AppTextStyles.body(colors.textSecondary)),
              const SizedBox(height: AppSpacing.md),
              Text('customers.form.statusLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
              const SizedBox(height: AppSpacing.xs),
              DropdownButtonFormField<CustomerStatus>(
                initialValue: _status,
                style: AppTextStyles.cardTitle(colors.textPrimary),
                dropdownColor: colors.surface,
                decoration: _decoration(colors),
                items: CustomerStatus.values
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _status = value);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.button),
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('customers.form.pinToTop'.tr(), style: AppTextStyles.cardTitle(colors.textPrimary)),
                    Switch(
                      value: _pinned,
                      onChanged: (value) => setState(() => _pinned = value),
                      activeTrackColor: colors.primaryAction,
                      thumbColor: WidgetStateProperty.all(colors.onPrimaryAction),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('customers.form.notesLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _notesController,
                style: AppTextStyles.cardTitle(colors.textPrimary),
                minLines: 3,
                maxLines: 5,
                decoration: _decoration(colors),
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
                  child: Text('customers.form.save'.tr(), style: AppTextStyles.cardTitle(colors.onPrimaryAction)),
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

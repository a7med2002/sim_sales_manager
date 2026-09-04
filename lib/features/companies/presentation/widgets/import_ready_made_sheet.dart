import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/company.dart';
import '../../domain/entities/preset_company.dart';

/// "Import Ready-Made" sheet: pick a brand from [presets] — either the
/// static offline/demo list, or (in real multi-tenant mode) the live,
/// admin-managed `company_catalog`, fetched by the caller before opening
/// this sheet. Already-active brands show an "Active" badge and can't be
/// re-imported; already-archived ones show "Archived" and can be tapped
/// to re-import (restores to active).
class ImportReadyMadeSheet extends StatelessWidget {
  final List<PresetCompany> presets;
  final List<Company> currentCompanies;
  final void Function(PresetCompany preset) onImport;

  const ImportReadyMadeSheet({super.key, required this.presets, required this.currentCompanies, required this.onImport});

  static Future<void> show(
    BuildContext context, {
    required List<PresetCompany> presets,
    required List<Company> currentCompanies,
    required void Function(PresetCompany) onImport,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ImportReadyMadeSheet(presets: presets, currentCompanies: currentCompanies, onImport: onImport),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.card)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('companies.import.title'.tr(), style: AppTextStyles.sectionHeader(colors.textPrimary)),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.close_rounded, color: colors.textSecondary),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 4, AppSpacing.lg, AppSpacing.md),
            child: Text('companies.import.subtitle'.tr(), style: AppTextStyles.body(colors.textSecondary)),
          ),
          if (presets.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: EmptyState(
                icon: Icons.apartment_rounded,
                title: 'companies.import.emptyCatalogTitle'.tr(),
                description: 'companies.import.emptyCatalogDescription'.tr(),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                itemCount: presets.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final preset = presets[index];
                  final existing = currentCompanies.where((c) => c.id == preset.id).toList();
                  final match = existing.isEmpty ? null : existing.first;
                  final isActive = match?.status == CompanyStatus.active;

                  return _PresetTile(
                    preset: preset,
                    isActive: isActive,
                    isArchived: match?.status == CompanyStatus.archived,
                    onTap: isActive
                        ? null
                        : () {
                            onImport(preset);
                            Navigator.of(context).pop();
                          },
                  );
                },
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _PresetTile extends StatelessWidget {
  final PresetCompany preset;
  final bool isActive;
  final bool isArchived;
  final VoidCallback? onTap;

  const _PresetTile({required this.preset, required this.isActive, required this.isArchived, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: colors.background, shape: BoxShape.circle, border: Border.all(color: colors.border)),
              alignment: Alignment.center,
              child: Text(preset.initials, style: AppTextStyles.cardTitle(colors.textPrimary)),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(preset.name, style: AppTextStyles.cardTitle(colors.textPrimary)),
                  Text('companies.import.packagesCount'.tr(namedArgs: {'count': '${preset.defaultPackages.length}'}), style: AppTextStyles.body(colors.textSecondary)),
                ],
              ),
            ),
            if (isActive)
              StatusBadge(label: 'companies.import.active'.tr(), type: StatusBadgeType.success)
            else if (isArchived)
              StatusBadge(label: 'companies.import.archivedTapToReimport'.tr(), type: StatusBadgeType.neutral)
            else
              Icon(Icons.download_outlined, color: colors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

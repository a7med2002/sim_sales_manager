import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/company.dart';

/// Company card for the Companies list: avatar/name/pin, packages &
/// operations count, profit generated, a 3-dot actions menu, balance-usage
/// progress bar, and consumed/available/owed row.
class CompanyCard extends StatelessWidget {
  final Company company;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onTogglePin;
  final VoidCallback onArchive;
  final VoidCallback onRestore;
  final VoidCallback onDelete;
  final VoidCallback onPermanentlyDelete;

  const CompanyCard({
    super.key,
    required this.company,
    required this.onTap,
    required this.onEdit,
    required this.onTogglePin,
    required this.onArchive,
    required this.onRestore,
    required this.onDelete,
    required this.onPermanentlyDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.background,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.border),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    company.initials,
                    style: AppTextStyles.cardTitle(colors.textPrimary),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              company.name,
                              style: AppTextStyles.cardTitle(
                                colors.textPrimary,
                              ),
                            ),
                          ),
                          if (company.pinned) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.push_pin_rounded,
                              size: 14,
                              color: colors.textSecondary,
                            ),
                          ],
                        ],
                      ),
                      Text(
                        'companies.card.packagesOperations'.tr(
                          namedArgs: {
                            'packages': '${company.packages.length}',
                            'operations': '${company.operationsCount}',
                          },
                        ),
                        style: AppTextStyles.body(colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'companies.card.profitGenerated'.tr(),
                      style: AppTextStyles.body(
                        colors.textSecondary,
                      ).copyWith(fontSize: 10),
                    ),
                    Text(
                      formatCurrency(company.profitGenerated),
                      style: AppTextStyles.cardTitle(colors.success),
                    ),
                  ],
                ),
                _ActionsMenu(
                  company: company,
                  onEdit: onEdit,
                  onTogglePin: onTogglePin,
                  onArchive: onArchive,
                  onRestore: onRestore,
                  onDelete: onDelete,
                  onPermanentlyDelete: onPermanentlyDelete,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'companies.card.balanceUsed'.tr(),
                  style: AppTextStyles.body(colors.textSecondary),
                ),
                Text(
                  '${company.usagePercent}%',
                  style: AppTextStyles.body(colors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.pill),
              child: LinearProgressIndicator(
                value: (company.usagePercent / 100).clamp(0, 1).toDouble(),
                minHeight: 6,
                backgroundColor: colors.border,
                valueColor: AlwaysStoppedAnimation(colors.primaryAction),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _DataColumn(
                  label: 'companies.card.consumed'.tr(),
                  value: formatCurrency(company.consumed),
                  color: colors.textPrimary,
                ),
                _DataColumn(
                  label: 'companies.card.availableToSell'.tr(),
                  value: formatCurrency(company.availableToSell),
                  color: colors.textPrimary,
                ),
                _DataColumn(
                  label: 'companies.card.owedToCompany'.tr(),
                  value: formatCurrency(company.owedToCompany),
                  color: company.owedToCompany > 0
                      ? colors.danger
                      : colors.textPrimary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DataColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DataColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.body(colors.textSecondary)),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.cardTitle(color)),
        ],
      ),
    );
  }
}

class _ActionsMenu extends StatelessWidget {
  final Company company;
  final VoidCallback onEdit;
  final VoidCallback onTogglePin;
  final VoidCallback onArchive;
  final VoidCallback onRestore;
  final VoidCallback onDelete;
  final VoidCallback onPermanentlyDelete;

  const _ActionsMenu({
    required this.company,
    required this.onEdit,
    required this.onTogglePin,
    required this.onArchive,
    required this.onRestore,
    required this.onDelete,
    required this.onPermanentlyDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PopupMenuButton<VoidCallback>(
      icon: Icon(
        Icons.more_vert_rounded,
        color: colors.textSecondary,
        size: 20,
      ),
      padding: EdgeInsets.zero,
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.button),
        side: BorderSide(color: colors.border),
      ),
      onSelected: (action) => action(),
      itemBuilder: (context) {
        final items = <PopupMenuEntry<VoidCallback>>[];

        if (company.status != CompanyStatus.deleted) {
          items.add(
            _item(
              context,
              'companies.menu.edit'.tr(),
              Icons.edit_outlined,
              onEdit,
            ),
          );
        }
        if (company.status == CompanyStatus.active) {
          items.add(
            _item(
              context,
              company.pinned
                  ? 'companies.menu.unpin'.tr()
                  : 'companies.menu.pinToTop'.tr(),
              company.pinned ? Icons.push_pin : Icons.push_pin_outlined,
              onTogglePin,
            ),
          );
          items.add(
            _item(
              context,
              'companies.menu.archive'.tr(),
              Icons.archive_outlined,
              onArchive,
            ),
          );
          items.add(
            _item(
              context,
              'companies.menu.delete'.tr(),
              Icons.delete_outline_rounded,
              onDelete,
              isDanger: true,
            ),
          );
        } else if (company.status == CompanyStatus.archived) {
          items.add(
            _item(
              context,
              'companies.menu.restoreToActive'.tr(),
              Icons.unarchive_outlined,
              onRestore,
            ),
          );
          items.add(
            _item(
              context,
              'companies.menu.delete'.tr(),
              Icons.delete_outline_rounded,
              onDelete,
              isDanger: true,
            ),
          );
        } else {
          items.add(
            _item(
              context,
              'companies.menu.restoreToActive'.tr(),
              Icons.restore_rounded,
              onRestore,
            ),
          );
          items.add(
            _item(
              context,
              'companies.menu.deletePermanently'.tr(),
              Icons.delete_forever_rounded,
              onPermanentlyDelete,
              isDanger: true,
            ),
          );
        }

        return items;
      },
    );
  }

  PopupMenuItem<VoidCallback> _item(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback action, {
    bool isDanger = false,
  }) {
    final colors = context.colors;
    final color = isDanger ? colors.danger : colors.textPrimary;

    return PopupMenuItem<VoidCallback>(
      value: action,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: AppTextStyles.body(color)),
        ],
      ),
    );
  }
}

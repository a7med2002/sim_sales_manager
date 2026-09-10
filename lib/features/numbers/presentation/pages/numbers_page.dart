import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/catalog/company_catalog.dart';
import '../../../../core/catalog/customer_catalog.dart';
import '../../../../core/catalog/line_summary.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/package_display.dart';
import '../../../../core/utils/table_export.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/company_filter_dropdown.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/page_size_dropdown.dart';
import '../../../../core/widgets/period_filter_row.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../data/numbers_export.dart';
import '../cubit/numbers_cubit.dart';
import '../cubit/numbers_state.dart';

/// Numbers / "Number Management": a global log of every sold Line/SIM
/// across every customer, with period/company/status filters, search,
/// and a page size cap. Matches APP_CONTEXT.md's "2. Numbers" spec (no
/// reference screenshot exists for this page).
class NumbersPage extends StatelessWidget {
  const NumbersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NumbersCubit(customerCatalog: getIt<CustomerCatalog>(), companyCatalog: getIt<CompanyCatalog>()),
      child: const _NumbersView(),
    );
  }
}

class _NumbersView extends StatefulWidget {
  const _NumbersView();

  @override
  State<_NumbersView> createState() => _NumbersViewState();
}

class _NumbersViewState extends State<_NumbersView> {
  TableExportFormat? _exportingFormat;

  Future<void> _export(NumbersState state, TableExportFormat format) async {
    if (_exportingFormat != null) return;
    final lines = state.exportLines;
    if (lines.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('numbers.export.empty'.tr())));
      return;
    }
    setState(() => _exportingFormat = format);
    try {
      await exportNumbers(context: context, lines: lines, format: format);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('numbers.export.error'.tr())));
      }
    } finally {
      if (mounted) setState(() => _exportingFormat = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: BlocBuilder<NumbersCubit, NumbersState>(
          builder: (context, state) {
            final cubit = context.read<NumbersCubit>();
            final visible = state.filteredLines;

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal).copyWith(
                top: AppSpacing.md,
                bottom: AppSpacing.xl,
              ),
              children: [
                AppTopBar(
                  title: 'numbers.title'.tr(),
                  subtitle: 'numbers.subtitle'.tr(),
                  showBack: true,
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _ExportButton(
                      label: 'numbers.export.pdf'.tr(),
                      isLoading: _exportingFormat == TableExportFormat.pdf,
                      isDisabled: _exportingFormat != null,
                      onTap: () => _export(state, TableExportFormat.pdf),
                    ),
                    _ExportButton(
                      label: 'numbers.export.csv'.tr(),
                      isLoading: _exportingFormat == TableExportFormat.csv,
                      isDisabled: _exportingFormat != null,
                      onTap: () => _export(state, TableExportFormat.csv),
                    ),
                    _ExportButton(
                      label: 'numbers.export.excel'.tr(),
                      isLoading: _exportingFormat == TableExportFormat.excel,
                      isDisabled: _exportingFormat != null,
                      onTap: () => _export(state, TableExportFormat.excel),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                PeriodFilterRow(
                  selectedPeriod: state.period,
                  customRange: state.customRange,
                  onPeriodSelected: cubit.periodChanged,
                  onCustomRangeSelected: cubit.customRangeChanged,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: CompanyFilterDropdown(
                        companies: state.companies,
                        value: state.companyFilter,
                        onChanged: cubit.companyFilterChanged,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        onChanged: cubit.searchChanged,
                        style: AppTextStyles.body(colors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'numbers.searchHint'.tr(),
                          hintStyle: AppTextStyles.body(colors.textSecondary),
                          prefixIcon: Icon(Icons.search_rounded, color: colors.textSecondary, size: 20),
                          filled: true,
                          fillColor: colors.surface,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.button), borderSide: BorderSide(color: colors.border)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.button), borderSide: BorderSide(color: colors.border)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadii.button),
                            borderSide: BorderSide(color: colors.primaryAction, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _StatusDotPill(label: 'common.all'.tr(), dotColor: null, isActive: state.statusFilter == null, onTap: () => cubit.statusFilterChanged(null)),
                    _StatusDotPill(
                      label: LineHealthStatus.active.label,
                      dotColor: colors.success,
                      isActive: state.statusFilter == LineHealthStatus.active,
                      onTap: () => cubit.statusFilterChanged(LineHealthStatus.active),
                    ),
                    _StatusDotPill(
                      label: LineHealthStatus.expiringSoon.label,
                      dotColor: colors.warning,
                      isActive: state.statusFilter == LineHealthStatus.expiringSoon,
                      onTap: () => cubit.statusFilterChanged(LineHealthStatus.expiringSoon),
                    ),
                    _StatusDotPill(
                      label: LineHealthStatus.expired.label,
                      dotColor: colors.danger,
                      isActive: state.statusFilter == LineHealthStatus.expired,
                      onTap: () => cubit.statusFilterChanged(LineHealthStatus.expired),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('numbers.matchCount'.tr(namedArgs: {'count': '${state.totalMatchCount}'}), style: AppTextStyles.body(colors.textSecondary)),
                    PageSizeDropdown(value: state.pageSize, onChanged: cubit.pageSizeChanged),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (visible.isEmpty)
                  EmptyState(
                    icon: Icons.tag_outlined,
                    title: 'numbers.empty.title'.tr(),
                    description: 'numbers.empty.description'.tr(),
                  )
                else
                  _NumbersTable(lines: visible),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final bool isDisabled;
  final VoidCallback onTap;

  const _ExportButton({required this.label, required this.onTap, this.isLoading = false, this.isDisabled = false});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return OutlinedButton.icon(
      onPressed: isDisabled ? null : onTap,
      icon: isLoading
          ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: colors.textSecondary))
          : Icon(Icons.download_outlined, size: 16, color: colors.textPrimary),
      label: Text(label, style: AppTextStyles.body(colors.textPrimary)),
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.textPrimary,
        side: BorderSide(color: colors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button)),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 8),
      ),
    );
  }
}

class _StatusDotPill extends StatelessWidget {
  final String label;
  final Color? dotColor;
  final bool isActive;
  final VoidCallback onTap;

  const _StatusDotPill({required this.label, required this.dotColor, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isActive ? colors.primaryAction : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: isActive ? colors.primaryAction : colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null) ...[
              Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyles.body(isActive ? colors.onPrimaryAction : colors.textPrimary).copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumbersTable extends StatelessWidget {
  final List<LineSummary> lines;

  const _NumbersTable({required this.lines});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final now = DateTime.now();

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: colors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(colors.background),
            headingTextStyle: AppTextStyles.body(colors.textSecondary).copyWith(fontWeight: FontWeight.w600),
            dataTextStyle: AppTextStyles.body(colors.textPrimary),
            dividerThickness: 1,
            columns: [
              DataColumn(label: Text('numbers.table.number'.tr())),
              DataColumn(label: Text('numbers.table.company'.tr())),
              DataColumn(label: Text('numbers.table.package'.tr())),
              DataColumn(label: Text('numbers.table.status'.tr())),
              DataColumn(label: Text('numbers.table.dateAdded'.tr())),
              DataColumn(label: Text('numbers.table.expiryDate'.tr())),
            ],
            rows: lines.map((line) {
              final status = line.statusAt(now);
              final expiryColor = switch (status) {
                LineHealthStatus.active => colors.success,
                LineHealthStatus.expiringSoon => colors.warning,
                LineHealthStatus.expired => colors.danger,
              };
              final badgeType = switch (status) {
                LineHealthStatus.active => StatusBadgeType.success,
                LineHealthStatus.expiringSoon => StatusBadgeType.warning,
                LineHealthStatus.expired => StatusBadgeType.danger,
              };

              return DataRow(cells: [
                DataCell(Text(line.simNumber)),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(color: colors.background, shape: BoxShape.circle, border: Border.all(color: colors.border)),
                      alignment: Alignment.center,
                      child: Text(line.companyInitials, style: AppTextStyles.badge(colors.textPrimary)),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(line.companyName),
                  ],
                )),
                DataCell(Text(packageDisplayLabel(line.packageName, line.packageSimType))),
                DataCell(StatusBadge(label: status.label, type: badgeType)),
                DataCell(Text(formatDate(line.purchaseDate))),
                DataCell(Text(formatDate(line.expiryDate), style: AppTextStyles.body(expiryColor).copyWith(fontWeight: FontWeight.w600))),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}

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
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/company_filter_dropdown.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/period_filter_row.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../cubit/reports_cubit.dart';
import '../cubit/reports_state.dart';

/// Reports: period + company filtered summary + a full detailed
/// operations table, over the same real `CustomerCatalog`/
/// `CompanyCatalog` data Numbers and Profits already use. Matches
/// APP_CONTEXT.md's "4. Reports" spec (no reference screenshot exists
/// for this page).
class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReportsCubit(
        customerCatalog: getIt<CustomerCatalog>(),
        companyCatalog: getIt<CompanyCatalog>(),
        repName: getIt<ProfileCubit>().state.name,
      ),
      child: const _ReportsView(),
    );
  }
}

class _ReportsView extends StatelessWidget {
  const _ReportsView();

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('common.comingSoon'.tr())));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: BlocBuilder<ReportsCubit, ReportsState>(
          builder: (context, state) {
            final cubit = context.read<ReportsCubit>();
            final lines = state.filteredLines;

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal).copyWith(
                top: AppSpacing.md,
                bottom: AppSpacing.xl,
              ),
              children: [
                AppTopBar(title: 'reports.title'.tr(), showBack: true),
                const SizedBox(height: AppSpacing.md),
                PeriodFilterRow(
                  selectedPeriod: state.period,
                  customRange: state.customRange,
                  onPeriodSelected: cubit.selectPeriod,
                  onCustomRangeSelected: cubit.selectCustomRange,
                ),
                const SizedBox(height: AppSpacing.sm),
                CompanyFilterDropdown(
                  companies: state.companies,
                  value: state.companyFilter,
                  onChanged: cubit.selectCompany,
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _comingSoon(context),
                      icon: Icon(Icons.picture_as_pdf_outlined, size: 16, color: colors.textPrimary),
                      label: Text('reports.printSavePdf'.tr(), style: AppTextStyles.body(colors.textPrimary)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.textPrimary,
                        side: BorderSide(color: colors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button)),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _comingSoon(context),
                      icon: Icon(Icons.table_chart_outlined, size: 16, color: colors.textPrimary),
                      label: Text('reports.exportExcel'.tr(), style: AppTextStyles.body(colors.textPrimary)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.textPrimary,
                        side: BorderSide(color: colors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.trending_up_rounded,
                        iconColor: colors.success,
                        title: 'reports.totalProfit'.tr(),
                        value: formatCurrency(state.totalProfit),
                        valueColor: colors.success,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.cardGap),
                    Expanded(
                      child: StatCard(
                        icon: Icons.payments_outlined,
                        iconColor: colors.textPrimary,
                        title: 'reports.totalSales'.tr(),
                        value: formatCurrency(state.totalSales),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.cardGap),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.sim_card_outlined,
                        iconColor: colors.textPrimary,
                        title: 'reports.linesSold'.tr(),
                        value: '${state.linesSold}',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.cardGap),
                    Expanded(
                      child: StatCard(
                        icon: Icons.insights_rounded,
                        iconColor: colors.textPrimary,
                        title: 'reports.operations'.tr(),
                        value: '${state.operationsCount}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.cardGap),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.error_outline_rounded,
                        iconColor: colors.danger,
                        title: 'reports.toCollect'.tr(),
                        value: formatCurrency(state.amountToCollect),
                        valueColor: state.amountToCollect > 0 ? colors.danger : null,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.cardGap),
                    Expanded(
                      child: StatCard(
                        icon: Icons.hourglass_bottom_rounded,
                        iconColor: colors.warning,
                        title: 'reports.partiallyPaid'.tr(),
                        value: '${state.partiallyPaidCount}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.cardGap),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.cancel_outlined,
                        iconColor: colors.danger,
                        title: 'reports.unpaid'.tr(),
                        value: '${state.unpaidCount}',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.cardGap),
                    const Expanded(child: SizedBox()),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('reports.operationsSection'.tr(), style: AppTextStyles.overline(colors.textSecondary)),
                const SizedBox(height: AppSpacing.sm),
                if (lines.isEmpty)
                  EmptyState(
                    icon: Icons.description_outlined,
                    title: 'reports.empty.title'.tr(),
                    description: 'reports.empty.description'.tr(),
                  )
                else
                  _OperationsTable(lines: lines, repName: state.repName),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OperationsTable extends StatelessWidget {
  final List<LineSummary> lines;
  final String repName;

  const _OperationsTable({required this.lines, required this.repName});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
              DataColumn(label: Text('reports.table.date'.tr())),
              DataColumn(label: Text('reports.table.simNumber'.tr())),
              DataColumn(label: Text('reports.table.customer'.tr())),
              DataColumn(label: Text('reports.table.company'.tr())),
              DataColumn(label: Text('reports.table.package'.tr())),
              DataColumn(label: Text('reports.table.salePrice'.tr())),
              DataColumn(label: Text('reports.table.profit'.tr())),
              DataColumn(label: Text('reports.table.payment'.tr())),
              DataColumn(label: Text('reports.table.rep'.tr())),
            ],
            rows: lines.map((line) {
              return DataRow(cells: [
                DataCell(Text(formatDate(line.purchaseDate))),
                DataCell(Text(line.simNumber)),
                DataCell(Text(line.customerName)),
                DataCell(Text(line.companyName)),
                DataCell(Text(line.packageName)),
                DataCell(Text(formatCurrency(line.retailPrice))),
                DataCell(Text(formatCurrency(line.profit), style: AppTextStyles.body(colors.success).copyWith(fontWeight: FontWeight.w600))),
                DataCell(_paymentBadge(line.paymentStatus)),
                DataCell(Text(repName)),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _paymentBadge(LinePaymentStatus status) {
    switch (status) {
      case LinePaymentStatus.paid:
        return StatusBadge(label: status.label, type: StatusBadgeType.success);
      case LinePaymentStatus.partial:
        return StatusBadge(label: status.label, type: StatusBadgeType.warning);
      case LinePaymentStatus.unpaid:
        return StatusBadge(label: status.label, type: StatusBadgeType.danger);
    }
  }
}

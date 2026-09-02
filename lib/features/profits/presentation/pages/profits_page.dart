import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/catalog/company_catalog.dart';
import '../../../../core/catalog/company_summary.dart';
import '../../../../core/catalog/customer_catalog.dart';
import '../../../../core/constants/period_filter.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/period_filter_row.dart';
import '../../../../core/widgets/stat_card.dart';
import '../cubit/profits_cubit.dart';
import '../cubit/profits_state.dart';

/// Profits: real profit/sales figures derived from every sold Line and
/// every Company's running profit total (see core/catalog/ extensions).
/// Matches APP_CONTEXT.md's "3. Profits" spec (no reference screenshot
/// exists for this page).
///
/// Chart choice: "Profit Over Time" uses fl_chart's animated LineChart
/// (a real win here — smooth area fill, built-in touch tooltips). "Best
/// Companies by Profit" needs a *horizontal* bar (company names as
/// labels, bar length = profit) — fl_chart's bar chart is vertical-only
/// without an awkward rotation workaround, so that one stays a simple
/// animated progress-bar list instead, which fits a horizontal ranking
/// more directly than forcing fl_chart into a shape it doesn't natively
/// support.
class ProfitsPage extends StatelessWidget {
  const ProfitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfitsCubit(customerCatalog: getIt<CustomerCatalog>(), companyCatalog: getIt<CompanyCatalog>()),
      child: const _ProfitsView(),
    );
  }
}

class _ProfitsView extends StatelessWidget {
  const _ProfitsView();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: BlocBuilder<ProfitsCubit, ProfitsState>(
          builder: (context, state) {
            final cubit = context.read<ProfitsCubit>();

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal).copyWith(
                top: AppSpacing.md,
                bottom: AppSpacing.xl,
              ),
              children: [
                AppTopBar(title: 'profits.title'.tr(), showBack: true),
                const SizedBox(height: AppSpacing.md),
                PeriodFilterRow(
                  selectedPeriod: state.selectedPeriod,
                  customRange: state.customRange,
                  onPeriodSelected: cubit.selectPeriod,
                  onCustomRangeSelected: cubit.selectCustomRange,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => cubit.selectPeriod(PeriodFilter.thisYear),
                        child: StatCard(
                          icon: Icons.calendar_today_outlined,
                          iconColor: colors.success,
                          title: 'profits.yearProfit'.tr(),
                          value: formatCurrency(state.yearProfit),
                          valueColor: colors.success,
                          caption: 'profits.opsTapToFilter'.tr(namedArgs: {'ops': '${state.yearOperations}'}),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.cardGap),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => cubit.selectPeriod(PeriodFilter.thisMonth),
                        child: StatCard(
                          icon: Icons.calendar_view_month_outlined,
                          iconColor: colors.success,
                          title: 'profits.monthProfit'.tr(),
                          value: formatCurrency(state.monthProfit),
                          valueColor: colors.success,
                          caption: 'profits.opsTapToFilter'.tr(namedArgs: {'ops': '${state.monthOperations}'}),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.cardGap),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => cubit.selectPeriod(PeriodFilter.thisWeek),
                        child: StatCard(
                          icon: Icons.calendar_view_week_outlined,
                          iconColor: colors.success,
                          title: 'profits.weekProfit'.tr(),
                          value: formatCurrency(state.weekProfit),
                          valueColor: colors.success,
                          caption: 'profits.opsTapToFilter'.tr(namedArgs: {'ops': '${state.weekOperations}'}),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.cardGap),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => cubit.selectPeriod(PeriodFilter.today),
                        child: StatCard(
                          icon: Icons.today_outlined,
                          iconColor: colors.success,
                          title: 'profits.todayProfit'.tr(),
                          value: formatCurrency(state.todayProfit),
                          valueColor: colors.success,
                          caption: 'profits.opsTapToFilter'.tr(namedArgs: {'ops': '${state.todayOperations}'}),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('profits.selectedPeriodSection'.tr(), style: AppTextStyles.overline(colors.textSecondary)),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.insights_rounded,
                        iconColor: colors.textPrimary,
                        title: 'profits.operations'.tr(),
                        value: '${state.selectedOperationsCount}',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.cardGap),
                    Expanded(
                      child: StatCard(
                        icon: Icons.trending_up_rounded,
                        iconColor: colors.success,
                        title: 'profits.netProfit'.tr(),
                        value: formatCurrency(state.selectedNetProfit),
                        valueColor: colors.success,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.cardGap),
                    Expanded(
                      child: StatCard(
                        icon: Icons.payments_outlined,
                        iconColor: colors.textPrimary,
                        title: 'profits.totalSales'.tr(),
                        value: formatCurrency(state.selectedTotalSales),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _SectionCard(
                  title: 'profits.profitOverTimeSection'.tr(),
                  child: _ProfitOverTimeChart(points: state.profitOverTime),
                ),
                const SizedBox(height: AppSpacing.md),
                _SectionCard(
                  title: 'profits.bestCompaniesSection'.tr(),
                  child: _BestCompaniesChart(companies: state.bestCompaniesByProfit),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.overline(colors.textSecondary)),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _ProfitOverTimeChart extends StatelessWidget {
  final List<ProfitPoint> points;

  const _ProfitOverTimeChart({required this.points});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final maxProfit = points.fold<double>(0, (max, p) => p.profit > max ? p.profit : max);
    final niceMaxY = maxProfit <= 0 ? 10.0 : maxProfit * 1.2;

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: niceMaxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: niceMaxY / 4,
            getDrawingHorizontalLine: (_) => FlLine(color: colors.border, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                interval: niceMaxY / 4,
                getTitlesWidget: (value, meta) => Text(formatCurrencyCompact(value), style: AppTextStyles.body(colors.textSecondary)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= points.length) return const SizedBox.shrink();
                  // A short, dedicated abbreviation (not the fuller name
                  // `formatDate` uses) — Arabic month names are full words
                  // and were overlapping each other across 6 narrow slots.
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      monthAbbreviation(points[index].month),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body(colors.textSecondary).copyWith(fontSize: 11),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => colors.textPrimary,
              getTooltipItems: (spots) => spots
                  .map((s) => LineTooltipItem(formatCurrency(s.y), AppTextStyles.body(colors.background).copyWith(fontWeight: FontWeight.w600)))
                  .toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].profit)],
              isCurved: true,
              color: colors.success,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [colors.success.withValues(alpha: 0.25), colors.success.withValues(alpha: 0.0)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BestCompaniesChart extends StatelessWidget {
  final List<CompanySummary> companies;

  const _BestCompaniesChart({required this.companies});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (companies.isEmpty) {
      return Text('profits.noCompaniesYet'.tr(), style: AppTextStyles.body(colors.textSecondary));
    }

    final maxProfit = companies.fold<double>(0, (max, c) => c.profitGenerated > max ? c.profitGenerated : max);

    return Column(
      children: companies.map((c) => _BestCompanyRow(company: c, maxProfit: maxProfit)).toList(),
    );
  }
}

class _BestCompanyRow extends StatelessWidget {
  final CompanySummary company;
  final double maxProfit;

  const _BestCompanyRow({required this.company, required this.maxProfit});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fraction = maxProfit <= 0 ? 0.0 : (company.profitGenerated / maxProfit).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: colors.background, shape: BoxShape.circle, border: Border.all(color: colors.border)),
            alignment: Alignment.center,
            child: Text(company.initials, style: AppTextStyles.badge(colors.textPrimary)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: Text(company.name, style: AppTextStyles.body(colors.textPrimary), overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      formatCurrency(company.profitGenerated),
                      style: AppTextStyles.body(colors.success).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: fraction),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: 10,
                      backgroundColor: colors.border,
                      valueColor: AlwaysStoppedAnimation(colors.success),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

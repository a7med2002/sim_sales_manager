import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/navigation/new_sale_launcher.dart';
import '../../../../core/navigation/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/cubit/theme_cubit.dart';
import '../../../../core/update/update_cubit.dart';
import '../../../../core/update/update_dialog.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/balance_progress_card.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/period_filter_row.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../domain/entities/company_balance.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/profit_trend_chart.dart';
import '../widgets/sales_profit_chart.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<HomeCubit>()),
        BlocProvider.value(value: getIt<UpdateCubit>()),
      ],
      child: const UpdateGate(child: _HomeView()),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  @override
  void initState() {
    super.initState();
    // `HomeCubit` is a `getIt` singleton that only loads once, at app
    // start — every navigation back to Home (New Sale confirm, adding a
    // company, etc. all `pushReplacementNamed` here) re-creates this
    // widget, so re-pulling here is what actually keeps stats/balance/
    // charts current instead of frozen at whatever existed on first
    // launch. `HomeCubit.refresh()` already existed for exactly this but
    // was never wired up to anything.
    context.read<HomeCubit>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal).copyWith(
                top: AppSpacing.md,
                bottom: AppSpacing.xl,
              ),
              children: [
                AppTopBar(
                  title: 'home.welcomeBack'.tr(namedArgs: {'name': state.userName}),
                  subtitle: 'home.tagline'.tr(),
                  showBrandMark: true,
                  isDarkMode: Theme.of(context).brightness == Brightness.dark,
                  onThemeToggle: () => context.read<ThemeCubit>().toggle(),
                ),
                const SizedBox(height: AppSpacing.md),
                PeriodFilterRow(
                  selectedPeriod: state.selectedPeriod,
                  customRange: state.customRange,
                  onPeriodSelected: context.read<HomeCubit>().selectPeriod,
                  onCustomRangeSelected: context.read<HomeCubit>().selectCustomRange,
                ),
                const SizedBox(height: AppSpacing.md),
                _StatsGrid(stats: state.stats),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'home.balanceSectionTitle'.tr(),
                  style: AppTextStyles.overline(colors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (state.companyBalances.isEmpty)
                  EmptyState(
                    icon: Icons.apartment_rounded,
                    title: 'home.emptyCompaniesTitle'.tr(),
                    description: 'home.emptyCompaniesDescription'.tr(),
                  )
                else
                  ...state.companyBalances.map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
                      child: BalanceProgressCard(
                        name: c.name,
                        initials: c.initials,
                        typeLabel: c.type.label,
                        usagePercent: c.usagePercent,
                        consumed: c.consumed,
                        availableToSell: c.availableToSell,
                        owedToCompany: c.owedToCompany,
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.sm),
                _SectionCard(
                  title: 'home.salesProfit'.tr(),
                  child: SalesProfitChart(data: state.salesProfitData),
                ),
                const SizedBox(height: AppSpacing.md),
                _SectionCard(
                  title: 'home.profitTrend'.tr(),
                  child: ProfitTrendChart(data: state.profitTrendData),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        current: AppNavTab.home,
        onTabSelected: (tab) {
          if (tab == AppNavTab.home) return;
          if (tab == AppNavTab.companies) {
            Navigator.of(context).pushReplacementNamed(RouteNames.companies);
            return;
          }
          if (tab == AppNavTab.customers) {
            Navigator.of(context).pushReplacementNamed(RouteNames.customers);
            return;
          }
          if (tab == AppNavTab.newSale) {
            NewSaleLauncher.open(context);
            return;
          }
          if (tab == AppNavTab.more) {
            Navigator.of(context).pushReplacementNamed(RouteNames.more);
            return;
          }
        },
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final DashboardStats stats;

  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.insights_rounded,
                iconColor: colors.textPrimary,
                title: 'home.stats.operations'.tr(),
                value: '${stats.operations}',
                onTap: () => Navigator.of(context).pushNamed(RouteNames.shipmentsOperations),
              ),
            ),
            const SizedBox(width: AppSpacing.cardGap),
            Expanded(
              child: StatCard(
                icon: Icons.apartment_rounded,
                iconColor: colors.textPrimary,
                title: 'home.stats.companies'.tr(),
                value: '${stats.companies}',
                onTap: () => Navigator.of(context).pushNamed(RouteNames.companies),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.cardGap),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.account_balance_wallet_outlined,
                iconColor: colors.warning,
                title: 'home.stats.totalSales'.tr(),
                value: formatCurrency(stats.totalSales),
                onTap: () => Navigator.of(context).pushNamed(RouteNames.reports),
              ),
            ),
            const SizedBox(width: AppSpacing.cardGap),
            Expanded(
              child: StatCard(
                icon: Icons.sim_card_outlined,
                iconColor: colors.textPrimary,
                title: 'home.stats.newLines'.tr(),
                value: '${stats.newLines}',
                onTap: () => Navigator.of(context).pushNamed(RouteNames.numbers),
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
                title: 'home.stats.uncollected'.tr(),
                value: formatCurrency(stats.uncollected),
                valueColor: stats.uncollected > 0 ? colors.danger : null,
                onTap: () => Navigator.of(context).pushNamed(RouteNames.customers),
              ),
            ),
            const SizedBox(width: AppSpacing.cardGap),
            Expanded(
              child: StatCard(
                icon: Icons.trending_up_rounded,
                iconColor: colors.success,
                title: 'home.stats.totalProfit'.tr(),
                value: formatCurrency(stats.totalProfit),
                valueColor: colors.success,
                onTap: () => Navigator.of(context).pushNamed(RouteNames.profits),
              ),
            ),
          ],
        ),
      ],
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
          Text(title, style: AppTextStyles.overline(colors.textPrimary)),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

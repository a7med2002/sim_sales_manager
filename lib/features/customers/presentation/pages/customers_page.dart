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
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/filter_pill.dart';
import '../../domain/entities/customer.dart';
import '../cubit/customers_cubit.dart';
import '../cubit/customers_state.dart';
import '../widgets/customer_card.dart';
import '../widgets/customer_form_sheet.dart';
import 'customer_detail_page.dart';

class CustomersPage extends StatelessWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<CustomersCubit>(),
      child: const _CustomersView(),
    );
  }
}

class _CustomersView extends StatelessWidget {
  const _CustomersView();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<CustomersCubit, CustomersState>(
          builder: (context, state) {
            final cubit = context.read<CustomersCubit>();
            final visible = state.visibleCustomers;

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal).copyWith(
                top: AppSpacing.md,
                bottom: AppSpacing.xl,
              ),
              children: [
                AppTopBar(
                  title: 'customers.title'.tr(),
                  subtitle: 'customers.activeCount'.tr(namedArgs: {'count': '${state.activeCount}'}),
                  isDarkMode: Theme.of(context).brightness == Brightness.dark,
                  onThemeToggle: () => context.read<ThemeCubit>().toggle(),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  onChanged: cubit.searchChanged,
                  style: AppTextStyles.cardTitle(colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'customers.searchHint'.tr(),
                    hintStyle: AppTextStyles.cardTitle(colors.textSecondary),
                    prefixIcon: Icon(Icons.search_rounded, color: colors.textSecondary, size: 20),
                    filled: true,
                    fillColor: colors.surface,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.button), borderSide: BorderSide(color: colors.border)),
                    enabledBorder:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.button), borderSide: BorderSide(color: colors.border)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.button),
                      borderSide: BorderSide(color: colors.primaryAction, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: _FilterDropdown<CustomerStatus?>(
                        label: state.statusFilter?.label ?? 'customers.statusLabel'.tr(),
                        value: state.statusFilter,
                        options: [null, ...CustomerStatus.values],
                        labelBuilder: (v) => v?.label ?? 'customers.allStatuses'.tr(),
                        onSelected: cubit.statusFilterChanged,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _FilterDropdown<String?>(
                        label: state.tagFilter ?? 'customers.tagsLabel'.tr(),
                        value: state.tagFilter,
                        options: [null, ...state.allTags],
                        labelBuilder: (v) => v ?? 'customers.allTags'.tr(),
                        onSelected: cubit.tagFilterChanged,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 40,
                  child: FilterPillRow(
                    labels: ['customers.tabs.active'.tr(), 'customers.tabs.debtors'.tr(), 'customers.tabs.deleted'.tr()],
                    selectedIndex: state.tab.index,
                    onSelected: (i) => cubit.selectTab(CustomersTab.values[i]),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (visible.isEmpty)
                  EmptyState(
                    icon: Icons.people_outline_rounded,
                    title: switch (state.tab) {
                      CustomersTab.active => 'customers.empty.activeTitle'.tr(),
                      CustomersTab.debtors => 'customers.empty.debtorsTitle'.tr(),
                      CustomersTab.deleted => 'customers.empty.deletedTitle'.tr(),
                    },
                    description: switch (state.tab) {
                      CustomersTab.active => 'customers.empty.activeDescription'.tr(),
                      CustomersTab.debtors => 'customers.empty.debtorsDescription'.tr(),
                      CustomersTab.deleted => 'customers.empty.deletedDescription'.tr(),
                    },
                  )
                else
                  ...visible.map(
                    (customer) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
                      child: CustomerCard(
                        customer: customer,
                        lineCount: state.linesFor(customer.id).length,
                        totalSpent: state.totalSpentFor(customer.id),
                        totalOwed: state.totalOwedFor(customer.id),
                        lastPurchase: state.lastPurchaseFor(customer.id),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: cubit,
                              child: CustomerDetailPage(customerId: customer.id),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => CustomerFormSheet.show(
          context,
          onSave: (name, contact, tags, status, pinned, notes) => context
              .read<CustomersCubit>()
              .addCustomer(name: name, contactNumber: contact, tags: tags, status: status, pinned: pinned, notes: notes),
        ),
        backgroundColor: colors.primaryAction,
        foregroundColor: colors.onPrimaryAction,
        icon: const Icon(Icons.add_rounded),
        label: Text('customers.newCustomer'.tr(), style: AppTextStyles.cardTitle(colors.onPrimaryAction)),
      ),
      bottomNavigationBar: BottomNavBar(
        current: AppNavTab.customers,
        onTabSelected: (tab) {
          if (tab == AppNavTab.customers) return;
          if (tab == AppNavTab.home) {
            Navigator.of(context).pushReplacementNamed(RouteNames.home);
            return;
          }
          if (tab == AppNavTab.companies) {
            Navigator.of(context).pushReplacementNamed(RouteNames.companies);
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

class _FilterDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> options;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onSelected;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.labelBuilder,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PopupMenuButton<T>(
      initialValue: value,
      color: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button), side: BorderSide(color: colors.border)),
      onSelected: onSelected,
      itemBuilder: (context) => options
          .map((o) => PopupMenuItem<T>(value: o, child: Text(labelBuilder(o), style: AppTextStyles.body(colors.textPrimary))))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadii.button),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Text(label, style: AppTextStyles.body(colors.textPrimary), overflow: TextOverflow.ellipsis)),
            Icon(Icons.keyboard_arrow_down_rounded, color: colors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

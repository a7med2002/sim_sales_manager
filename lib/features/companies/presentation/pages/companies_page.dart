import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/navigation/new_sale_launcher.dart';
import '../../../../core/navigation/route_names.dart';
import '../../../../core/theme/cubit/theme_cubit.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/filter_pill.dart';
import '../../domain/entities/company.dart';
import '../cubit/companies_cubit.dart';
import '../cubit/companies_state.dart';
import '../widgets/company_card.dart';
import '../widgets/company_form_sheet.dart';
import '../widgets/import_ready_made_sheet.dart';
import 'company_detail_page.dart';

class CompaniesPage extends StatelessWidget {
  const CompaniesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<CompaniesCubit>(),
      child: const _CompaniesView(),
    );
  }
}

class _CompaniesView extends StatelessWidget {
  const _CompaniesView();

  static const _tabs = [CompanyStatus.active, CompanyStatus.archived, CompanyStatus.deleted];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<CompaniesCubit, CompaniesState>(
          builder: (context, state) {
            final cubit = context.read<CompaniesCubit>();
            final visible = state.visibleCompanies;

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal).copyWith(
                top: AppSpacing.md,
                bottom: AppSpacing.xl,
              ),
              children: [
                AppTopBar(
                  title: 'companies.title'.tr(),
                  subtitle: 'companies.totalCount'.tr(namedArgs: {'count': '${state.totalCount}'}),
                  isDarkMode: Theme.of(context).brightness == Brightness.dark,
                  onThemeToggle: () => context.read<ThemeCubit>().toggle(),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    // A seller can always freely add/edit their own
                    // companies — "Import Ready-Made" (below) is just a
                    // convenience that copies from the shared catalog
                    // instead of typing everything by hand, not the only
                    // way to add one. See CompaniesCubit's doc comment.
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => CompanyFormSheet.show(
                          context,
                          onSave: (name, notes, packages) => cubit.addCompany(name: name, notes: notes, packages: packages),
                        ),
                        icon: Icon(Icons.add_rounded, color: colors.onPrimaryAction, size: 18),
                        label: Text('companies.addCompany'.tr(), style: AppTextStyles.body(colors.onPrimaryAction).copyWith(fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primaryAction,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button)),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final presets = await cubit.loadCatalogOptions();
                          if (!context.mounted) return;
                          ImportReadyMadeSheet.show(
                            context,
                            presets: presets,
                            currentCompanies: state.companies,
                            onImport: cubit.importPreset,
                          );
                        },
                        icon: Icon(Icons.auto_awesome_outlined, color: colors.textPrimary, size: 18),
                        label: Text('companies.importReadyMade'.tr(), style: AppTextStyles.body(colors.textPrimary).copyWith(fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.textPrimary,
                          side: BorderSide(color: colors.border),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 40,
                  child: FilterPillRow(
                    labels: ['companies.tabs.active', 'companies.tabs.archived', 'companies.tabs.deleted'].map((k) => k.tr()).toList(),
                    selectedIndex: _tabs.indexOf(state.selectedTab),
                    onSelected: (i) => cubit.selectTab(_tabs[i]),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (visible.isEmpty)
                  EmptyState(
                    icon: Icons.apartment_rounded,
                    title: _emptyTitleFor(state.selectedTab),
                    description: _emptyDescriptionFor(state.selectedTab),
                  )
                else
                  ...visible.map(
                    (company) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
                      child: CompanyCard(
                        company: company,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: cubit,
                              child: CompanyDetailPage(companyId: company.id),
                            ),
                          ),
                        ),
                        onEdit: () => CompanyFormSheet.show(
                          context,
                          company: company,
                          onSave: (name, notes, packages) =>
                              cubit.updateCompany(company.id, name: name, notes: notes, packages: packages),
                        ),
                        onTogglePin: () => cubit.togglePin(company.id),
                        onArchive: () => cubit.archive(company.id),
                        onRestore: () => cubit.restoreToActive(company.id),
                        onDelete: () => showConfirmDialog(
                          context,
                          title: 'companies.deleteDialog.title'.tr(namedArgs: {'name': company.name}),
                          message: 'companies.deleteDialog.message'.tr(),
                          confirmLabel: 'companies.deleteDialog.confirm'.tr(),
                          onConfirm: () => cubit.softDelete(company.id),
                        ),
                        onPermanentlyDelete: () => showConfirmDialog(
                          context,
                          title: 'companies.deletePermanentDialog.title'.tr(namedArgs: {'name': company.name}),
                          message: 'companies.deletePermanentDialog.message'.tr(),
                          confirmLabel: 'companies.deletePermanentDialog.confirm'.tr(),
                          onConfirm: () => cubit.permanentlyDelete(company.id),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        current: AppNavTab.companies,
        onTabSelected: (tab) {
          if (tab == AppNavTab.companies) return;
          if (tab == AppNavTab.home) {
            Navigator.of(context).pushReplacementNamed(RouteNames.home);
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

  String _emptyTitleFor(CompanyStatus status) {
    switch (status) {
      case CompanyStatus.active:
        return 'companies.empty.activeTitle'.tr();
      case CompanyStatus.archived:
        return 'companies.empty.archivedTitle'.tr();
      case CompanyStatus.deleted:
        return 'companies.empty.deletedTitle'.tr();
    }
  }

  String _emptyDescriptionFor(CompanyStatus status) {
    switch (status) {
      case CompanyStatus.active:
        return 'companies.empty.activeDescription'.tr();
      case CompanyStatus.archived:
        return 'companies.empty.archivedDescription'.tr();
      case CompanyStatus.deleted:
        return 'companies.empty.deletedDescription'.tr();
    }
  }
}

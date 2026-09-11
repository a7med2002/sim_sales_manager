import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/logo_avatar.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/catalog_company_admin.dart';
import '../cubit/admin_company_catalog_cubit.dart';
import '../widgets/catalog_company_form_sheet.dart';

/// Admin → Company Catalog: list/add/edit/archive the shared templates
/// "Import Ready-Made" reads from. See `AdminCompanyCatalogCubit`'s doc
/// comment for why this reads/writes Supabase directly, no Drift.
class AdminCompanyCatalogPage extends StatelessWidget {
  const AdminCompanyCatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminCompanyCatalogCubit(),
      child: const _AdminCompanyCatalogView(),
    );
  }
}

class _AdminCompanyCatalogView extends StatelessWidget {
  const _AdminCompanyCatalogView();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocBuilder<AdminCompanyCatalogCubit, AdminCompanyCatalogState>(
      builder: (context, state) {
        final cubit = context.read<AdminCompanyCatalogCubit>();

        return Scaffold(
          backgroundColor: colors.background,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => CatalogCompanyFormSheet.show(
              context,
              onSave: (name, notes, url, provider, logoLocalPath, removeLogo, packages) => cubit.addCompany(
                name: name,
                notes: notes,
                numberUpdateUrl: url,
                numberUpdateProvider: provider,
                logoLocalPath: logoLocalPath,
                packages: packages,
              ),
            ),
            backgroundColor: colors.primaryAction,
            foregroundColor: colors.onPrimaryAction,
            icon: const Icon(Icons.add_rounded),
            label: Text('admin.catalog.addCompany'.tr(), style: AppTextStyles.cardTitle(colors.onPrimaryAction)),
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: cubit.load,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal).copyWith(
                  top: AppSpacing.md,
                  bottom: AppSpacing.xl,
                ),
                children: [
                  AppTopBar(title: 'admin.catalog.title'.tr(), subtitle: 'admin.catalog.subtitle'.tr(), showBack: true),
                  const SizedBox(height: AppSpacing.md),
                  if (state.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Text(state.errorMessage!.tr(), style: AppTextStyles.body(colors.danger)),
                    ),
                  if (state.isLoading && state.companies.isEmpty)
                    const Padding(padding: EdgeInsets.symmetric(vertical: AppSpacing.xl), child: Center(child: CircularProgressIndicator()))
                  else if (state.companies.isEmpty)
                    EmptyState(
                      icon: Icons.apartment_rounded,
                      title: 'admin.catalog.emptyTitle'.tr(),
                      description: 'admin.catalog.emptyDescription'.tr(),
                    )
                  else
                    ...state.companies.map(
                      (company) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
                        child: _CatalogCompanyCard(company: company, cubit: cubit),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CatalogCompanyCard extends StatelessWidget {
  final CatalogCompanyAdmin company;
  final AdminCompanyCatalogCubit cubit;

  const _CatalogCompanyCard({required this.company, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isArchived = company.status == CatalogStatus.archived;

    return Container(
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
              LogoAvatar(initials: _initialsFor(company.name), logoUrl: company.logoUrl),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(child: Text(company.name, style: AppTextStyles.cardTitle(colors.textPrimary))),
                        const SizedBox(width: AppSpacing.xs),
                        if (isArchived) StatusBadge(label: 'admin.catalog.archived'.tr(), type: StatusBadgeType.neutral),
                      ],
                    ),
                    Text(
                      'admin.catalog.packagesCount'.tr(namedArgs: {'count': '${company.packages.length}'}),
                      style: AppTextStyles.body(colors.textSecondary),
                    ),
                    if (company.numberUpdateUrl.isNotEmpty)
                      Text(company.numberUpdateUrl, style: AppTextStyles.body(colors.textSecondary), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              PopupMenuButton<VoidCallback>(
                icon: Icon(Icons.more_vert_rounded, color: colors.textSecondary, size: 20),
                padding: EdgeInsets.zero,
                color: colors.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button), side: BorderSide(color: colors.border)),
                onSelected: (action) => action(),
                itemBuilder: (context) => [
                  PopupMenuItem<VoidCallback>(
                    value: () => CatalogCompanyFormSheet.show(
                      context,
                      company: company,
                      onSave: (name, notes, url, provider, logoLocalPath, removeLogo, packages) => cubit.updateCompany(
                        company.id,
                        name: name,
                        notes: notes,
                        numberUpdateUrl: url,
                        numberUpdateProvider: provider,
                        logoLocalPath: logoLocalPath,
                        removeLogo: removeLogo,
                        packages: packages,
                      ),
                    ),
                    child: Row(children: [
                      Icon(Icons.edit_outlined, size: 18, color: colors.textPrimary),
                      const SizedBox(width: AppSpacing.sm),
                      Text('admin.catalog.edit'.tr(), style: AppTextStyles.body(colors.textPrimary)),
                    ]),
                  ),
                  PopupMenuItem<VoidCallback>(
                    value: () => cubit.setStatus(company.id, isArchived ? CatalogStatus.active : CatalogStatus.archived),
                    child: Row(children: [
                      Icon(isArchived ? Icons.unarchive_outlined : Icons.archive_outlined, size: 18, color: colors.textPrimary),
                      const SizedBox(width: AppSpacing.sm),
                      Text(isArchived ? 'admin.catalog.restore'.tr() : 'admin.catalog.archive'.tr(), style: AppTextStyles.body(colors.textPrimary)),
                    ]),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _initialsFor(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return (words.first.substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
  }
}

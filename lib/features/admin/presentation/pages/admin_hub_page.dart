import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/navigation/logout.dart';
import '../../../../core/navigation/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/cubit/theme_cubit.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../domain/entities/admin_user.dart';
import '../cubit/admin_dashboard_cubit.dart';

/// Admin's own home — an admin account never sees the seller shell
/// (Home/Companies/Customers/New Sale/More) at all: `main.dart`'s
/// startup check and `LoginCubit` both route straight here instead of
/// `HomePage` once `profiles.role == 'admin'` is confirmed. An admin
/// manages the platform, not a seller's own sales — showing them the
/// seller UI "plus an Admin section" made the two roles feel muddled,
/// so they're now fully separate app experiences sharing one codebase
/// (still gated by real RLS server-side, same as before — this is a UX
/// split, not a security one). Root page: no back arrow, theme toggle +
/// logout live directly in the top bar (there's no "More" to reach them
/// from here). See `AdminDashboardCubit`'s doc comment for exactly what
/// data this can and can't show.
class AdminHubPage extends StatelessWidget {
  const AdminHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminDashboardCubit(),
      child: const _AdminHubView(),
    );
  }
}

class _AdminHubView extends StatelessWidget {
  const _AdminHubView();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: BlocBuilder<AdminDashboardCubit, AdminDashboardState>(
          builder: (context, state) {
            final cubit = context.read<AdminDashboardCubit>();

            return RefreshIndicator(
              onRefresh: cubit.load,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal).copyWith(
                  top: AppSpacing.md,
                  bottom: AppSpacing.xl,
                ),
                children: [
                  AppTopBar(
                    title: 'admin.hub.title'.tr(),
                    subtitle: 'admin.hub.subtitle'.tr(),
                    isDarkMode: Theme.of(context).brightness == Brightness.dark,
                    onThemeToggle: () => context.read<ThemeCubit>().toggle(),
                    actions: [
                      const SizedBox(width: 4),
                      _LogoutButton(onTap: () => confirmLogout(context)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (state.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Text(state.errorMessage!, style: AppTextStyles.body(colors.danger)),
                    ),
                  if (state.isLoading)
                    const Padding(padding: EdgeInsets.symmetric(vertical: AppSpacing.xl), child: Center(child: CircularProgressIndicator()))
                  else ...[
                    Text('admin.dashboard.overviewSection'.tr(), style: AppTextStyles.overline(colors.textSecondary)),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            icon: Icons.people_outline_rounded,
                            iconColor: colors.primaryAction,
                            title: 'admin.dashboard.totalSellers'.tr(),
                            value: '${state.totalSellers}',
                            caption: 'admin.dashboard.activeCaption'.tr(namedArgs: {'count': '${state.activeSellers}'}),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.cardGap),
                        Expanded(
                          child: StatCard(
                            icon: Icons.person_off_outlined,
                            iconColor: colors.danger,
                            title: 'admin.dashboard.inactiveSellers'.tr(),
                            value: '${state.inactiveSellers}',
                            valueColor: state.inactiveSellers > 0 ? colors.danger : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.cardGap),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            icon: Icons.apartment_rounded,
                            iconColor: colors.success,
                            title: 'admin.dashboard.catalogCompanies'.tr(),
                            value: '${state.catalogCompaniesActive}',
                            caption: state.catalogCompaniesArchived > 0
                                ? 'admin.dashboard.archivedCaption'.tr(namedArgs: {'count': '${state.catalogCompaniesArchived}'})
                                : null,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.cardGap),
                        Expanded(
                          child: StatCard(
                            icon: Icons.inventory_2_outlined,
                            iconColor: colors.warning,
                            title: 'admin.dashboard.catalogPackages'.tr(),
                            value: '${state.catalogPackages}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.cardGap),
                    StatCard(
                      icon: Icons.headset_mic_outlined,
                      iconColor: colors.primaryAction,
                      title: 'admin.dashboard.supportRequests'.tr(),
                      value: '${state.totalSupportRequests}',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('admin.dashboard.recentSignupsSection'.tr(), style: AppTextStyles.overline(colors.textSecondary)),
                    const SizedBox(height: AppSpacing.sm),
                    if (state.recentSignups.isEmpty)
                      _EmptyRow(text: 'admin.dashboard.noSignups'.tr())
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(AppRadii.card),
                          border: Border.all(color: colors.border),
                        ),
                        child: Column(
                          children: [
                            for (var i = 0; i < state.recentSignups.length; i++) ...[
                              if (i > 0) Container(height: 1, color: colors.border),
                              _SignupRow(user: state.recentSignups[i]),
                            ],
                          ],
                        ),
                      ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  Text('admin.dashboard.manageSection'.tr(), style: AppTextStyles.overline(colors.textSecondary)),
                  const SizedBox(height: AppSpacing.sm),
                  _AdminSectionCard(
                    icon: Icons.apartment_rounded,
                    title: 'admin.hub.companyCatalog'.tr(),
                    subtitle: 'admin.hub.companyCatalogDescription'.tr(),
                    onTap: () => Navigator.of(context).pushNamed(RouteNames.adminCompanyCatalog),
                  ),
                  const SizedBox(height: AppSpacing.cardGap),
                  _AdminSectionCard(
                    icon: Icons.people_outline_rounded,
                    title: 'admin.hub.users'.tr(),
                    subtitle: 'admin.hub.usersDescription'.tr(),
                    onTap: () => Navigator.of(context).pushNamed(RouteNames.adminUsers),
                  ),
                  const SizedBox(height: AppSpacing.cardGap),
                  _AdminSectionCard(
                    icon: Icons.headset_mic_outlined,
                    title: 'admin.hub.supportFeedback'.tr(),
                    subtitle: 'admin.hub.supportFeedbackDescription'.tr(),
                    onTap: () => Navigator.of(context).pushNamed(RouteNames.adminSupportFeedback),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SignupRow extends StatelessWidget {
  final AdminUser user;

  const _SignupRow({required this.user});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.cardPadding, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName.isEmpty ? user.email : user.displayName,
                  style: AppTextStyles.cardTitle(colors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  user.role == AppRole.admin
                      ? 'admin.users.roleAdmin'.tr()
                      : 'admin.users.roleSeller'.tr(),
                  style: AppTextStyles.body(colors.textSecondary),
                ),
              ],
            ),
          ),
          Text(formatDate(user.createdAt), style: AppTextStyles.body(colors.textSecondary)),
        ],
      ),
    );
  }
}

class _AdminSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AdminSectionCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
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
              decoration: BoxDecoration(color: colors.primaryAction.withValues(alpha: 0.1), shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Icon(icon, color: colors.primaryAction, size: 20),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.cardTitle(colors.textPrimary)),
                  Text(subtitle, style: AppTextStyles.body(colors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _EmptyRow extends StatelessWidget {
  final String text;

  const _EmptyRow({required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: colors.border),
      ),
      child: Text(text, style: AppTextStyles.body(colors.textSecondary)),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: colors.border)),
        child: Icon(Icons.logout_rounded, color: colors.danger, size: 18),
      ),
    );
  }
}

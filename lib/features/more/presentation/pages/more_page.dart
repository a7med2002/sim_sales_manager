import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/navigation/logout.dart';
import '../../../../core/navigation/new_sale_launcher.dart';
import '../../../../core/navigation/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/cubit/theme_cubit.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../core/widgets/list_row.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';

/// More landing page: profile card + the 9 sub-page menu rows + Logout.
/// Matches design/screenshots/more.png (the original 8 rows) plus Number
/// Update, added later per design/screenshots/numbers update.png.
class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<ProfileCubit>(),
      child: const _MoreView(),
    );
  }
}

class _MoreView extends StatelessWidget {
  const _MoreView();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<ProfileCubit, Profile>(
          builder: (context, profile) {
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal).copyWith(
                top: AppSpacing.md,
                bottom: AppSpacing.xl,
              ),
              children: [
                AppTopBar(
                  title: 'more.title'.tr(),
                  isDarkMode: Theme.of(context).brightness == Brightness.dark,
                  onThemeToggle: () => context.read<ThemeCubit>().toggle(),
                ),
                const SizedBox(height: AppSpacing.md),
                _ProfileCard(profile: profile),
                const SizedBox(height: AppSpacing.md),
                Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AppRadii.card),
                    border: Border.all(color: colors.border),
                  ),
                  child: Column(
                    children: [
                      ListRow(
                        icon: Icons.local_shipping_outlined,
                        title: 'more.shipmentsOperations'.tr(),
                        onTap: () => Navigator.of(context).pushNamed(RouteNames.shipmentsOperations),
                      ),
                      _divider(colors),
                      ListRow(
                        icon: Icons.tag_outlined,
                        title: 'more.numbers'.tr(),
                        onTap: () => Navigator.of(context).pushNamed(RouteNames.numbers),
                      ),
                      _divider(colors),
                      ListRow(
                        icon: Icons.sync_rounded,
                        title: 'more.numberUpdate'.tr(),
                        onTap: () => Navigator.of(context).pushNamed(RouteNames.numberUpdate),
                      ),
                      _divider(colors),
                      ListRow(
                        icon: Icons.trending_up_rounded,
                        title: 'more.profits'.tr(),
                        onTap: () => Navigator.of(context).pushNamed(RouteNames.profits),
                      ),
                      _divider(colors),
                      ListRow(
                        icon: Icons.description_outlined,
                        title: 'more.reports'.tr(),
                        onTap: () => Navigator.of(context).pushNamed(RouteNames.reports),
                      ),
                      _divider(colors),
                      ListRow(
                        icon: Icons.headset_mic_outlined,
                        title: 'more.supportFeedback'.tr(),
                        onTap: () => Navigator.of(context).pushNamed(RouteNames.supportFeedback),
                      ),
                      _divider(colors),
                      ListRow(
                        icon: Icons.phone_iphone_outlined,
                        title: 'more.trustedDevices'.tr(),
                        onTap: () => Navigator.of(context).pushNamed(RouteNames.trustedDevices),
                      ),
                      _divider(colors),
                      ListRow(
                        icon: Icons.show_chart_rounded,
                        title: 'more.activityLog'.tr(),
                        onTap: () => Navigator.of(context).pushNamed(RouteNames.activityLog),
                      ),
                      _divider(colors),
                      ListRow(
                        icon: Icons.settings_outlined,
                        title: 'more.settings'.tr(),
                        onTap: () => Navigator.of(context).pushNamed(RouteNames.settings),
                      ),
                      _divider(colors),
                      ListRow(
                        icon: Icons.logout_rounded,
                        title: 'more.logout'.tr(),
                        iconColor: colors.danger,
                        titleColor: colors.danger,
                        showChevron: false,
                        onTap: () => confirmLogout(context),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        current: AppNavTab.more,
        onTabSelected: (tab) {
          if (tab == AppNavTab.more) return;
          if (tab == AppNavTab.home) {
            Navigator.of(context).pushReplacementNamed(RouteNames.home);
            return;
          }
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
        },
      ),
    );
  }

  Widget _divider(AppColors colors) => Container(height: 1, color: colors.border);
}

class _ProfileCard extends StatelessWidget {
  final Profile profile;

  const _ProfileCard({required this.profile});

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
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: colors.background, shape: BoxShape.circle, border: Border.all(color: colors.border)),
            alignment: Alignment.center,
            child: Text(_initialsFor(profile.name), style: AppTextStyles.cardTitle(colors.textPrimary)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.name, style: AppTextStyles.cardTitle(colors.textPrimary)),
                Text(profile.email, style: AppTextStyles.body(colors.textSecondary)),
              ],
            ),
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

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/auth_service.dart';
import '../../../../core/config/env.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/admin_user.dart';
import '../cubit/admin_users_cubit.dart';
import '../widgets/add_user_sheet.dart';

/// Admin → Users: list every seller/admin account and manage them
/// through `admin-manage-user` — see `AdminUsersCubit`'s doc comment.
class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminUsersCubit(auth: getIt<AuthService>()),
      child: const _AdminUsersView(),
    );
  }
}

class _AdminUsersView extends StatelessWidget {
  const _AdminUsersView();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: BlocBuilder<AdminUsersCubit, AdminUsersState>(
          builder: (context, state) {
            final cubit = context.read<AdminUsersCubit>();
            final currentUserId = Env.isConfigured ? getIt<AuthService>().currentOwnerId : null;

            return RefreshIndicator(
              onRefresh: cubit.load,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal).copyWith(
                  top: AppSpacing.md,
                  bottom: AppSpacing.xl,
                ),
                children: [
                  AppTopBar(title: 'admin.users.title'.tr(), subtitle: 'admin.users.subtitle'.tr(), showBack: true),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => AddUserSheet.show(
                        context,
                        onSave: (email, password, name) => cubit.createUser(email: email, password: password, displayName: name),
                      ),
                      icon: Icon(Icons.person_add_alt_1_rounded, color: colors.onPrimaryAction, size: 18),
                      label: Text('admin.users.addUser'.tr(), style: AppTextStyles.cardTitle(colors.onPrimaryAction)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primaryAction,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (state.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Text(state.errorMessage!, style: AppTextStyles.body(colors.danger)),
                    ),
                  if (state.isLoading && state.users.isEmpty)
                    const Padding(padding: EdgeInsets.symmetric(vertical: AppSpacing.xl), child: Center(child: CircularProgressIndicator()))
                  else if (state.users.isEmpty)
                    EmptyState(icon: Icons.people_outline_rounded, title: 'admin.users.emptyTitle'.tr(), description: 'admin.users.emptyDescription'.tr())
                  else
                    ...state.users.map(
                      (user) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
                        child: _UserCard(user: user, cubit: cubit, isSelf: user.id == currentUserId),
                      ),
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

class _UserCard extends StatelessWidget {
  final AdminUser user;
  final AdminUsersCubit cubit;
  final bool isSelf;

  const _UserCard({required this.user, required this.cubit, required this.isSelf});

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.displayName.isEmpty ? user.email : user.displayName,
                        style: AppTextStyles.cardTitle(colors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    StatusBadge(
                      label: user.role == AppRole.admin ? 'admin.users.roleAdmin'.tr() : 'admin.users.roleSeller'.tr(),
                      type: user.role == AppRole.admin ? StatusBadgeType.warning : StatusBadgeType.neutral,
                    ),
                    if (!user.isActive) ...[
                      const SizedBox(width: 4),
                      StatusBadge(label: 'admin.users.inactive'.tr(), type: StatusBadgeType.danger),
                    ],
                  ],
                ),
                Text(user.email, style: AppTextStyles.body(colors.textSecondary)),
              ],
            ),
          ),
          if (!isSelf)
            PopupMenuButton<VoidCallback>(
              icon: Icon(Icons.more_vert_rounded, color: colors.textSecondary, size: 20),
              padding: EdgeInsets.zero,
              color: colors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button), side: BorderSide(color: colors.border)),
              onSelected: (action) => action(),
              itemBuilder: (context) => [
                PopupMenuItem<VoidCallback>(
                  value: () => cubit.setActive(user.id, !user.isActive),
                  child: Row(children: [
                    Icon(user.isActive ? Icons.block_outlined : Icons.check_circle_outline_rounded, size: 18, color: colors.textPrimary),
                    const SizedBox(width: AppSpacing.sm),
                    Text(user.isActive ? 'admin.users.deactivate'.tr() : 'admin.users.activate'.tr(), style: AppTextStyles.body(colors.textPrimary)),
                  ]),
                ),
                PopupMenuItem<VoidCallback>(
                  value: () => cubit.setRole(user.id, user.role == AppRole.admin ? AppRole.seller : AppRole.admin),
                  child: Row(children: [
                    Icon(Icons.admin_panel_settings_outlined, size: 18, color: colors.textPrimary),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      user.role == AppRole.admin ? 'admin.users.demote'.tr() : 'admin.users.promote'.tr(),
                      style: AppTextStyles.body(colors.textPrimary),
                    ),
                  ]),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

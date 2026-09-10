import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/navigation/route_names.dart';
import '../../../../core/notifications/app_notification.dart';
import '../../../../core/notifications/notification_type.dart';
import '../../../../core/notifications/notifications_cubit.dart';
import '../../../../core/notifications/notifications_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/empty_state.dart';

/// Notifications inbox — every row from the local `notifications` table
/// (see `NotificationsCubit`'s doc comment), newest first: past reminders
/// that already fired, and still-pending future ones. Tapping a row marks
/// it read and, for the types tied to a specific customer/company, jumps
/// to that list page (the customer-debt/company-balance/company-owed
/// ones — line reminders don't carry a customer id to navigate to).
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<NotificationsCubit>(),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            final cubit = context.read<NotificationsCubit>();
            final items = state.sortedByNewest;

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal).copyWith(
                top: AppSpacing.md,
                bottom: AppSpacing.xl,
              ),
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text('notifications.title'.tr(), style: AppTextStyles.pageTitle(colors.textPrimary)),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (items.isEmpty)
                  EmptyState(
                    icon: Icons.notifications_none_rounded,
                    title: 'notifications.emptyTitle'.tr(),
                    description: 'notifications.emptyDescription'.tr(),
                  )
                else
                  ...items.map((n) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _NotificationTile(notification: n, onTap: () => _handleTap(context, cubit, n)),
                      )),
              ],
            );
          },
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, NotificationsCubit cubit, AppNotification n) {
    cubit.markRead(n.id);
    switch (n.type) {
      case NotificationType.customerDebtReminder:
        Navigator.of(context).pushNamed(RouteNames.customers);
      case NotificationType.companyLowBalance:
      case NotificationType.companyOwedAlert:
        Navigator.of(context).pushNamed(RouteNames.companies);
      case NotificationType.lineExpiringSoon:
      case NotificationType.lineExpired:
        break;
    }
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  IconData get _icon {
    switch (notification.type) {
      case NotificationType.lineExpiringSoon:
      case NotificationType.lineExpired:
        return Icons.sim_card_outlined;
      case NotificationType.customerDebtReminder:
        return Icons.person_outline_rounded;
      case NotificationType.companyLowBalance:
      case NotificationType.companyOwedAlert:
        return Icons.apartment_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final unread = !notification.read && !notification.isPending;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: unread ? colors.primaryAction.withValues(alpha: 0.05) : colors.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: unread ? colors.primaryAction.withValues(alpha: 0.3) : colors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: colors.background, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Icon(_icon, size: 18, color: colors.textPrimary),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.title, style: AppTextStyles.cardTitle(colors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(notification.body, style: AppTextStyles.body(colors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(
                    notification.isPending
                        ? 'notifications.pendingLabel'.tr(namedArgs: {'date': formatDateTime(notification.fireAt)})
                        : formatDateTime(notification.fireAt),
                    style: AppTextStyles.body(colors.textSecondary).copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            if (unread) Container(width: 8, height: 8, margin: const EdgeInsets.only(top: 4), decoration: BoxDecoration(color: colors.primaryAction, shape: BoxShape.circle)),
          ],
        ),
      ),
    );
  }
}

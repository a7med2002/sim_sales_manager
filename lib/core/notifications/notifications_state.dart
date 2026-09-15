import 'package:equatable/equatable.dart';

import 'app_notification.dart';

class NotificationsState extends Equatable {
  final List<AppNotification> notifications;

  const NotificationsState({this.notifications = const []});

  /// The inbox list — deliberately excludes anything still pending
  /// (`fireAt` in the future): a notification whose title/body says
  /// "expires today" or "3 days left" is only true at the moment it
  /// actually fires, so showing it ahead of time (labelled "scheduled
  /// for `future date`") reads as contradictory, not as a preview. This
  /// mirrors how a real OS notification tray works — nothing appears
  /// until it actually happens. `NotificationsCubit.pendingDebtReminder`
  /// still reads the raw `notifications` list directly, so a still-future
  /// debt reminder stays fully trackable from the customer detail page;
  /// it's only hidden from this general inbox.
  List<AppNotification> get sortedByNewest =>
      notifications.where((n) => !n.isPending).toList()..sort((a, b) => b.fireAt.compareTo(a.fireAt));

  /// Only counts ones that have actually fired — a still-pending future
  /// reminder hasn't "happened" yet, so it shouldn't inflate the badge.
  int get unreadCount => notifications.where((n) => !n.read && !n.isPending).length;

  NotificationsState copyWith({List<AppNotification>? notifications}) {
    return NotificationsState(notifications: notifications ?? this.notifications);
  }

  @override
  List<Object?> get props => [notifications];
}

import 'package:equatable/equatable.dart';

import 'app_notification.dart';

class NotificationsState extends Equatable {
  final List<AppNotification> notifications;

  const NotificationsState({this.notifications = const []});

  List<AppNotification> get sortedByNewest => [...notifications]..sort((a, b) => b.fireAt.compareTo(a.fireAt));

  /// Only counts ones that have actually fired — a still-pending future
  /// reminder hasn't "happened" yet, so it shouldn't inflate the badge.
  int get unreadCount => notifications.where((n) => !n.read && !n.isPending).length;

  NotificationsState copyWith({List<AppNotification>? notifications}) {
    return NotificationsState(notifications: notifications ?? this.notifications);
  }

  @override
  List<Object?> get props => [notifications];
}

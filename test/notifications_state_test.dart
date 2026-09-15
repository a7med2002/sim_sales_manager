import 'package:flutter_test/flutter_test.dart';

import 'package:sim_sales_manager/core/notifications/app_notification.dart';
import 'package:sim_sales_manager/core/notifications/notification_type.dart';
import 'package:sim_sales_manager/core/notifications/notifications_state.dart';

/// Pure-Dart tests for the inbox filtering/sorting rule behind the
/// "Notifications" page: reproduces the field report that scheduling a
/// reminder made it show up immediately in the inbox, labelled
/// "scheduled for `future date`" while its own body text said things
/// like "expires today" — a still-pending notification hasn't actually
/// happened yet, so `sortedByNewest` must hide it until its fireAt
/// passes, exactly like a real OS notification tray.
void main() {
  AppNotification make({required String id, required DateTime fireAt, bool read = false}) {
    return AppNotification(
      id: id,
      type: NotificationType.lineExpiringSoon,
      title: 'title',
      body: 'body',
      fireAt: fireAt,
      read: read,
    );
  }

  test('sortedByNewest excludes still-pending (future) notifications entirely', () {
    final now = DateTime.now();
    final state = NotificationsState(notifications: [
      make(id: 'future', fireAt: now.add(const Duration(days: 3))),
      make(id: 'past', fireAt: now.subtract(const Duration(days: 1))),
    ]);

    final ids = state.sortedByNewest.map((n) => n.id);
    expect(ids, ['past']);
    expect(ids, isNot(contains('future')));
  });

  test('sortedByNewest orders already-fired notifications newest-first', () {
    final now = DateTime.now();
    final state = NotificationsState(notifications: [
      make(id: 'oldest', fireAt: now.subtract(const Duration(days: 5))),
      make(id: 'newest', fireAt: now.subtract(const Duration(hours: 1))),
      make(id: 'middle', fireAt: now.subtract(const Duration(days: 2))),
    ]);

    expect(state.sortedByNewest.map((n) => n.id), ['newest', 'middle', 'oldest']);
  });

  test('unreadCount only counts already-fired, unread notifications', () {
    final now = DateTime.now();
    final state = NotificationsState(notifications: [
      make(id: 'unread-fired', fireAt: now.subtract(const Duration(hours: 1))),
      make(id: 'read-fired', fireAt: now.subtract(const Duration(hours: 2)), read: true),
      make(id: 'unread-pending', fireAt: now.add(const Duration(days: 1))),
    ]);

    expect(state.unreadCount, 1);
  });
}

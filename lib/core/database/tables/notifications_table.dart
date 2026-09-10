import 'package:drift/drift.dart';

import 'tenant_columns.dart';

/// One row per notification — the single source of truth for both the
/// in-app "Notifications" inbox (every row, past and future, newest
/// first) and for what's currently scheduled at the OS level: whenever
/// [fireAt] is still in the future, `NotificationsCubit` has (or, on the
/// next app open, re-arms) a matching `flutter_local_notifications`
/// alarm for [osNotificationId] — Android's own AlarmManager delivers it
/// even if the app isn't running. Backed up to Supabase like every other
/// tenant table (`SyncEngine.pushPendingNotifications`/`pullNotifications`,
/// `supabase/migrations/0015_notifications.sql`) — clearing the app's
/// local storage (or reinstalling) wipes both this table and every OS
/// alarm it had armed, so without a remote copy a still-future reminder
/// would just be gone; syncing it back down on the next sign-in lets
/// `NotificationsCubit` re-arm it. [osNotificationId] is a pure function
/// of [id] (see `notification_id.dart`), so it comes back identical
/// after a reinstall and re-scheduling by it is safe.
class NotificationsTable extends Table with TenantColumns {
  @override
  String get tableName => 'notifications';

  TextColumn get id => text()();

  /// A stable, deterministic int derived from [id] (see
  /// `core/notifications/notification_id.dart`) — `flutter_local_notifications`
  /// schedules/cancels by int id, not by our own string [id].
  IntColumn get osNotificationId => integer()();

  /// One of `NotificationType`'s enum names (`core/notifications/notification_type.dart`).
  TextColumn get type => text()();
  TextColumn get title => text()();
  TextColumn get body => text()();

  /// What this notification is about, if anything — lets tapping it (or
  /// cancelling it when the underlying situation resolves, e.g. a debt
  /// getting paid off) jump straight back to the right row without
  /// re-deriving it from [type]. Free-form on purpose (a customer id, a
  /// line id, a company id, ...) — the inbox UI dispatches on [type] to
  /// know how to interpret it.
  TextColumn get relatedEntityId => text().nullable()();

  DateTimeColumn get fireAt => dateTime()();
  BoolColumn get read => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sim_sales_manager/core/auth/auth_service.dart';
import 'package:sim_sales_manager/core/database/app_database.dart';
import 'package:sim_sales_manager/core/notifications/notification_scheduler.dart';
import 'package:sim_sales_manager/core/notifications/notification_type.dart';
import 'package:sim_sales_manager/core/notifications/notifications_cubit.dart';

/// Never actually constructed against a real Supabase project — just
/// needs a `SupabaseClient` to satisfy `AuthService`'s constructor.
/// `currentOwnerId` is the only member `NotificationsCubit` reads.
class _FakeAuthService extends AuthService {
  _FakeAuthService(this._ownerId) : super(SupabaseClient('https://example.supabase.co', 'anon-key'));

  final String? _ownerId;

  @override
  String? get currentOwnerId => _ownerId;
}

/// Records every call instead of touching `flutter_local_notifications`
/// (which needs a real platform channel and would hang/crash under
/// `flutter test`).
class _FakeScheduler extends NotificationScheduler {
  final List<({int id, String title, String body, DateTime at})> scheduled = [];
  final List<({int id, String title, String body})> shownNow = [];
  final List<int> cancelled = [];

  /// Simulates a real-device native-plugin failure (missing notification
  /// permission, OEM alarm restrictions, etc.) that the in-memory test
  /// double otherwise never reproduces — used to prove the cubit's state
  /// still reflects the database even when this throws.
  bool failNextCall = false;

  void _maybeFail() {
    if (failNextCall) {
      failNextCall = false;
      throw Exception('simulated native plugin failure');
    }
  }

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> scheduleAt({required int id, required String title, required String body, required DateTime at}) async {
    _maybeFail();
    scheduled.add((id: id, title: title, body: body, at: at));
  }

  @override
  Future<void> showNow({required int id, required String title, required String body}) async {
    _maybeFail();
    shownNow.add((id: id, title: title, body: body));
  }

  @override
  Future<void> cancel(int id) async {
    _maybeFail();
    cancelled.add(id);
  }
}

void main() {
  const ownerId = 'seller-1';

  late AppDatabase db;
  late _FakeScheduler scheduler;
  late NotificationsCubit cubit;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    scheduler = _FakeScheduler();
    cubit = NotificationsCubit(db: db, auth: _FakeAuthService(ownerId), syncEngine: null, scheduler: scheduler);
    // The constructor's _init() runs unawaited; give it a beat to settle
    // (it only awaits scheduler.init()/requestPermission() and a couple
    // of in-memory Drift queries here — both fast and synchronous-ish
    // fakes/local calls, no real I/O).
    await Future<void>.delayed(Duration.zero);
  });

  tearDown(() async {
    await cubit.close();
    await db.close();
  });

  group('customer debt reminder', () {
    test('scheduleDebtReminder inserts a row, arms one OS alarm, and is reported as pending', () async {
      await cubit.scheduleDebtReminder(customerId: 'cust-1', customerName: 'Mahmoud', amountOwed: 120, days: 2);

      expect(scheduler.scheduled, hasLength(1));
      expect(scheduler.scheduled.single.at.difference(DateTime.now()).inHours, closeTo(48, 1));

      final pending = cubit.pendingDebtReminder('cust-1');
      expect(pending, isNotNull);
      expect(pending!.type, NotificationType.customerDebtReminder);
      expect(pending.relatedEntityId, 'cust-1');
      expect(pending.isPending, isTrue);

      // A different customer must never see this one.
      expect(cubit.pendingDebtReminder('cust-2'), isNull);
    });

    test('cancelDebtReminder cancels the OS alarm, deletes the row, and pendingDebtReminder goes back to null', () async {
      await cubit.scheduleDebtReminder(customerId: 'cust-1', customerName: 'Mahmoud', amountOwed: 120, days: 2);
      expect(cubit.pendingDebtReminder('cust-1'), isNotNull);

      await cubit.cancelDebtReminder('cust-1');

      expect(cubit.pendingDebtReminder('cust-1'), isNull);
      expect(scheduler.cancelled, hasLength(1));

      final rows = await (db.select(db.notificationsTable)..where((t) => t.relatedEntityId.equals('cust-1'))).get();
      expect(rows, isEmpty);
    });

    test('cancelDebtRemindersIfSettled only cancels once the debt actually reaches zero', () async {
      await cubit.scheduleDebtReminder(customerId: 'cust-1', customerName: 'Mahmoud', amountOwed: 120, days: 2);

      await cubit.cancelDebtRemindersIfSettled(customerId: 'cust-1', totalOwed: 40);
      expect(cubit.pendingDebtReminder('cust-1'), isNotNull, reason: 'still owes money — must not be cancelled yet');

      await cubit.cancelDebtRemindersIfSettled(customerId: 'cust-1', totalOwed: 0);
      expect(cubit.pendingDebtReminder('cust-1'), isNull);
    });

    test('a native-plugin failure while arming the OS alarm never blocks the row from showing as pending', () async {
      // Reproduces the real-device bug report: the DB write must land
      // and the in-app state must reflect it even when
      // flutter_local_notifications itself throws (permission denied,
      // OEM restrictions, etc.) — otherwise the button looks stuck
      // forever even though a row genuinely exists.
      scheduler.failNextCall = true;
      await cubit.scheduleDebtReminder(customerId: 'cust-1', customerName: 'Mahmoud', amountOwed: 120, days: 2);

      final pending = cubit.pendingDebtReminder('cust-1');
      expect(pending, isNotNull, reason: 'the local row + state must update regardless of the native scheduler throwing');
      expect(scheduler.scheduled, isEmpty, reason: 'the simulated failure means the OS alarm itself never actually got armed');
    });

    test('a native-plugin failure while cancelling still deletes the row and clears pending state', () async {
      await cubit.scheduleDebtReminder(customerId: 'cust-1', customerName: 'Mahmoud', amountOwed: 120, days: 2);

      scheduler.failNextCall = true;
      await cubit.cancelDebtReminder('cust-1');

      expect(cubit.pendingDebtReminder('cust-1'), isNull);
      final rows = await (db.select(db.notificationsTable)..where((t) => t.relatedEntityId.equals('cust-1'))).get();
      expect(rows, isEmpty);
    });

    test('scheduling again for the same customer stacks another pending reminder rather than silently no-oping', () async {
      await cubit.scheduleDebtReminder(customerId: 'cust-1', customerName: 'Mahmoud', amountOwed: 120, days: 5);
      final first = cubit.pendingDebtReminder('cust-1');

      // A second call from the widget (e.g. cancel then reschedule, or a
      // double tap) must still leave a real, findable pending reminder —
      // this is the exact path the customer detail page's row exercises.
      await cubit.cancelDebtReminder('cust-1');
      await cubit.scheduleDebtReminder(customerId: 'cust-1', customerName: 'Mahmoud', amountOwed: 120, days: 1);
      final second = cubit.pendingDebtReminder('cust-1');

      expect(second, isNotNull);
      expect(second!.id, isNot(first!.id));
    });
  });

  group('line expiry reminders', () {
    test('schedules both the 3-day-before and on-the-day alarms when expiry is far enough out', () async {
      final expiry = DateTime.now().add(const Duration(days: 10));
      await cubit.scheduleLineReminders(lineId: 'line-1', simNumber: '0599999999', customerName: 'Rana', expiryDate: expiry);

      expect(scheduler.scheduled, hasLength(2));
      final rows = await (db.select(db.notificationsTable)..where((t) => t.relatedEntityId.equals('line-1'))).get();
      expect(rows, hasLength(2));
      expect(rows.map((r) => r.type), containsAll([
        notificationTypeToRow(NotificationType.lineExpiringSoon),
        notificationTypeToRow(NotificationType.lineExpired),
      ]));
    });

    test('re-scheduling with a new expiry date cancels the old alarms instead of leaving stale ones behind', () async {
      final firstExpiry = DateTime.now().add(const Duration(days: 10));
      await cubit.scheduleLineReminders(lineId: 'line-1', simNumber: '0599999999', customerName: 'Rana', expiryDate: firstExpiry);
      expect(scheduler.scheduled, hasLength(2));

      final newExpiry = DateTime.now().add(const Duration(days: 20));
      await cubit.scheduleLineReminders(lineId: 'line-1', simNumber: '0599999999', customerName: 'Rana', expiryDate: newExpiry);

      // 2 cancelled from the first round, 2 more newly armed for the second.
      expect(scheduler.cancelled, hasLength(2));
      expect(scheduler.scheduled, hasLength(4));

      final rows = await (db.select(db.notificationsTable)..where((t) => t.relatedEntityId.equals('line-1'))).get();
      expect(rows, hasLength(2), reason: 'only the latest pair should remain in the inbox, not both rounds');
    });

    test('cancelLineReminders removes both alarms and rows for that line', () async {
      final expiry = DateTime.now().add(const Duration(days: 10));
      await cubit.scheduleLineReminders(lineId: 'line-1', simNumber: '0599999999', customerName: 'Rana', expiryDate: expiry);

      await cubit.cancelLineReminders('line-1');

      expect(scheduler.cancelled, hasLength(2));
      final rows = await (db.select(db.notificationsTable)..where((t) => t.relatedEntityId.equals('line-1'))).get();
      expect(rows, isEmpty);
    });

    test('an expiry date within the next 3 days only arms the on-the-day alarm, not an already-past 3-day-before one', () async {
      final expiry = DateTime.now().add(const Duration(days: 1));
      await cubit.scheduleLineReminders(lineId: 'line-1', simNumber: '0599999999', customerName: 'Rana', expiryDate: expiry);

      expect(scheduler.scheduled, hasLength(1));
      final rows = await (db.select(db.notificationsTable)..where((t) => t.relatedEntityId.equals('line-1'))).get();
      expect(rows.single.type, notificationTypeToRow(NotificationType.lineExpired));
    });
  });

  group('company low balance alert', () {
    test('raises exactly one alert even if the recompute runs repeatedly while still at/below zero', () async {
      await cubit.raiseOrClearLowBalanceAlert(companyId: 'company-1', companyName: 'Zain', availableToSell: 0);
      await cubit.raiseOrClearLowBalanceAlert(companyId: 'company-1', companyName: 'Zain', availableToSell: -5);
      await cubit.raiseOrClearLowBalanceAlert(companyId: 'company-1', companyName: 'Zain', availableToSell: 0);

      final rows = await (db.select(db.notificationsTable)
            ..where((t) => t.relatedEntityId.equals('company-1') & t.type.equals(notificationTypeToRow(NotificationType.companyLowBalance))))
          .get();
      expect(rows, hasLength(1), reason: 'repeated recomputes while still low must not spam duplicate alerts');
    });

    test('clears the alert the instant the balance recovers above zero, and a fresh dip raises a new one', () async {
      await cubit.raiseOrClearLowBalanceAlert(companyId: 'company-1', companyName: 'Zain', availableToSell: 0);
      await cubit.raiseOrClearLowBalanceAlert(companyId: 'company-1', companyName: 'Zain', availableToSell: 200);

      var rows = await (db.select(db.notificationsTable)
            ..where((t) => t.relatedEntityId.equals('company-1') & t.type.equals(notificationTypeToRow(NotificationType.companyLowBalance))))
          .get();
      expect(rows, isEmpty);
      expect(scheduler.cancelled, hasLength(1));

      await cubit.raiseOrClearLowBalanceAlert(companyId: 'company-1', companyName: 'Zain', availableToSell: 0);
      rows = await (db.select(db.notificationsTable)
            ..where((t) => t.relatedEntityId.equals('company-1') & t.type.equals(notificationTypeToRow(NotificationType.companyLowBalance))))
          .get();
      expect(rows, hasLength(1), reason: 'the second dip must be able to raise a brand new alert');
    });

    test('cancelCompanyAlerts clears a low-balance alert for a company that left the active list', () async {
      await cubit.raiseOrClearLowBalanceAlert(companyId: 'company-1', companyName: 'Zain', availableToSell: 0);
      await cubit.cancelCompanyAlerts('company-1');

      final rows = await (db.select(db.notificationsTable)..where((t) => t.relatedEntityId.equals('company-1'))).get();
      expect(rows, isEmpty);
    });
  });

  group('company owed alert', () {
    test('notifyCompanyOwed fires immediately (shown now, not scheduled) when there is an unpaid remainder', () async {
      await cubit.notifyCompanyOwed(companyId: 'company-1', companyName: 'Zain', amountOwed: 150);

      expect(scheduler.shownNow, hasLength(1));
      expect(scheduler.scheduled, isEmpty);
      final rows = await (db.select(db.notificationsTable)..where((t) => t.relatedEntityId.equals('company-1'))).get();
      expect(rows.single.type, notificationTypeToRow(NotificationType.companyOwedAlert));
    });

    test('does nothing when nothing is owed', () async {
      await cubit.notifyCompanyOwed(companyId: 'company-1', companyName: 'Zain', amountOwed: 0);
      expect(scheduler.shownNow, isEmpty);
    });
  });

  test('markRead flips the row and the emitted state without needing a real sync engine', () async {
    await cubit.notifyCompanyOwed(companyId: 'company-1', companyName: 'Zain', amountOwed: 150);
    final id = cubit.state.notifications.single.id;
    expect(cubit.state.notifications.single.read, isFalse);

    cubit.markRead(id);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.notifications.single.read, isTrue);
    final row = await (db.select(db.notificationsTable)..where((t) => t.id.equals(id))).getSingle();
    expect(row.read, isTrue);
  });
}

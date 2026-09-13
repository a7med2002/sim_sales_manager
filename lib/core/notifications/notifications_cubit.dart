import 'dart:async';

import 'package:drift/drift.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../auth/auth_service.dart';
import '../config/env.dart';
import '../database/app_database.dart';
import '../di/service_locator.dart';
import '../sync/sync_engine.dart';
import '../utils/uuid.dart';
import 'app_notification.dart';
import 'notification_id.dart';
import 'notification_scheduler.dart';
import 'notification_type.dart';
import 'notifications_state.dart';

/// Owns the local `notifications` table end to end: the in-app inbox
/// (`state.notifications`) and, in lockstep, whatever's actually armed
/// at the OS level through `NotificationScheduler`. Every feature that
/// needs to raise or clear a reminder goes through this Cubit's public
/// methods rather than touching `NotificationScheduler` directly, so
/// the inbox table and the real scheduled alarms can never drift apart.
///
/// **Line expiry** (`scheduleLineReminders`/`cancelLineReminders`):
/// called by `CustomersCubit` on every line add/edit/delete — 3 days
/// before `expiryDate` and again on the day itself, both at 9am local
/// time. **Customer debt** (`scheduleDebtReminder`/
/// `cancelDebtRemindersIfSettled`): a seller-picked 1-30 day "remind me"
/// per customer, auto-cancelled the moment that customer's total owed
/// reaches zero. **Company balance** (`raiseOrClearLowBalanceAlert`):
/// fires once when a company's `availableToSell` drops to zero or
/// below, clears itself the moment it recovers above zero so the next
/// dip can alert again. **Company owed** (`notifyCompanyOwed`): a
/// one-shot alert whenever a shipment is recorded with an unpaid
/// remainder — there's no "mark this shipment paid" flow to hook an
/// auto-cancel to (unlike a Line's `addPayment`), so unlike the other
/// three this one is fire-and-forget, not a persistent tracked state.
class NotificationsCubit extends Cubit<NotificationsState> {
  final AppDatabase? _db;
  final AuthService? _auth;
  final SyncEngine? _syncEngine;
  final NotificationScheduler _scheduler;

  NotificationsCubit({AppDatabase? db, AuthService? auth, SyncEngine? syncEngine, NotificationScheduler? scheduler})
    : _db = _resolveDb(db),
      _auth = _resolveAuth(auth),
      _syncEngine = syncEngine ?? (Env.isConfigured ? getIt<SyncEngine>() : null),
      _scheduler = scheduler ?? NotificationScheduler(),
      super(const NotificationsState()) {
    if (_db != null && _auth?.currentOwnerId != null) {
      unawaited(_init());
    }
  }

  static AppDatabase? _resolveDb(AppDatabase? db) => db ?? (Env.isConfigured ? getIt<AppDatabase>() : null);
  static AuthService? _resolveAuth(AuthService? auth) => auth ?? (Env.isConfigured ? getIt<AuthService>() : null);

  bool get _isReal => _db != null && _auth?.currentOwnerId != null;

  Future<void> _init() async {
    await _scheduler.init();
    await _scheduler.requestPermission();
    // Pulls back whatever survived on Supabase before anything else —
    // this is what lets a still-future reminder recover after the local
    // database was wiped (cleared app storage, reinstall) instead of
    // just silently vanishing. See notifications_table.dart's doc
    // comment.
    final engine = _syncEngine;
    final ownerId = _auth?.currentOwnerId;
    if (engine != null && ownerId != null) {
      try {
        await engine.pushPendingNotifications(ownerId);
        await engine.pullNotifications(ownerId);
      } catch (_) {
        // Offline or transient failure — proceed with local data.
      }
    }
    await _rearmAllPending();
    await _loadFromDrift();
  }

  Future<void> _pushBestEffort() async {
    final engine = _syncEngine;
    final ownerId = _auth?.currentOwnerId;
    if (engine == null || ownerId == null) return;
    try {
      await engine.pushPendingNotifications(ownerId);
    } catch (_) {
      // Offline or transient failure — next sync cycle retries.
    }
  }

  /// Re-schedules every still-future notification with the OS on every
  /// cold start — `zonedSchedule` calls for the same id just replace
  /// whatever was there, so this is safe to call unconditionally. Covers
  /// both a genuine device reboot (Android clears `AlarmManager` alarms
  /// then, the plugin's own boot receiver only catches what it had
  /// already persisted natively) and a fresh install/first run.
  Future<void> _rearmAllPending() async {
    final db = _db!;
    final ownerId = _auth!.currentOwnerId!;
    final now = DateTime.now();
    final rows = await (db.select(db.notificationsTable)
          ..where((t) => t.ownerId.equals(ownerId) & t.fireAt.isBiggerThanValue(now)))
        .get();
    for (final row in rows) {
      await _scheduler.scheduleAt(id: row.osNotificationId, title: row.title, body: row.body, at: row.fireAt);
    }
  }

  Future<void> _loadFromDrift() async {
    final db = _db!;
    final ownerId = _auth!.currentOwnerId!;
    final rows = await (db.select(db.notificationsTable)..where((t) => t.ownerId.equals(ownerId))).get();
    final notifications = rows
        .map((row) {
          final type = notificationTypeFromRow(row.type);
          if (type == null) return null;
          return AppNotification(
            id: row.id,
            type: type,
            title: row.title,
            body: row.body,
            relatedEntityId: row.relatedEntityId,
            fireAt: row.fireAt,
            read: row.read,
          );
        })
        .whereType<AppNotification>()
        .toList();
    emit(state.copyWith(notifications: notifications));
  }

  void markRead(String id) {
    if (!_isReal) return;
    final db = _db!;
    unawaited((db.update(db.notificationsTable)..where((t) => t.id.equals(id)))
        .write(NotificationsTableCompanion(read: const Value(true), synced: const Value(false), updatedAt: Value(DateTime.now())))
        .then((_) => _pushBestEffort()));
    emit(state.copyWith(notifications: state.notifications.map((n) => n.id == id ? AppNotification(
          id: n.id,
          type: n.type,
          title: n.title,
          body: n.body,
          relatedEntityId: n.relatedEntityId,
          fireAt: n.fireAt,
          read: true,
        ) : n).toList()));
  }

  Future<void> _insertAndSchedule({
    required NotificationType type,
    required String title,
    required String body,
    required String? relatedEntityId,
    required DateTime fireAt,
  }) async {
    final db = _db!;
    final ownerId = _auth!.currentOwnerId!;
    final id = generateUuidV4();
    final osId = notificationOsId(id);
    await db.into(db.notificationsTable).insert(NotificationsTableCompanion.insert(
          id: id,
          ownerId: ownerId,
          osNotificationId: osId,
          type: notificationTypeToRow(type),
          title: title,
          body: body,
          relatedEntityId: Value(relatedEntityId),
          fireAt: fireAt,
          synced: const Value(false),
          updatedAt: DateTime.now(),
        ));
    // The Drift row is the source of truth (per this app's offline-first
    // rule) — refresh state from it right away, before touching the OS
    // alarm below. `flutter_local_notifications`'s real plugin can throw
    // on a real device in ways the tests' fake scheduler never does
    // (missing notification permission, exact-alarm restrictions, OEM
    // quirks) — if that call threw *before* this reload ran, the row
    // would already be saved but the UI would never find out, since
    // nothing here awaits/catches this method's Future. Best-effort and
    // isolated so a native scheduling failure can never again block the
    // in-app state from reflecting what's actually in the database.
    await _loadFromDrift();
    try {
      if (fireAt.isAfter(DateTime.now())) {
        await _scheduler.scheduleAt(id: osId, title: title, body: body, at: fireAt);
      } else {
        await _scheduler.showNow(id: osId, title: title, body: body);
      }
    } catch (_) {
      // The reminder still exists and shows in the inbox; only the OS-level
      // alarm/heads-up failed to arm. _rearmAllPending retries this on
      // every cold start.
    }
    unawaited(_pushBestEffort());
  }

  /// Cancels every notification matching [match]: removes its OS alarm,
  /// deletes the local row, and tombstones+pushes the delete to Supabase
  /// (same `recordAndPushDelete` mechanism `CompaniesCubit`/
  /// `CustomersCubit` use — see its doc comment) so a pull can never
  /// resurrect a reminder that was correctly cancelled here.
  Future<void> _cancelWhere(bool Function(NotificationsTableData) match) async {
    final db = _db!;
    final ownerId = _auth!.currentOwnerId!;
    final rows = await (db.select(db.notificationsTable)..where((t) => t.ownerId.equals(ownerId))).get();
    for (final row in rows.where(match)) {
      // Same ordering fix as _insertAndSchedule: cancel the OS alarm
      // best-effort first, but never let a native-plugin failure there
      // stop the row from actually being deleted and reflected below.
      try {
        await _scheduler.cancel(row.osNotificationId);
      } catch (_) {
        // Worst case a stale alarm fires once more later; the row (the
        // source of truth) is still removed right after this.
      }
      await (db.delete(db.notificationsTable)..where((t) => t.id.equals(row.id))).go();
      unawaited(_syncEngine?.recordAndPushDelete(entityTable: 'notifications', id: row.id, ownerId: ownerId) ?? Future.value());
    }
    await _loadFromDrift();
  }

  // ── Line expiry ─────────────────────────────────────────────────────

  static DateTime _atNineAm(DateTime date) => DateTime(date.year, date.month, date.day, 9);

  /// Call on every line add/edit — clears any previous reminders for
  /// this line first, so an edited expiry date never leaves a stale
  /// alarm behind pointing at the old date.
  Future<void> scheduleLineReminders({
    required String lineId,
    required String simNumber,
    required String customerName,
    required DateTime expiryDate,
  }) async {
    if (!_isReal) return;
    await cancelLineReminders(lineId);

    final threeDaysBefore = _atNineAm(expiryDate.subtract(const Duration(days: 3)));
    if (threeDaysBefore.isAfter(DateTime.now())) {
      await _insertAndSchedule(
        type: NotificationType.lineExpiringSoon,
        title: 'notifications.lineExpiringSoon.title'.tr(),
        body: 'notifications.lineExpiringSoon.body'.tr(namedArgs: {'sim': simNumber, 'customer': customerName}),
        relatedEntityId: lineId,
        fireAt: threeDaysBefore,
      );
    }

    final onTheDay = _atNineAm(expiryDate);
    if (onTheDay.isAfter(DateTime.now())) {
      await _insertAndSchedule(
        type: NotificationType.lineExpired,
        title: 'notifications.lineExpired.title'.tr(),
        body: 'notifications.lineExpired.body'.tr(namedArgs: {'sim': simNumber, 'customer': customerName}),
        relatedEntityId: lineId,
        fireAt: onTheDay,
      );
    }
  }

  Future<void> cancelLineReminders(String lineId) async {
    if (!_isReal) return;
    await _cancelWhere((row) =>
        row.relatedEntityId == lineId &&
        (row.type == notificationTypeToRow(NotificationType.lineExpiringSoon) ||
            row.type == notificationTypeToRow(NotificationType.lineExpired)));
  }

  // ── Customer debt ───────────────────────────────────────────────────

  Future<void> scheduleDebtReminder({
    required String customerId,
    required String customerName,
    required double amountOwed,
    required int days,
  }) async {
    if (!_isReal) return;
    await _insertAndSchedule(
      type: NotificationType.customerDebtReminder,
      title: 'notifications.customerDebtReminder.title'.tr(),
      body: 'notifications.customerDebtReminder.body'.tr(namedArgs: {'customer': customerName, 'amount': amountOwed.toStringAsFixed(2)}),
      relatedEntityId: customerId,
      fireAt: DateTime.now().add(Duration(days: days)),
    );
  }

  /// Call after recording any payment against a customer's lines —
  /// cancels every pending debt reminder for [customerId] once
  /// [totalOwed] confirms nothing's left to collect.
  Future<void> cancelDebtRemindersIfSettled({required String customerId, required double totalOwed}) async {
    if (!_isReal || totalOwed > 0) return;
    await _cancelWhere((row) => row.relatedEntityId == customerId && row.type == notificationTypeToRow(NotificationType.customerDebtReminder));
  }

  /// Manual cancel from the customer detail page's reminder row — unlike
  /// [cancelDebtRemindersIfSettled] this isn't gated on the debt actually
  /// being paid off, since the seller may just want to call off a
  /// reminder they scheduled by mistake or too far out.
  Future<void> cancelDebtReminder(String customerId) async {
    if (!_isReal) return;
    await _cancelWhere((row) => row.relatedEntityId == customerId && row.type == notificationTypeToRow(NotificationType.customerDebtReminder));
  }

  /// The still-pending (future `fireAt`) debt reminder for [customerId],
  /// if any — lets the customer detail page show real persisted state
  /// instead of ephemeral widget state that resets on navigation.
  AppNotification? pendingDebtReminder(String customerId) {
    for (final n in state.notifications) {
      if (n.relatedEntityId == customerId && n.type == NotificationType.customerDebtReminder && n.isPending) return n;
    }
    return null;
  }

  // ── Company balance ─────────────────────────────────────────────────

  /// Call after every balance recompute (`CompaniesCubit._loadFromDrift`)
  /// with the company's current `availableToSell` — raises a one-shot
  /// alert the moment it's at/below zero (skipped if one's already
  /// pending, so a dozen reloads in a row don't spam a dozen alerts),
  /// and clears that alert the moment the balance recovers above zero so
  /// the next dip can raise a fresh one.
  Future<void> raiseOrClearLowBalanceAlert({required String companyId, required String companyName, required double availableToSell}) async {
    if (!_isReal) return;
    final db = _db!;
    final ownerId = _auth!.currentOwnerId!;
    final existing = await (db.select(db.notificationsTable)
          ..where((t) =>
              t.ownerId.equals(ownerId) &
              t.relatedEntityId.equals(companyId) &
              t.type.equals(notificationTypeToRow(NotificationType.companyLowBalance))))
        .get();

    if (availableToSell > 0) {
      if (existing.isEmpty) return;
      for (final row in existing) {
        await _scheduler.cancel(row.osNotificationId);
        await (db.delete(db.notificationsTable)..where((t) => t.id.equals(row.id))).go();
        unawaited(_syncEngine?.recordAndPushDelete(entityTable: 'notifications', id: row.id, ownerId: ownerId) ?? Future.value());
      }
      await _loadFromDrift();
      return;
    }

    if (existing.isNotEmpty) return;
    await _insertAndSchedule(
      type: NotificationType.companyLowBalance,
      title: 'notifications.companyLowBalance.title'.tr(),
      body: 'notifications.companyLowBalance.body'.tr(namedArgs: {'company': companyName, 'amount': availableToSell.toStringAsFixed(2)}),
      relatedEntityId: companyId,
      fireAt: DateTime.now(),
    );
  }

  // ── Company owed (unpaid shipment) ──────────────────────────────────

  Future<void> notifyCompanyOwed({required String companyId, required String companyName, required double amountOwed}) async {
    if (!_isReal || amountOwed <= 0) return;
    await _insertAndSchedule(
      type: NotificationType.companyOwedAlert,
      title: 'notifications.companyOwedAlert.title'.tr(),
      body: 'notifications.companyOwedAlert.body'.tr(namedArgs: {'company': companyName, 'amount': amountOwed.toStringAsFixed(2)}),
      relatedEntityId: companyId,
      fireAt: DateTime.now(),
    );
  }

  // ── Admin: new support request (live, not scheduled) ────────────────

  /// Called by `SupportRequestRealtimeGate` the instant a seller submits
  /// a new Support & Feedback request, while an admin's app is open.
  /// Unlike every other notification here, nothing schedules this ahead
  /// of time — it's a plain immediate insert (`fireAt: DateTime.now()`),
  /// same underlying path (`_insertAndSchedule` already shows instantly
  /// via `NotificationScheduler.showNow` when `fireAt` isn't in the
  /// future) that a same-instant company-balance alert already uses.
  Future<void> notifyNewSupportRequest({required String requestTypeLabel}) async {
    if (!_isReal) return;
    await _insertAndSchedule(
      type: NotificationType.newSupportRequest,
      title: 'notifications.newSupportRequest.title'.tr(),
      body: 'notifications.newSupportRequest.body'.tr(namedArgs: {'type': requestTypeLabel}),
      relatedEntityId: null,
      fireAt: DateTime.now(),
    );
  }

  /// Call whenever a company stops being active (archived, soft-deleted,
  /// or permanently deleted) — `raiseOrClearLowBalanceAlert` only ever
  /// runs over the *active* company list, so without this a low-balance
  /// alert already raised before the company left that list would sit
  /// in the inbox forever pointing at a company that's gone.
  Future<void> cancelCompanyAlerts(String companyId) async {
    if (!_isReal) return;
    await _cancelWhere((row) =>
        row.relatedEntityId == companyId &&
        (row.type == notificationTypeToRow(NotificationType.companyLowBalance) ||
            row.type == notificationTypeToRow(NotificationType.companyOwedAlert)));
  }
}

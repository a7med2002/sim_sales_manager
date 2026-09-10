import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Thin wrapper around `flutter_local_notifications` — the one place
/// that talks to the OS notification/alarm system directly.
/// `NotificationsCubit` is the only caller; it owns the actual
/// scheduling *decisions* (what to schedule, when to cancel), this just
/// executes them.
class NotificationScheduler {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _channelId = 'esim_dafter_reminders';
  static const _channelName = 'Reminders';
  static const _channelDescription = 'Line expiry, customer debt, and company balance reminders';

  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.local);
    } catch (_) {
      // Falls back to UTC if the platform's local timezone can't be
      // resolved — reminders still fire, just against UTC clock time.
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(_channelId, _channelName, description: _channelDescription),
    );

    _initialized = true;
  }

  Future<bool> requestPermission() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      return await androidPlugin.requestNotificationsPermission() ?? false;
    }
    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      return await iosPlugin.requestPermissions(alert: true, badge: true, sound: true) ?? false;
    }
    return true;
  }

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(_channelId, _channelName, channelDescription: _channelDescription),
        iOS: DarwinNotificationDetails(),
      );

  /// Schedules [title]/[body] to appear at [at]. A past [at] fires
  /// almost immediately instead (Android/iOS both handle this
  /// gracefully) — callers that need "never schedule for the past"
  /// filter before calling this, not here.
  Future<void> scheduleAt({required int id, required String title, required String body, required DateTime at}) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(at, tz.local),
      _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> showNow({required int id, required String title, required String body}) async {
    await _plugin.show(id, title, body, _details);
  }

  Future<void> cancel(int id) => _plugin.cancel(id);
}

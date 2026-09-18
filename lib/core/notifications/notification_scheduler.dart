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
    // Only used so `zonedSchedule` below has a loaded timezone database to
    // work with at all — this app deliberately never resolves the
    // device's actual named zone (`tz.local` defaults to, and stays,
    // UTC with nothing more done here; there's no bundled/platform-
    // channel way to ask for the real one without a new package). Every
    // `DateTime` this app schedules against is converted straight to a
    // UTC instant before it ever reaches `TZDateTime` (see [scheduleAt])
    // — Dart's own `DateTime.toUtc()` already correctly accounts for the
    // device's real offset, so the absolute moment scheduled is correct
    // regardless of what "local" means to the `timezone` package itself.
    tz_data.initializeTimeZones();

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

  /// Whether Android currently actually lets this app show notifications —
  /// distinct from [requestPermission]'s one-shot result at cold start:
  /// Android only shows that OS prompt once, ever, so a seller who denied
  /// it (or later revoked it from Settings) never gets asked again, and
  /// `requestNotificationsPermission()` just silently returns `false` from
  /// then on with no further UI. This is what actually explains "the
  /// reminder never showed while the app was closed" even though the row
  /// is saved correctly and its OS alarm still fires on schedule — the
  /// alarm fires, `AndroidScheduleMode` still runs, but Android drops the
  /// notification itself right before display because permission isn't
  /// granted. `NotificationsPage` polls this to show a real, actionable
  /// warning instead of a reminder that looks scheduled but can never
  /// actually be seen. `true` on iOS/non-Android, where this isn't
  /// resolvable the same way and isn't this app's primary target anyway.
  Future<bool> areNotificationsEnabled() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return true;
    return await androidPlugin.areNotificationsEnabled() ?? false;
  }

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(_channelId, _channelName, channelDescription: _channelDescription),
        iOS: DarwinNotificationDetails(),
      );

  /// Schedules [title]/[body] to appear at [at] (interpreted as whatever
  /// timezone [at] itself carries — local wall-clock time for every
  /// caller in this app; converted to UTC below before being wrapped in
  /// a `TZDateTime`, which is what actually determines the real fire
  /// instant, not the `Location` tag it carries). A past [at] fires
  /// almost immediately instead (Android/iOS both handle this
  /// gracefully) — callers that need "never schedule for the past"
  /// filter before calling this, not here.
  Future<void> scheduleAt({required int id, required String title, required String body, required DateTime at}) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(at.toUtc(), tz.UTC),
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

import 'package:flutter/services.dart';

/// Native-settings bridge (see `MainActivity.kt`) — the notifications page
/// uses this to send the seller straight to this app's OS notification
/// settings, or its general app-info page, with one tap. There's no
/// Flutter-side API for either (notification permission, once denied,
/// can't be re-requested through the plugin — only the OS settings screen
/// itself can flip it back on).
class NotificationSettingsBridge {
  static const _channel = MethodChannel('esim_dafter/notification_settings');

  static Future<void> openNotificationSettings() async {
    try {
      await _channel.invokeMethod('openNotificationSettings');
    } catch (_) {
      // Best-effort — some OEMs/older Android versions may not resolve
      // this intent; openAppSettings is the fallback callers use.
    }
  }

  /// Fallback when `openNotificationSettings` isn't available (rare OEMs) —
  /// also where the seller can find their OEM's own "battery
  /// optimization"/"auto-start" toggle, which this app has no standard,
  /// Play-policy-safe API to jump straight to.
  static Future<void> openAppSettings() async {
    try {
      await _channel.invokeMethod('openAppSettings');
    } catch (_) {
      // Nothing more we can do — the OS itself refused to open it.
    }
  }
}

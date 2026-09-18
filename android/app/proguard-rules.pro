# flutter_local_notifications (18.0.1) persists scheduled notifications to
# disk via Gson, using reflection over each class's generic type signature
# (`TypeToken`). R8's release-build code shrinking strips that signature
# info by default, which is the confirmed, reproduced cause of every
# scheduled reminder silently failing to arm on a real device with:
#   PlatformException(error, Missing type parameter., ...
#     at FlutterLocalNotificationsPlugin.loadScheduledNotifications
#     at FlutterLocalNotificationsPlugin.saveScheduledNotification
#     at FlutterLocalNotificationsPlugin.zonedSchedule
# — see https://github.com/MaikuB/flutter_local_notifications/issues/2265
# and the plugin's own README ("ProGuard/R8" section: manual rules are
# only required for versions before 19, which is what this app currently
# pins). Keep this file even if that version is ever bumped past 19 —
# harmless once truly unneeded, actively required until then.
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# The plugin's own model classes get (de)serialized by Gson via field-name
# reflection — R8 renaming/removing fields there breaks the JSON
# round-trip even with Signature preserved.
-keep class com.dexterous.flutterlocalnotifications.** { *; }

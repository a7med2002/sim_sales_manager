import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

/// A human-readable device name for the "Signed in from ..." Activity
/// Log entry (see `LoginCubit.submit`) — replaces the earlier plan for a
/// dedicated Trusted Devices feature: a log line is enough, no separate
/// table/page needed.
///
/// Android only ever exposes a device's manufacturer + raw model string
/// (e.g. "samsung SM-G991B") — there's no OS API for the marketing name
/// ("Galaxy S21"), so that's the best this can do there. iOS gives the
/// user-assigned device name directly (e.g. "Ahmed's iPhone"), which is
/// friendlier. Falls back to a plain OS label on any other platform or
/// on failure — this is a nice-to-have log detail, never worth blocking
/// sign-in over.
Future<String> currentDeviceName() async {
  try {
    final plugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final info = await plugin.androidInfo;
      return '${info.manufacturer} ${info.model}'.trim();
    }
    if (Platform.isIOS) {
      final info = await plugin.iosInfo;
      return info.name;
    }
    if (Platform.isWindows) {
      final info = await plugin.windowsInfo;
      return info.computerName;
    }
    if (Platform.isMacOS) {
      final info = await plugin.macOsInfo;
      return info.computerName;
    }
    if (Platform.isLinux) {
      final info = await plugin.linuxInfo;
      return info.name;
    }
    return Platform.operatingSystem;
  } catch (_) {
    return Platform.operatingSystem;
  }
}

import '../domain/entities/trusted_device.dart';

/// Static mock/dummy data — no real device/session tracking exists yet
/// (no Supabase Auth). Timestamps line up with the sign-in events already
/// seeded in Activity Log's mock data, for consistency.
class TrustedDevicesMockData {
  TrustedDevicesMockData._();

  static List<TrustedDevice> initialDevices() => [
        TrustedDevice(
          id: 'device-1',
          name: 'Windows - Chrome',
          type: DeviceType.desktop,
          ipAddress: '192.168.1.12',
          firstLogin: DateTime(2026, 7, 1, 9, 0),
          lastLogin: DateTime(2026, 8, 27, 9, 12),
          lastVerification: DateTime(2026, 8, 20, 9, 0),
          isThisDevice: true,
        ),
        TrustedDevice(
          id: 'device-2',
          name: 'Android - Chrome',
          type: DeviceType.mobile,
          ipAddress: '10.0.0.5',
          firstLogin: DateTime(2026, 7, 15, 8, 30),
          lastLogin: DateTime(2026, 8, 26, 18, 4),
          lastVerification: DateTime(2026, 8, 15, 8, 30),
        ),
        TrustedDevice(
          id: 'device-3',
          name: 'iPhone - Safari',
          type: DeviceType.mobile,
          ipAddress: '172.16.0.9',
          firstLogin: DateTime(2026, 8, 1, 7, 45),
          lastLogin: DateTime(2026, 8, 21, 13, 3),
          lastVerification: DateTime(2026, 8, 1, 7, 45),
        ),
        TrustedDevice(
          id: 'device-4',
          name: 'macOS - Safari',
          type: DeviceType.desktop,
          ipAddress: '192.168.1.44',
          firstLogin: DateTime(2026, 6, 10, 11, 0),
          lastLogin: DateTime(2026, 8, 10, 10, 0),
          lastVerification: DateTime(2026, 7, 1, 11, 0),
        ),
      ];
}

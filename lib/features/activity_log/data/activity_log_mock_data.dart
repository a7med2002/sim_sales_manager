import '../domain/entities/activity_log_entry.dart';

/// Static mock/dummy data — used only offline/in demo mode (no configured
/// Supabase project or no signed-in owner yet). In real mode, entries
/// come from Drift's `activity_log` table instead, written by
/// `core/activity_log/activity_logger.dart` (see `ActivityLogCubit`).
class ActivityLogMockData {
  ActivityLogMockData._();

  static List<ActivityLogEntry> initialEntries() => [
        ActivityLogEntry(
          id: 'log-1',
          timestamp: DateTime(2026, 8, 27, 9, 12),
          type: ActivityActionType.login,
          details: 'Signed in from Chrome on Windows.',
        ),
        ActivityLogEntry(
          id: 'log-2',
          timestamp: DateTime(2026, 8, 27, 9, 20),
          type: ActivityActionType.fullCollection,
          details: "Collected the remaining ₪5.00 on Mahmoud Salah's Weekly 1GB line.",
        ),
        ActivityLogEntry(
          id: 'log-3',
          timestamp: DateTime(2026, 8, 26, 18, 4),
          type: ActivityActionType.create,
          details: 'Sold a new line to Yousef Hamdan (Weekly 500MB, Ooredoo).',
        ),
        ActivityLogEntry(
          id: 'log-4',
          timestamp: DateTime(2026, 8, 26, 14, 47),
          type: ActivityActionType.edit,
          details: "Updated customer Karim Odeh's status to Troubled.",
        ),
        ActivityLogEntry(
          id: 'log-5',
          timestamp: DateTime(2026, 8, 25, 11, 30),
          type: ActivityActionType.delete,
          details: "Deleted Karim Odeh's Weekly 2GB line (0569884413).",
        ),
        ActivityLogEntry(
          id: 'log-6',
          timestamp: DateTime(2026, 8, 24, 20, 15),
          type: ActivityActionType.create,
          details: 'Added new customer Mahmoud Salah.',
        ),
        ActivityLogEntry(
          id: 'log-7',
          timestamp: DateTime(2026, 8, 24, 20, 22),
          type: ActivityActionType.create,
          details: 'Added a new shipment to Jawwal for ₪2,000.00 (prepaid).',
        ),
        ActivityLogEntry(
          id: 'log-8',
          timestamp: DateTime(2026, 8, 23, 8, 5),
          type: ActivityActionType.edit,
          details: 'Archived company Orange.',
        ),
        ActivityLogEntry(
          id: 'log-9',
          timestamp: DateTime(2026, 8, 22, 16, 41),
          type: ActivityActionType.create,
          details: 'Imported ready-made company Holafly.',
        ),
        ActivityLogEntry(
          id: 'log-10',
          timestamp: DateTime(2026, 8, 21, 13, 3),
          type: ActivityActionType.login,
          details: 'Signed in from Safari on iPhone.',
        ),
        ActivityLogEntry(
          id: 'log-11',
          timestamp: DateTime(2026, 8, 20, 10, 58),
          type: ActivityActionType.fullCollection,
          details: "Collected ₪60.00 on Lina Abu Rahma's Regional 3GB line.",
        ),
        ActivityLogEntry(
          id: 'log-12',
          timestamp: DateTime(2026, 8, 19, 17, 26),
          type: ActivityActionType.edit,
          details: 'Updated profile name to Ahmed Mq.',
        ),
        ActivityLogEntry(
          id: 'log-13',
          timestamp: DateTime(2026, 8, 18, 9, 40),
          type: ActivityActionType.edit,
          details: 'Changed the app currency symbol to ₪.',
        ),
        ActivityLogEntry(
          id: 'log-14',
          timestamp: DateTime(2026, 8, 17, 21, 11),
          type: ActivityActionType.create,
          details: 'Added new customer Rana Nasser.',
        ),
        ActivityLogEntry(
          id: 'log-15',
          timestamp: DateTime(2026, 8, 16, 12, 0),
          type: ActivityActionType.delete,
          details: 'Deleted customer Test Telecom (soft delete).',
        ),
      ];
}

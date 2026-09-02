import '../domain/entities/number_update_entry.dart';

/// Seeded update-log entries so the page feels alive before the real
/// automatic per-company lookup exists. Reuses phone numbers already seeded
/// in Customers' mock data (Mahmoud Salah, Karim Odeh) so the history reads
/// as a plausible continuation of data visible elsewhere in the app.
class NumberUpdateMockData {
  NumberUpdateMockData._();

  static List<NumberUpdateEntry> initialLog() => [
        NumberUpdateEntry(
          id: 'update-1',
          phoneNumber: '0599123456',
          timestamp: DateTime(2026, 8, 26, 10, 15),
          status: NumberUpdateStatus.success,
          message: 'Status refreshed from the supplier platform.',
        ),
        NumberUpdateEntry(
          id: 'update-2',
          phoneNumber: '0599123456',
          timestamp: DateTime(2026, 8, 20, 14, 40),
          status: NumberUpdateStatus.success,
          message: 'Status refreshed from the supplier platform.',
        ),
        NumberUpdateEntry(
          id: 'update-3',
          phoneNumber: '0569884412',
          timestamp: DateTime(2026, 8, 22, 9, 5),
          status: NumberUpdateStatus.notFound,
          message: 'Number not found on the supplier platform yet.',
        ),
      ];
}

import '../domain/entities/shipment.dart';

/// Static mock/dummy data — a small transaction history so the tab
/// doesn't look empty. These don't reconcile exactly with the baseline
/// consumed/available/owed numbers already seeded on `Company` (those
/// are a fixed starting point, same simplification as
/// `Company.profitGenerated` not deriving from Customers' seeded
/// lines) — the important part is that *new* shipments added during the
/// session correctly move the company's real balance via
/// `CompanyCatalog.addShipment`.
class ShipmentsMockData {
  ShipmentsMockData._();

  static List<Shipment> initialShipments() => [
        Shipment(
          id: 'shipment-1',
          companyName: 'Jawwal',
          companyInitials: 'J',
          type: ShipmentType.prepaid,
          totalAmount: 2000,
          amountPaid: 2000,
          paymentMethod: 'Bank transfer',
          date: DateTime(2026, 8, 24),
          referenceNumber: 'JW-2026-08',
        ),
        Shipment(
          id: 'shipment-2',
          companyName: 'Ooredoo',
          companyInitials: 'O',
          type: ShipmentType.creditLimit,
          totalAmount: 900,
          amountPaid: 300,
          paymentMethod: 'Cash',
          date: DateTime(2026, 8, 12),
          referenceNumber: 'OR-2026-08',
        ),
        Shipment(
          id: 'shipment-3',
          companyName: 'Airalo eSIM',
          companyInitials: 'AE',
          type: ShipmentType.prepaid,
          totalAmount: 600,
          amountPaid: 600,
          paymentMethod: 'Wallet',
          date: DateTime(2026, 7, 28),
        ),
        Shipment(
          id: 'shipment-4',
          companyName: 'Jawwal',
          companyInitials: 'J',
          type: ShipmentType.prepaid,
          totalAmount: 1500,
          amountPaid: 1500,
          paymentMethod: 'Bank transfer',
          date: DateTime(2026, 7, 5),
          referenceNumber: 'JW-2026-07',
        ),
      ];
}

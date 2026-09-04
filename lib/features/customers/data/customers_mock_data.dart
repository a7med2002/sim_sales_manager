import '../domain/entities/customer.dart';
import '../domain/entities/line.dart';

/// Static mock/dummy data — no Drift/Supabase yet. Line totals per customer
/// (spent/owed) match design/screenshots/customers.png and
/// `customer details.png`.
class CustomersMockData {
  CustomersMockData._();

  static List<Customer> initialCustomers() => const [
        Customer(
          id: 'mahmoud-salah',
          name: 'Mahmoud Salah',
          contactNumber: '0599123456',
          tags: ['regular', 'hebron'],
          status: CustomerStatus.normal,
          pinned: true,
          notes: 'Buys monthly bundles for the family.',
        ),
        Customer(
          id: 'karim-odeh',
          name: 'Karim Odeh',
          contactNumber: '0569884412',
          tags: ['late payer'],
          status: CustomerStatus.troubled,
        ),
        Customer(
          id: 'lina-abu-rahma',
          name: 'Lina Abu Rahma',
          contactNumber: '+970598772211',
          tags: ['travel'],
          status: CustomerStatus.normal,
        ),
        Customer(
          id: 'rana-nasser',
          name: 'Rana Nasser',
          contactNumber: '0509004455',
          status: CustomerStatus.normal,
        ),
        Customer(
          id: 'yousef-hamdan',
          name: 'Yousef Hamdan',
          contactNumber: '0567712233',
          tags: ['new'],
          status: CustomerStatus.normal,
        ),
      ];

  static List<Line> initialLines() => [
        // Mahmoud Salah — 4 lines, total spent 148, owed 5.
        Line(
          id: 'line-1',
          customerId: 'mahmoud-salah',
          simNumber: '0599123456',
          companyId: 'ooredoo',
          companyName: 'Ooredoo',
          companyInitials: 'O',
          packageName: 'Weekly 1GB',
          purchaseDate: DateTime(2026, 8, 24),
          expiryDate: DateTime(2026, 9, 23),
          wholesaleCost: 10,
          retailPrice: 15,
          paymentStatus: PaymentStatus.partial,
          amountPaid: 10,
          amountRemaining: 5,
        ),
        Line(
          id: 'line-2',
          customerId: 'mahmoud-salah',
          simNumber: '0599123457',
          companyId: 'jawwal',
          companyName: 'Jawwal',
          companyInitials: 'J',
          packageName: 'Weekly 500MB',
          purchaseDate: DateTime(2026, 8, 18),
          expiryDate: DateTime(2026, 9, 2),
          wholesaleCost: 8,
          retailPrice: 12,
          paymentStatus: PaymentStatus.paid,
          amountPaid: 12,
          amountRemaining: 0,
        ),
        Line(
          id: 'line-3',
          customerId: 'mahmoud-salah',
          simNumber: '0599123456',
          companyId: 'jawwal',
          companyName: 'Jawwal',
          companyInitials: 'J',
          packageName: 'Monthly 5GB',
          purchaseDate: DateTime(2026, 7, 10),
          expiryDate: DateTime(2026, 8, 10),
          wholesaleCost: 40,
          retailPrice: 60,
          paymentStatus: PaymentStatus.paid,
          amountPaid: 60,
          amountRemaining: 0,
        ),
        Line(
          id: 'line-4',
          customerId: 'mahmoud-salah',
          simNumber: '0599123456',
          companyId: 'ooredoo',
          companyName: 'Ooredoo',
          companyInitials: 'O',
          packageName: 'Monthly 3GB',
          purchaseDate: DateTime(2026, 6, 1),
          expiryDate: DateTime(2026, 7, 1),
          wholesaleCost: 40,
          retailPrice: 61,
          paymentStatus: PaymentStatus.paid,
          amountPaid: 61,
          amountRemaining: 0,
        ),

        // Karim Odeh — 2 lines, total spent 60, owed 55.
        Line(
          id: 'line-5',
          customerId: 'karim-odeh',
          simNumber: '0569884412',
          companyId: 'ooredoo',
          companyName: 'Ooredoo',
          companyInitials: 'O',
          packageName: 'Weekly 2GB',
          purchaseDate: DateTime(2026, 8, 10),
          expiryDate: DateTime(2026, 8, 17),
          wholesaleCost: 12,
          retailPrice: 20,
          paymentStatus: PaymentStatus.unpaid,
          amountPaid: 0,
          amountRemaining: 20,
        ),
        Line(
          id: 'line-6',
          customerId: 'karim-odeh',
          simNumber: '0569884413',
          companyId: 'jawwal',
          companyName: 'Jawwal',
          companyInitials: 'J',
          packageName: 'Weekly 2GB',
          purchaseDate: DateTime(2026, 8, 5),
          expiryDate: DateTime(2026, 8, 12),
          wholesaleCost: 15,
          retailPrice: 40,
          paymentStatus: PaymentStatus.partial,
          amountPaid: 5,
          amountRemaining: 35,
        ),

        // Lina Abu Rahma — 2 lines, total spent 148, owed 30.
        Line(
          id: 'line-7',
          customerId: 'lina-abu-rahma',
          simNumber: '+970598772211',
          companyId: 'airalo',
          companyName: 'Airalo eSIM',
          companyInitials: 'AE',
          packageName: 'Global 5GB',
          purchaseDate: DateTime(2026, 8, 20),
          expiryDate: DateTime(2026, 9, 20),
          wholesaleCost: 30,
          retailPrice: 88,
          paymentStatus: PaymentStatus.partial,
          amountPaid: 58,
          amountRemaining: 30,
        ),
        Line(
          id: 'line-8',
          customerId: 'lina-abu-rahma',
          simNumber: '+970598772212',
          companyId: 'airalo',
          companyName: 'Airalo eSIM',
          companyInitials: 'AE',
          packageName: 'Regional 3GB',
          purchaseDate: DateTime(2026, 8, 15),
          expiryDate: DateTime(2026, 8, 29),
          wholesaleCost: 18,
          retailPrice: 60,
          paymentStatus: PaymentStatus.paid,
          amountPaid: 60,
          amountRemaining: 0,
        ),

        // Rana Nasser — 1 line, total spent 45, owed 0.
        Line(
          id: 'line-9',
          customerId: 'rana-nasser',
          simNumber: '0509004455',
          companyId: 'jawwal',
          companyName: 'Jawwal',
          companyInitials: 'J',
          packageName: 'Weekly 1GB',
          purchaseDate: DateTime(2026, 8, 22),
          expiryDate: DateTime(2026, 9, 22),
          wholesaleCost: 15,
          retailPrice: 45,
          paymentStatus: PaymentStatus.paid,
          amountPaid: 45,
          amountRemaining: 0,
        ),

        // Yousef Hamdan — 1 line, total spent 20, owed 0.
        Line(
          id: 'line-10',
          customerId: 'yousef-hamdan',
          simNumber: '0567712233',
          companyId: 'ooredoo',
          companyName: 'Ooredoo',
          companyInitials: 'O',
          packageName: 'Weekly 500MB',
          purchaseDate: DateTime(2026, 8, 25),
          expiryDate: DateTime(2026, 9, 25),
          wholesaleCost: 8,
          retailPrice: 20,
          paymentStatus: PaymentStatus.paid,
          amountPaid: 20,
          amountRemaining: 0,
        ),
      ];

  /// Common supplier brand names, offered as quick-pick chips on the
  /// Add/Edit Line sheet (kept local to this feature — not importing the
  /// Companies feature's entities, per CLAUDE.md's no-cross-feature-import
  /// rule).
  static const commonCompanyNames = ['Jawwal', 'Ooredoo', 'Airalo eSIM', 'Orange', 'Holafly'];
}

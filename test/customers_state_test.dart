import 'package:flutter_test/flutter_test.dart';

import 'package:sim_sales_manager/features/customers/domain/entities/additional_service.dart';
import 'package:sim_sales_manager/features/customers/domain/entities/line.dart';
import 'package:sim_sales_manager/features/customers/presentation/cubit/customers_state.dart';

/// Regression coverage for the "Additional Service" feature's debt
/// math: `totalOwedFor` must add any not-yet-collected `amountCharged`
/// on top of a customer's lines' own `amountRemaining`, without ever
/// touching `Line`/`Line.applyPayment` itself (see
/// additional_services_table.dart's doc comment on why that separation
/// matters — folding this into `retailPrice`/`amountRemaining` directly
/// would get silently wiped out by the next payment on that line).
void main() {
  final now = DateTime.now();

  Line makeLine({required String id, required double amountRemaining}) {
    return Line(
      id: id,
      customerId: 'cust-1',
      simNumber: '0599999999',
      companyId: 'company-1',
      companyName: 'Zain',
      companyInitials: 'Z',
      packageName: '5GB',
      purchaseDate: now,
      expiryDate: now.add(const Duration(days: 30)),
      wholesaleCost: 20,
      retailPrice: 30,
      paymentStatus: PaymentStatus.partial,
      amountPaid: 30 - amountRemaining,
      amountRemaining: amountRemaining,
    );
  }

  AdditionalService makeService({
    required String id,
    required String lineId,
    required double amountCharged,
    bool collected = false,
  }) {
    return AdditionalService(
      id: id,
      lineId: lineId,
      customerId: 'cust-1',
      companyId: 'company-1',
      amountDeducted: 10,
      amountCharged: amountCharged,
      gbAdded: 30,
      collected: collected,
      createdAt: now,
    );
  }

  test('totalOwedFor adds uncollected additional-service charges on top of lines\' own remaining', () {
    final state = CustomersState(
      lines: [makeLine(id: 'line-1', amountRemaining: 15)],
      additionalServices: [makeService(id: 'svc-1', lineId: 'line-1', amountCharged: 5)],
    );

    expect(state.totalOwedFor('cust-1'), 20);
  });

  test('a collected additional-service charge no longer counts toward totalOwedFor', () {
    final state = CustomersState(
      lines: [makeLine(id: 'line-1', amountRemaining: 15)],
      additionalServices: [makeService(id: 'svc-1', lineId: 'line-1', amountCharged: 5, collected: true)],
    );

    expect(state.totalOwedFor('cust-1'), 15);
  });

  test('an additional service with amountCharged 0 (not charged to the customer) never adds debt', () {
    final state = CustomersState(
      lines: [makeLine(id: 'line-1', amountRemaining: 15)],
      additionalServices: [makeService(id: 'svc-1', lineId: 'line-1', amountCharged: 0)],
    );

    expect(state.totalOwedFor('cust-1'), 15);
  });

  test('a fully paid-off line (amountRemaining 0) can still owe purely through an uncollected service charge', () {
    final state = CustomersState(
      lines: [makeLine(id: 'line-1', amountRemaining: 0)],
      additionalServices: [makeService(id: 'svc-1', lineId: 'line-1', amountCharged: 8)],
    );

    expect(state.totalOwedFor('cust-1'), 8);
  });

  test('additionalServicesFor returns only that line\'s services, newest first', () {
    final older = makeService(id: 'svc-old', lineId: 'line-1', amountCharged: 5);
    final newer = AdditionalService(
      id: 'svc-new',
      lineId: 'line-1',
      customerId: 'cust-1',
      companyId: 'company-1',
      amountDeducted: 10,
      amountCharged: 5,
      gbAdded: 30,
      collected: false,
      createdAt: now.add(const Duration(hours: 1)),
    );
    final otherLine = makeService(id: 'svc-other', lineId: 'line-2', amountCharged: 5);

    final state = CustomersState(additionalServices: [older, newer, otherLine]);

    expect(state.additionalServicesFor('line-1').map((s) => s.id), ['svc-new', 'svc-old']);
  });
}

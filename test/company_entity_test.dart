import 'package:flutter_test/flutter_test.dart';

import 'package:sim_sales_manager/features/companies/domain/entities/company.dart';

/// Regression test for the "deleted line, company balance didn't move
/// until app restart" bug: `reverseSale` must be the exact inverse of
/// `applySale`, since `CustomersCubit.deleteLine`/`updateLine` rely on
/// it to keep `CompaniesCubit`'s optimistic in-memory balance correct
/// the moment a Line goes away or changes, not just on the next reload.
void main() {
  const company = Company(
    id: 'company-1',
    name: 'Jawwal',
    initials: 'J',
    consumed: 100,
    availableToSell: 400,
    profitGenerated: 50,
    operationsCount: 3,
    usagePercent: 20, // consistent with consumed/available above (100 / 500)
  );

  test('reverseSale undoes applySale exactly, back to the original balance', () {
    final sold = company.applySale(wholesaleCost: 30, profit: 12);
    expect(sold.consumed, 130);
    expect(sold.availableToSell, 370);
    expect(sold.operationsCount, 4);
    expect(sold.profitGenerated, 62);

    final reversed = sold.reverseSale(wholesaleCost: 30, profit: 12);
    expect(reversed.consumed, company.consumed);
    expect(reversed.availableToSell, company.availableToSell);
    expect(reversed.operationsCount, company.operationsCount);
    expect(reversed.profitGenerated, company.profitGenerated);
    expect(reversed.usagePercent, company.usagePercent);
  });

  test('reverseSale never drives consumed/operationsCount negative', () {
    final reversed = company.reverseSale(wholesaleCost: 999, profit: 999);
    expect(reversed.consumed, 0);
    expect(reversed.operationsCount, 2); // 3 - 1, never below 0 in general
    expect(reversed.availableToSell, 400 + 999);
  });
}

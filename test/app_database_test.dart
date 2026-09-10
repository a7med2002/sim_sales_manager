import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sim_sales_manager/core/database/app_database.dart';

/// Smoke test for the multi-tenant Drift schema (Phase 2/3 of the
/// multi-tenant/admin architecture — see design/APP_CONTEXT.md). Not
/// exhaustive per-table coverage; just confirms the schema actually
/// opens and that the ownership relationships every feature migration
/// depends on round-trip correctly: a seller's own `companies`/
/// `packages` (fully theirs, unrelated to other sellers'), and the
/// separate, admin-only `company_catalog`/`package_catalog` used only to
/// prefill "Import Ready-Made" — never a live link to a seller's company.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('inserts a seller-owned company and a shipment against it', () async {
    final now = DateTime.now();

    await db.into(db.companiesTable).insert(
      CompaniesTableCompanion.insert(id: 'company-1', ownerId: 'seller-1', name: 'Zain', updatedAt: now),
    );

    await db.into(db.shipmentsTable).insert(
      ShipmentsTableCompanion.insert(
        id: 'shipment-1',
        ownerId: 'seller-1',
        companyId: 'company-1',
        type: 'prepaid',
        shipmentDate: now,
        updatedAt: now,
      ),
    );

    final shipments = await db.select(db.shipmentsTable).get();
    expect(shipments, hasLength(1));
    expect(shipments.single.ownerId, 'seller-1');
    expect(shipments.single.companyId, 'company-1');
    expect(shipments.single.synced, isTrue);
  });

  test('two sellers can each own a company with the same name independently', () async {
    final now = DateTime.now();

    await db.into(db.companiesTable).insert(
      CompaniesTableCompanion.insert(id: 'company-a', ownerId: 'seller-a', name: 'Umniah', updatedAt: now),
    );
    await db.into(db.companiesTable).insert(
      CompaniesTableCompanion.insert(
        id: 'company-b',
        ownerId: 'seller-b',
        name: 'Umniah',
        updatedAt: now,
        pinned: const Value(true),
      ),
    );

    final rows = await db.select(db.companiesTable).get();
    expect(rows, hasLength(2));
    expect(rows.where((r) => r.ownerId == 'seller-a').single.pinned, isFalse);
    expect(rows.where((r) => r.ownerId == 'seller-b').single.pinned, isTrue);
  });

  test('CompaniesCubit-style load returns only this seller\'s companies with their own packages', () async {
    final now = DateTime.now();
    await db.batch((batch) {
      batch.insertAll(db.companiesTable, [
        CompaniesTableCompanion.insert(id: 'zain-a', ownerId: 'seller-a', name: 'Zain', updatedAt: now),
        CompaniesTableCompanion.insert(id: 'umniah-b', ownerId: 'seller-b', name: 'Umniah', updatedAt: now),
      ]);
      batch.insertAll(db.packagesTable, [
        PackagesTableCompanion.insert(
          id: 'zain-a-5gb',
          ownerId: 'seller-a',
          companyId: 'zain-a',
          name: '5GB',
          wholesaleCost: const Value(18),
          retailPrice: const Value(28),
          updatedAt: now,
        ),
      ]);
    });

    final companies = await (db.select(db.companiesTable)..where((c) => c.ownerId.equals('seller-a'))).get();
    expect(companies, hasLength(1));
    expect(companies.single.name, 'Zain');

    final packages = await (db.select(db.packagesTable)..where((p) => p.companyId.equals('zain-a'))).get();
    expect(packages, hasLength(1));
    expect(packages.single.name, '5GB');
  });

  test('importing from the catalog copies data — editing the company afterward never touches the catalog', () async {
    final now = DateTime.now();
    await db.into(db.companyCatalogTable).insert(
      CompanyCatalogTableCompanion.insert(id: 'catalog-zain', name: 'Zain', createdAt: now, updatedAt: now),
    );

    // "Import": a fresh, independent company row referencing the catalog
    // entry only via `catalogCompanyId`, not by sharing its id.
    await db.into(db.companiesTable).insert(
      CompaniesTableCompanion.insert(
        id: 'my-zain',
        ownerId: 'seller-a',
        name: 'Zain',
        catalogCompanyId: const Value('catalog-zain'),
        updatedAt: now,
      ),
    );

    // Seller freely renames their own copy.
    await (db.update(db.companiesTable)..where((t) => t.id.equals('my-zain')))
        .write(CompaniesTableCompanion(name: const Value('Zain (my prices)')));

    final catalogRow = await (db.select(db.companyCatalogTable)..where((c) => c.id.equals('catalog-zain'))).getSingle();
    expect(catalogRow.name, 'Zain', reason: 'editing the imported copy must not mutate the catalog template');

    final ownedRow = await (db.select(db.companiesTable)..where((c) => c.id.equals('my-zain'))).getSingle();
    expect(ownedRow.name, 'Zain (my prices)');
    expect(ownedRow.catalogCompanyId, 'catalog-zain');
  });

  test('CustomersCubit-style load: a new insert defaults synced=false-only-when-set, tags round-trip', () async {
    final now = DateTime.now();

    // Mirrors CustomersCubit._persistNewCustomer: explicit synced:false
    // on insert, tags stored as a comma-joined string locally.
    await db.into(db.customersTable).insert(
      CustomersTableCompanion.insert(
        id: 'cust-1',
        ownerId: 'seller-a',
        name: 'Mahmoud',
        contactNumber: '0591234567',
        tags: const Value('vip,reseller'),
        synced: const Value(false),
        updatedAt: now,
      ),
    );
    await db.into(db.customersTable).insert(
      CustomersTableCompanion.insert(id: 'cust-2', ownerId: 'seller-b', name: 'Rana', contactNumber: '0599999999', updatedAt: now),
    );

    final ownRows = await (db.select(db.customersTable)..where((c) => c.ownerId.equals('seller-a'))).get();
    expect(ownRows, hasLength(1));
    expect(ownRows.single.name, 'Mahmoud');
    expect(ownRows.single.tags.split(','), ['vip', 'reseller']);
    expect(ownRows.single.synced, isFalse, reason: 'unsynced rows are exactly what pushPendingCustomers filters on');

    final pending = await (db.select(db.customersTable)..where((c) => c.synced.equals(false))).get();
    expect(pending.map((r) => r.id), ['cust-1']);
  });

  test('a Line references this seller\'s own company/package, not the catalog', () async {
    final now = DateTime.now();
    await db.batch((batch) {
      batch.insertAll(db.customersTable, [
        CustomersTableCompanion.insert(id: 'cust-1', ownerId: 'seller-a', name: 'Mahmoud', contactNumber: '0591234567', updatedAt: now),
      ]);
      batch.insertAll(db.companiesTable, [
        CompaniesTableCompanion.insert(id: 'my-zain', ownerId: 'seller-a', name: 'Zain', updatedAt: now),
      ]);
      batch.insertAll(db.packagesTable, [
        PackagesTableCompanion.insert(
          id: 'my-zain-5gb',
          ownerId: 'seller-a',
          companyId: 'my-zain',
          name: '5GB',
          wholesaleCost: const Value(18),
          retailPrice: const Value(28),
          updatedAt: now,
        ),
      ]);
    });

    await db.into(db.linesTable).insert(LinesTableCompanion.insert(
          id: 'line-1',
          ownerId: 'seller-a',
          customerId: 'cust-1',
          companyId: const Value('my-zain'),
          packageId: const Value('my-zain-5gb'),
          simNumber: '0599999999',
          purchaseDate: now,
          expiryDate: now.add(const Duration(days: 30)),
          wholesaleCost: const Value(18),
          retailPrice: const Value(28),
          profit: const Value(10),
          paymentStatus: const Value('paid'),
          amountPaid: const Value(28),
          synced: const Value(false),
          updatedAt: now,
        ));

    final line = await (db.select(db.linesTable)..where((l) => l.id.equals('line-1'))).getSingle();
    expect(line.companyId, 'my-zain');
    expect(line.packageId, 'my-zain-5gb');
    expect(line.profit, 10);
    expect(line.synced, isFalse);
  });

  test('CompaniesCubit-style derived balance: shipments minus lines\' wholesale cost', () async {
    final now = DateTime.now();
    await db.into(db.companiesTable).insert(
      CompaniesTableCompanion.insert(id: 'zain', ownerId: 'seller-a', name: 'Zain', updatedAt: now),
    );
    await db.batch((batch) {
      batch.insertAll(db.shipmentsTable, [
        ShipmentsTableCompanion.insert(
          id: 'ship-1',
          ownerId: 'seller-a',
          companyId: 'zain',
          type: 'prepaid',
          totalAmount: const Value(500),
          amountPaid: const Value(500),
          shipmentDate: now,
          updatedAt: now,
        ),
        ShipmentsTableCompanion.insert(
          id: 'ship-2',
          ownerId: 'seller-a',
          companyId: 'zain',
          type: 'credit_limit',
          totalAmount: const Value(200),
          amountPaid: const Value(50), // 150 owed
          shipmentDate: now,
          updatedAt: now,
        ),
      ]);
      batch.insertAll(db.customersTable, [
        CustomersTableCompanion.insert(id: 'cust-1', ownerId: 'seller-a', name: 'Mahmoud', contactNumber: '0591234567', updatedAt: now),
      ]);
      batch.insertAll(db.linesTable, [
        LinesTableCompanion.insert(
          id: 'line-1',
          ownerId: 'seller-a',
          customerId: 'cust-1',
          companyId: const Value('zain'),
          simNumber: '0599999999',
          purchaseDate: now,
          expiryDate: now.add(const Duration(days: 30)),
          wholesaleCost: const Value(120),
          retailPrice: const Value(180),
          profit: const Value(60),
          updatedAt: now,
        ),
      ]);
    });

    // Mirrors CompaniesCubit._loadFromDrift's exact formula.
    final shipments = await (db.select(db.shipmentsTable)..where((s) => s.companyId.equals('zain'))).get();
    final lines = await (db.select(db.linesTable)..where((l) => l.companyId.equals('zain'))).get();

    final consumed = lines.fold(0.0, (sum, l) => sum + l.wholesaleCost);
    final totalShipped = shipments.fold(0.0, (sum, s) => sum + s.totalAmount);
    final availableToSell = (totalShipped - consumed).clamp(0, double.infinity).toDouble();
    final owedToCompany = shipments.fold(0.0, (sum, s) => sum + (s.totalAmount - s.amountPaid).clamp(0, double.infinity));
    final profitGenerated = lines.fold(0.0, (sum, l) => sum + l.profit);

    expect(consumed, 120);
    expect(totalShipped, 700);
    expect(availableToSell, 580); // 700 shipped - 120 consumed
    expect(owedToCompany, 150); // unpaid part of ship-2 only
    expect(profitGenerated, 60);
  });
}

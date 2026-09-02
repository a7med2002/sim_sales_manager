import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sim_sales_manager/core/database/app_database.dart';

/// Smoke test for the multi-tenant Drift schema (Phase 2 of the
/// multi-tenant/admin architecture — see design/APP_CONTEXT.md). Not
/// exhaustive per-table coverage; just confirms the schema actually
/// opens and that a catalog row + a tenant-scoped row referencing it
/// round-trip correctly, since that's the one relationship every
/// feature migration will depend on.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('inserts a catalog company and a seller-scoped shipment against it', () async {
    final now = DateTime.now();

    await db.into(db.companyCatalogTable).insert(
      CompanyCatalogTableCompanion.insert(
        id: 'company-1',
        name: 'Zain',
        createdAt: now,
        updatedAt: now,
      ),
    );

    await db.into(db.shipmentsTable).insert(
      ShipmentsTableCompanion.insert(
        id: 'shipment-1',
        ownerId: 'seller-1',
        companyCatalogId: 'company-1',
        type: 'prepaid',
        shipmentDate: now,
        updatedAt: now,
      ),
    );

    final shipments = await db.select(db.shipmentsTable).get();
    expect(shipments, hasLength(1));
    expect(shipments.single.ownerId, 'seller-1');
    expect(shipments.single.companyCatalogId, 'company-1');
    expect(shipments.single.synced, isTrue);
  });

  test('two sellers can each have their own seller_companies row for the same catalog company', () async {
    final now = DateTime.now();
    await db.into(db.companyCatalogTable).insert(
      CompanyCatalogTableCompanion.insert(id: 'company-1', name: 'Umniah', createdAt: now, updatedAt: now),
    );

    await db.into(db.sellerCompaniesTable).insert(
      SellerCompaniesTableCompanion.insert(id: 'sc-1', ownerId: 'seller-a', companyCatalogId: 'company-1', updatedAt: now),
    );
    await db.into(db.sellerCompaniesTable).insert(
      SellerCompaniesTableCompanion.insert(
        id: 'sc-2',
        ownerId: 'seller-b',
        companyCatalogId: 'company-1',
        updatedAt: now,
        pinned: const Value(true),
      ),
    );

    final rows = await db.select(db.sellerCompaniesTable).get();
    expect(rows, hasLength(2));
    expect(rows.where((r) => r.ownerId == 'seller-a').single.pinned, isFalse);
    expect(rows.where((r) => r.ownerId == 'seller-b').single.pinned, isTrue);
  });
}

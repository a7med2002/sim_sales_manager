import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';

/// Push/pull between the local Drift database and Supabase.
///
/// **Catalog** (`company_catalog`/`package_catalog`): read-only pull —
/// sellers never write it, admins write it directly via Supabase and it
/// flows down here like any other pull.
///
/// **Tenant tables** (`companies`/`packages`/`customers`/`lines`/
/// `shipments`/`settings` so far — more get added
/// here one at a time as each feature migrates off mock data, see
/// PROGRESS.md "Next"): push rows with `synced = false` via `upsert`,
/// then mark them synced locally; pull replaces local rows with
/// whatever the server has for this owner. **Simplification, on
/// purpose** (per CLAUDE.md: don't over-engineer conflict resolution) —
/// push always runs before pull in [syncAll], so by the time pull runs
/// this device's own edits are already reflected server-side; there's no
/// separate `updated_at` comparison on pull, and no tombstone tracking
/// for permanent deletes made on *another* device (a row deleted
/// elsewhere while this device was offline will reappear on next pull —
/// acceptable for a single-seller-across-devices scenario, revisit if
/// that turns out to matter in practice).
class SyncEngine {
  final SupabaseClient _client;
  final AppDatabase _db;

  SyncEngine(this._client, this._db);

  /// Runs a full sync for [ownerId]: catalog pull, then push/pull for
  /// every tenant table currently migrated. Companies before packages
  /// (packages reference companies by id); customers before lines (lines
  /// reference both a customer and a company).
  Future<void> syncAll(String ownerId) async {
    await pullCatalog();
    await pushPendingCompanies(ownerId);
    await pushPendingPackages(ownerId);
    await pushPendingCustomers(ownerId);
    await pushPendingLines(ownerId);
    await pushPendingShipments(ownerId);
    await pushPendingSettings(ownerId);
    await pullCompanies(ownerId);
    await pullPackages(ownerId);
    await pullCustomers(ownerId);
    await pullLines(ownerId);
    await pushPendingActivityLog(ownerId);
    await pushPendingSupportRequests(ownerId);
    await pushPendingNumberUpdateLog(ownerId);
    await pullShipments(ownerId);
    await pullSettings(ownerId);
    await pullActivityLog(ownerId);
    await pullSupportRequests(ownerId);
    await pullNumberUpdateLog(ownerId);
  }

  /// Pulls the full company/package catalog. Small, shared, admin-edited
  /// rarely — a full replace on every sync is simpler and cheap enough to
  /// not need incremental `updated_at` filtering yet.
  Future<void> pullCatalog() async {
    final companies = await _client.from('company_catalog').select();
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _db.companyCatalogTable,
        companies.map(_catalogCompanyFromRow).toList(),
      );
    });

    final packages = await _client.from('package_catalog').select();
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _db.packageCatalogTable,
        packages.map(_catalogPackageFromRow).toList(),
      );
    });
  }

  // ── companies ─────────────────────────────────────────────────────────

  Future<void> pushPendingCompanies(String ownerId) async {
    final pending = await (_db.select(_db.companiesTable)
          ..where((t) => t.ownerId.equals(ownerId) & t.synced.equals(false)))
        .get();
    if (pending.isEmpty) return;

    await _client.from('companies').upsert(pending.map(_companyToRow).toList());

    for (final row in pending) {
      await (_db.update(_db.companiesTable)..where((t) => t.id.equals(row.id)))
          .write(const CompaniesTableCompanion(synced: Value(true)));
    }
  }

  Future<void> pullCompanies(String ownerId) async {
    final rows = await _client.from('companies').select().eq('owner_id', ownerId);
    if (rows.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.companiesTable, rows.map(_companyFromRow).toList());
    });
  }

  /// Deletes a company on the server directly (not via the `synced`
  /// queue — a permanent delete removes the local row entirely, so
  /// there'd be nothing left to "push"). Packages cascade automatically
  /// server-side (`ON DELETE CASCADE`); the caller is responsible for
  /// deleting the local package rows too, since Drift doesn't cascade.
  Future<void> deleteCompanyRemote(String id) => _client.from('companies').delete().eq('id', id);

  Map<String, dynamic> _companyToRow(CompaniesTableData c) => {
        'id': c.id,
        'owner_id': c.ownerId,
        'name': c.name,
        'logo_url': c.logoUrl,
        'notes': c.notes,
        'status': c.status,
        'pinned': c.pinned,
        'catalog_company_id': c.catalogCompanyId,
        'number_update_provider': c.numberUpdateProvider,
        'updated_at': c.updatedAt.toIso8601String(),
      };

  CompaniesTableCompanion _companyFromRow(Map<String, dynamic> row) {
    return CompaniesTableCompanion.insert(
      id: row['id'] as String,
      ownerId: row['owner_id'] as String,
      name: row['name'] as String,
      logoUrl: Value(row['logo_url'] as String?),
      notes: Value(row['notes'] as String?),
      status: Value(row['status'] as String? ?? 'active'),
      pinned: Value(row['pinned'] as bool? ?? false),
      catalogCompanyId: Value(row['catalog_company_id'] as String?),
      numberUpdateProvider: Value(row['number_update_provider'] as String?),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  // ── packages ──────────────────────────────────────────────────────────

  Future<void> pushPendingPackages(String ownerId) async {
    final pending = await (_db.select(_db.packagesTable)
          ..where((t) => t.ownerId.equals(ownerId) & t.synced.equals(false)))
        .get();
    if (pending.isEmpty) return;

    await _client.from('packages').upsert(pending.map(_packageToRow).toList());

    for (final row in pending) {
      await (_db.update(_db.packagesTable)..where((t) => t.id.equals(row.id)))
          .write(const PackagesTableCompanion(synced: Value(true)));
    }
  }

  Future<void> pullPackages(String ownerId) async {
    final rows = await _client.from('packages').select().eq('owner_id', ownerId);
    if (rows.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.packagesTable, rows.map(_packageFromRow).toList());
    });
  }

  Map<String, dynamic> _packageToRow(PackagesTableData p) => {
        'id': p.id,
        'owner_id': p.ownerId,
        'company_id': p.companyId,
        'name': p.name,
        'wholesale_cost': p.wholesaleCost,
        'retail_price': p.retailPrice,
        'updated_at': p.updatedAt.toIso8601String(),
      };

  PackagesTableCompanion _packageFromRow(Map<String, dynamic> row) {
    return PackagesTableCompanion.insert(
      id: row['id'] as String,
      ownerId: row['owner_id'] as String,
      companyId: row['company_id'] as String,
      name: row['name'] as String,
      wholesaleCost: Value((row['wholesale_cost'] as num).toDouble()),
      retailPrice: Value((row['retail_price'] as num).toDouble()),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  // ── customers ─────────────────────────────────────────────────────────

  Future<void> pushPendingCustomers(String ownerId) async {
    final pending = await (_db.select(_db.customersTable)
          ..where((t) => t.ownerId.equals(ownerId) & t.synced.equals(false)))
        .get();
    if (pending.isEmpty) return;

    await _client.from('customers').upsert(pending.map(_customerToRow).toList());

    for (final row in pending) {
      await (_db.update(_db.customersTable)..where((t) => t.id.equals(row.id)))
          .write(const CustomersTableCompanion(synced: Value(true)));
    }
  }

  Future<void> pullCustomers(String ownerId) async {
    final rows = await _client.from('customers').select().eq('owner_id', ownerId);
    if (rows.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.customersTable, rows.map(_customerFromRow).toList());
    });
  }

  Future<void> deleteCustomerRemote(String id) => _client.from('customers').delete().eq('id', id);

  Map<String, dynamic> _customerToRow(CustomersTableData c) => {
        'id': c.id,
        'owner_id': c.ownerId,
        'name': c.name,
        'contact_number': c.contactNumber,
        'status': c.status,
        // Local storage is a comma-joined string (see tables/customers_table.dart);
        // Postgres' column is a real `text[]`, so this is the one spot that
        // has to convert between the two representations.
        'tags': c.tags.isEmpty ? const <String>[] : c.tags.split(','),
        'pinned': c.pinned,
        'notes': c.notes,
        'deleted': c.deleted,
        'updated_at': c.updatedAt.toIso8601String(),
      };

  CustomersTableCompanion _customerFromRow(Map<String, dynamic> row) {
    final tags = (row['tags'] as List?)?.cast<String>() ?? const <String>[];
    return CustomersTableCompanion.insert(
      id: row['id'] as String,
      ownerId: row['owner_id'] as String,
      name: row['name'] as String,
      contactNumber: row['contact_number'] as String,
      status: Value(row['status'] as String? ?? 'normal'),
      tags: Value(tags.join(',')),
      pinned: Value(row['pinned'] as bool? ?? false),
      notes: Value(row['notes'] as String?),
      deleted: Value(row['deleted'] as bool? ?? false),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  // ── lines ─────────────────────────────────────────────────────────────

  Future<void> pushPendingLines(String ownerId) async {
    final pending = await (_db.select(_db.linesTable)
          ..where((t) => t.ownerId.equals(ownerId) & t.synced.equals(false)))
        .get();
    if (pending.isEmpty) return;

    await _client.from('lines').upsert(pending.map(_lineToRow).toList());

    for (final row in pending) {
      await (_db.update(_db.linesTable)..where((t) => t.id.equals(row.id)))
          .write(const LinesTableCompanion(synced: Value(true)));
    }
  }

  Future<void> pullLines(String ownerId) async {
    final rows = await _client.from('lines').select().eq('owner_id', ownerId);
    if (rows.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.linesTable, rows.map(_lineFromRow).toList());
    });
  }

  Future<void> deleteLineRemote(String id) => _client.from('lines').delete().eq('id', id);

  Map<String, dynamic> _lineToRow(LinesTableData l) => {
        'id': l.id,
        'owner_id': l.ownerId,
        'customer_id': l.customerId,
        'company_id': l.companyId,
        'package_id': l.packageId,
        'sim_number': l.simNumber,
        'purchase_date': l.purchaseDate.toIso8601String(),
        'expiry_date': l.expiryDate.toIso8601String(),
        'wholesale_cost': l.wholesaleCost,
        'retail_price': l.retailPrice,
        'profit': l.profit,
        'payment_status': l.paymentStatus,
        'amount_paid': l.amountPaid,
        'amount_remaining': l.amountRemaining,
        'updated_at': l.updatedAt.toIso8601String(),
      };

  LinesTableCompanion _lineFromRow(Map<String, dynamic> row) {
    return LinesTableCompanion.insert(
      id: row['id'] as String,
      ownerId: row['owner_id'] as String,
      customerId: row['customer_id'] as String,
      companyId: row['company_id'] as String,
      packageId: Value(row['package_id'] as String?),
      simNumber: row['sim_number'] as String,
      purchaseDate: DateTime.parse(row['purchase_date'] as String),
      expiryDate: DateTime.parse(row['expiry_date'] as String),
      wholesaleCost: Value((row['wholesale_cost'] as num).toDouble()),
      retailPrice: Value((row['retail_price'] as num).toDouble()),
      profit: Value((row['profit'] as num).toDouble()),
      paymentStatus: Value(row['payment_status'] as String? ?? 'unpaid'),
      amountPaid: Value((row['amount_paid'] as num).toDouble()),
      amountRemaining: Value((row['amount_remaining'] as num).toDouble()),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  // ── shipments ─────────────────────────────────────────────────────────

  Future<void> pushPendingShipments(String ownerId) async {
    final pending = await (_db.select(_db.shipmentsTable)
          ..where((t) => t.ownerId.equals(ownerId) & t.synced.equals(false)))
        .get();
    if (pending.isEmpty) return;

    await _client.from('shipments').upsert(pending.map(_shipmentToRow).toList());

    for (final row in pending) {
      await (_db.update(_db.shipmentsTable)..where((t) => t.id.equals(row.id)))
          .write(const ShipmentsTableCompanion(synced: Value(true)));
    }
  }

  Future<void> pullShipments(String ownerId) async {
    final rows = await _client.from('shipments').select().eq('owner_id', ownerId);
    if (rows.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.shipmentsTable, rows.map(_shipmentFromRow).toList());
    });
  }

  Map<String, dynamic> _shipmentToRow(ShipmentsTableData s) => {
        'id': s.id,
        'owner_id': s.ownerId,
        'company_id': s.companyId,
        'type': s.type,
        'total_amount': s.totalAmount,
        'amount_paid': s.amountPaid,
        'amount_remaining': s.amountRemaining,
        'payment_method': s.paymentMethod,
        'reference_number': s.referenceNumber,
        'shipment_date': s.shipmentDate.toIso8601String(),
        'notes': s.notes,
        'updated_at': s.updatedAt.toIso8601String(),
      };

  ShipmentsTableCompanion _shipmentFromRow(Map<String, dynamic> row) {
    return ShipmentsTableCompanion.insert(
      id: row['id'] as String,
      ownerId: row['owner_id'] as String,
      companyId: row['company_id'] as String,
      type: row['type'] as String,
      totalAmount: Value((row['total_amount'] as num).toDouble()),
      amountPaid: Value((row['amount_paid'] as num).toDouble()),
      amountRemaining: Value((row['amount_remaining'] as num).toDouble()),
      paymentMethod: Value(row['payment_method'] as String?),
      referenceNumber: Value(row['reference_number'] as String?),
      shipmentDate: DateTime.parse(row['shipment_date'] as String),
      notes: Value(row['notes'] as String?),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  // ── settings ──────────────────────────────────────────────────────────
  // One row per owner (the primary key *is* `owner_id`), so this is
  // simpler than the others: no per-row loop, just a single upsert/read.

  Future<void> pushPendingSettings(String ownerId) async {
    final row = await (_db.select(_db.settingsTable)..where((t) => t.ownerId.equals(ownerId) & t.synced.equals(false)))
        .getSingleOrNull();
    if (row == null) return;

    await _client.from('settings').upsert(_settingsToRow(row));
    await (_db.update(_db.settingsTable)..where((t) => t.ownerId.equals(ownerId)))
        .write(const SettingsTableCompanion(synced: Value(true)));
  }

  Future<void> pullSettings(String ownerId) async {
    final rows = await _client.from('settings').select().eq('owner_id', ownerId);
    if (rows.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.settingsTable, rows.map(_settingsFromRow).toList());
    });
  }

  Map<String, dynamic> _settingsToRow(SettingsTableData s) => {
        'owner_id': s.ownerId,
        'currency_symbol': s.currencySymbol,
        'theme_preference': s.themePreference,
        'updated_at': s.updatedAt.toIso8601String(),
      };

  SettingsTableCompanion _settingsFromRow(Map<String, dynamic> row) {
    return SettingsTableCompanion.insert(
      ownerId: row['owner_id'] as String,
      currencySymbol: Value(row['currency_symbol'] as String? ?? '₪'),
      themePreference: Value(row['theme_preference'] as String? ?? 'system'),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  // ── support requests ──────────────────────────────────────────────────
  // Append-only, same shape as activity log — a submitted request is
  // never edited locally afterward. `attachment_url`/`voice_note_url`
  // hold a `support-attachments` Storage object path (not a public URL —
  // the bucket is private), uploaded by `SupportFeedbackCubit` before
  // this table row is even written; this push/pull just carries whatever
  // path ends up in the local row, same as any other column.

  Future<void> pushPendingSupportRequests(String ownerId) async {
    final pending = await (_db.select(_db.supportRequestsTable)
          ..where((t) => t.ownerId.equals(ownerId) & t.synced.equals(false)))
        .get();
    if (pending.isEmpty) return;

    await _client.from('support_requests').upsert(pending.map(_supportRequestToRow).toList());

    for (final row in pending) {
      await (_db.update(_db.supportRequestsTable)..where((t) => t.id.equals(row.id)))
          .write(const SupportRequestsTableCompanion(synced: Value(true)));
    }
  }

  Future<void> pullSupportRequests(String ownerId) async {
    final rows = await _client.from('support_requests').select().eq('owner_id', ownerId);
    if (rows.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.supportRequestsTable, rows.map(_supportRequestFromRow).toList());
    });
  }

  Map<String, dynamic> _supportRequestToRow(SupportRequestsTableData s) => {
        'id': s.id,
        'owner_id': s.ownerId,
        'type': s.type,
        'body': s.body,
        'attachment_url': s.attachmentUrl,
        'voice_note_url': s.voiceNoteUrl,
        'created_at': s.createdAt.toIso8601String(),
        'updated_at': s.updatedAt.toIso8601String(),
      };

  SupportRequestsTableCompanion _supportRequestFromRow(Map<String, dynamic> row) {
    return SupportRequestsTableCompanion.insert(
      id: row['id'] as String,
      ownerId: row['owner_id'] as String,
      type: row['type'] as String,
      body: row['body'] as String,
      attachmentUrl: Value(row['attachment_url'] as String?),
      voiceNoteUrl: Value(row['voice_note_url'] as String?),
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  // ── activity log ──────────────────────────────────────────────────────
  // Append-only audit trail (see `ActivityLogger`) — no local update
  // path once a row is written, so push is a plain insert-if-pending
  // rather than an upsert-and-mark-synced-in-place like every other
  // table; pull is still a full replace-by-owner, same as the rest.

  Future<void> pushPendingActivityLog(String ownerId) async {
    final pending = await (_db.select(_db.activityLogTable)
          ..where((t) => t.ownerId.equals(ownerId) & t.synced.equals(false)))
        .get();
    if (pending.isEmpty) return;

    await _client.from('activity_log').upsert(pending.map(_activityLogToRow).toList());

    for (final row in pending) {
      await (_db.update(_db.activityLogTable)..where((t) => t.id.equals(row.id)))
          .write(const ActivityLogTableCompanion(synced: Value(true)));
    }
  }

  Future<void> pullActivityLog(String ownerId) async {
    final rows = await _client.from('activity_log').select().eq('owner_id', ownerId);
    if (rows.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.activityLogTable, rows.map(_activityLogFromRow).toList());
    });
  }

  Map<String, dynamic> _activityLogToRow(ActivityLogTableData a) => {
        'id': a.id,
        'owner_id': a.ownerId,
        'occurred_at': a.occurredAt.toIso8601String(),
        'action_type': a.actionType,
        'details': a.details,
        'updated_at': a.updatedAt.toIso8601String(),
      };

  ActivityLogTableCompanion _activityLogFromRow(Map<String, dynamic> row) {
    return ActivityLogTableCompanion.insert(
      id: row['id'] as String,
      ownerId: row['owner_id'] as String,
      occurredAt: DateTime.parse(row['occurred_at'] as String),
      actionType: row['action_type'] as String,
      details: Value(row['details'] as String?),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  // ── number update log ────────────────────────────────────────────────
  // Append-only, same shape as activity log — one row per Number Update
  // attempt (see `NumberUpdateCubit`), never edited locally afterward.

  Future<void> pushPendingNumberUpdateLog(String ownerId) async {
    final pending = await (_db.select(_db.numberUpdateLogTable)
          ..where((t) => t.ownerId.equals(ownerId) & t.synced.equals(false)))
        .get();
    if (pending.isEmpty) return;

    await _client.from('number_update_log').upsert(pending.map(_numberUpdateLogToRow).toList());

    for (final row in pending) {
      await (_db.update(_db.numberUpdateLogTable)..where((t) => t.id.equals(row.id)))
          .write(const NumberUpdateLogTableCompanion(synced: Value(true)));
    }
  }

  Future<void> pullNumberUpdateLog(String ownerId) async {
    final rows = await _client.from('number_update_log').select().eq('owner_id', ownerId);
    if (rows.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.numberUpdateLogTable, rows.map(_numberUpdateLogFromRow).toList());
    });
  }

  Map<String, dynamic> _numberUpdateLogToRow(NumberUpdateLogTableData n) => {
        'id': n.id,
        'owner_id': n.ownerId,
        'phone_number': n.phoneNumber,
        'status': n.status,
        'message': n.message,
        'created_at': n.createdAt.toIso8601String(),
        'updated_at': n.updatedAt.toIso8601String(),
      };

  NumberUpdateLogTableCompanion _numberUpdateLogFromRow(Map<String, dynamic> row) {
    return NumberUpdateLogTableCompanion.insert(
      id: row['id'] as String,
      ownerId: row['owner_id'] as String,
      phoneNumber: row['phone_number'] as String,
      status: row['status'] as String,
      message: row['message'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  // ── catalog row mapping ──────────────────────────────────────────────

  CompanyCatalogTableCompanion _catalogCompanyFromRow(Map<String, dynamic> row) {
    return CompanyCatalogTableCompanion.insert(
      id: row['id'] as String,
      name: row['name'] as String,
      logoUrl: Value(row['logo_url'] as String?),
      notes: Value(row['notes'] as String?),
      numberUpdateUrl: Value(row['number_update_url'] as String?),
      numberUpdateProvider: Value(row['number_update_provider'] as String?),
      status: Value(row['status'] as String? ?? 'active'),
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  PackageCatalogTableCompanion _catalogPackageFromRow(Map<String, dynamic> row) {
    return PackageCatalogTableCompanion.insert(
      id: row['id'] as String,
      companyCatalogId: row['company_catalog_id'] as String,
      name: row['name'] as String,
      wholesaleCost: Value((row['wholesale_cost'] as num).toDouble()),
      suggestedRetailPrice: Value((row['suggested_retail_price'] as num).toDouble()),
      status: Value(row['status'] as String? ?? 'active'),
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }
}

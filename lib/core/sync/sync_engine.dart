import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';

/// Push/pull between the local Drift database and Supabase. Currently
/// covers the shared company/package catalog end-to-end (read-only pull —
/// sellers never write it, admins write it directly via Supabase and it
/// flows down here like any other pull). Tenant-scoped tables
/// (customers, lines, shipments, ...) get their push/pull methods added
/// here one at a time as each feature migrates off mock data (see
/// PROGRESS.md "Next" — Phase 3), following the same shape: filter by
/// `synced = false` to push, upsert-by-`updated_at` to pull.
class SyncEngine {
  final SupabaseClient _client;
  final AppDatabase _db;

  SyncEngine(this._client, this._db);

  /// Pulls the full company/package catalog. Small, shared, admin-edited
  /// rarely — a full replace on every sync is simpler and cheap enough to
  /// not need incremental `updated_at` filtering yet.
  Future<void> pullCatalog() async {
    final companies = await _client.from('company_catalog').select();
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _db.companyCatalogTable,
        companies.map(_companyFromRow).toList(),
      );
    });

    final packages = await _client.from('package_catalog').select();
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _db.packageCatalogTable,
        packages.map(_packageFromRow).toList(),
      );
    });
  }

  CompanyCatalogTableCompanion _companyFromRow(Map<String, dynamic> row) {
    return CompanyCatalogTableCompanion.insert(
      id: row['id'] as String,
      name: row['name'] as String,
      logoUrl: Value(row['logo_url'] as String?),
      notes: Value(row['notes'] as String?),
      numberUpdateUrl: Value(row['number_update_url'] as String?),
      status: Value(row['status'] as String? ?? 'active'),
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  PackageCatalogTableCompanion _packageFromRow(Map<String, dynamic> row) {
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

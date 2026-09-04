import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

import 'tables/activity_log_table.dart';
import 'tables/catalog_tables.dart';
import 'tables/companies_table.dart';
import 'tables/customers_table.dart';
import 'tables/lines_table.dart';
import 'tables/operations_table.dart';
import 'tables/packages_table.dart';
import 'tables/settings_table.dart';
import 'tables/shipments_table.dart';
import 'tables/support_requests_table.dart';
import 'tables/trusted_devices_table.dart';

part 'app_database.g.dart';

/// The offline-first source of truth (CLAUDE.md) — every feature reads
/// and writes here first; the sync engine in `core/sync/` reconciles this
/// with Supabase in the background. One database file per device install,
/// holding whichever single account is currently logged in plus a
/// read-only mirror of the shared company/package catalog.
@DriftDatabase(
  tables: [
    CompanyCatalogTable,
    PackageCatalogTable,
    CompaniesTable,
    PackagesTable,
    CustomersTable,
    ShipmentsTable,
    LinesTable,
    OperationsTable,
    ActivityLogTable,
    TrustedDevicesTable,
    SupportRequestsTable,
    SettingsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}

QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File('${dbFolder.path}${Platform.pathSeparator}sim_sales_manager.sqlite');
    return NativeDatabase.createInBackground(file);
  });
}

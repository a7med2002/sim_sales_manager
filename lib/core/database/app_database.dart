import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

import 'tables/activity_log_table.dart';
import 'tables/catalog_tables.dart';
import 'tables/companies_table.dart';
import 'tables/customers_table.dart';
import 'tables/lines_table.dart';
import 'tables/number_update_log_table.dart';
import 'tables/number_update_provider_cache_table.dart';
import 'tables/operations_table.dart';
import 'tables/packages_table.dart';
import 'tables/pending_deletes_table.dart';
import 'tables/settings_table.dart';
import 'tables/shipments_table.dart';
import 'tables/support_requests_table.dart';

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
    SupportRequestsTable,
    SettingsTable,
    NumberUpdateLogTable,
    NumberUpdateProviderCacheTable,
    PendingDeletesTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  // `schemaVersion` sat at 1 for this app's entire build-out even as
  // columns/tables kept getting added — meaning a device that installed
  // the app early (this app's only real device so far) never actually
  // got those additions applied to its physical SQLite file: Drift only
  // runs `onCreate`/`onUpgrade` when the declared version changes, and
  // it never did. The generated code (this file) always reflects the
  // *current* schema regardless, so every app rebuild silently drifted
  // further from what was actually sitting on disk — until a query
  // finally touched one of the missing pieces and failed outright
  // (surfacing as sync going straight to its error state on every
  // retry: the local `companies` SELECT/INSERT itself was throwing
  // "no such column", so nothing — including an unsynced local change
  // like a freshly-picked logo — ever got as far as attempting the
  // network call).
  //
  // Bumping to 2 and adding exactly the pieces introduced since v1
  // heals an existing install without touching any data already
  // there (including anything still only-local and unsynced) — this is
  // additive only, nothing here can lose data.
  @override
  int get schemaVersion => 10;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) => m.createAll(),
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.addColumn(companiesTable, companiesTable.numberUpdateProvider);
            await m.addColumn(companiesTable, companiesTable.numberUpdateUrl);
            await m.addColumn(companyCatalogTable, companyCatalogTable.numberUpdateProvider);
            await m.createTable(numberUpdateLogTable);
          }
          if (from < 3) {
            // See lines_table.dart's doc comment on these columns for
            // why a Line needs its own frozen company/package name
            // snapshot instead of always live-joining the current
            // Companies list.
            await m.addColumn(linesTable, linesTable.companyName);
            await m.addColumn(linesTable, linesTable.companyInitials);
            await m.addColumn(linesTable, linesTable.packageName);
          }
          if (from < 4) {
            // See settings_table.dart's doc comment on this column —
            // a local-only cache, nothing to add server-side.
            await m.addColumn(settingsTable, settingsTable.cachedDisplayName);
          }
          if (from < 5) {
            // See number_update_provider_cache_table.dart's doc comment —
            // remembers which supplier a number matched last time.
            await m.createTable(numberUpdateProviderCacheTable);
          }
          if (from < 6) {
            // "SIM type" — see CompanyPackage's doc comment.
            await m.addColumn(packagesTable, packagesTable.simType);
            await m.addColumn(packageCatalogTable, packageCatalogTable.simType);
            await m.addColumn(linesTable, linesTable.packageSimType);
          }
          if (from < 7) {
            // `lines.companyId` NOT NULL -> nullable — see
            // lines_table.dart's doc comment: a permanently-deleted
            // company now detaches from its historical Lines instead of
            // deleting them. SQLite can't ALTER a column's nullability
            // directly, so this recreates the table per Drift's own
            // 12-step procedure (`alterTable`) — existing data is
            // preserved, nothing here can lose rows.
            await m.alterTable(TableMigration(linesTable));
          }
          if (from < 8) {
            // See pending_deletes_table.dart's doc comment — tombstones
            // a permanent delete until its remote counterpart is
            // confirmed, so a pull that races ahead of it can't
            // resurrect the row.
            await m.createTable(pendingDeletesTable);
          }
          if (from < 9) {
            // See settings_table.dart's doc comment on `cachedRole` —
            // lets a cold app start route a signed-in admin to the
            // right shell while offline, instead of only being able to
            // find that out with a network call.
            await m.addColumn(settingsTable, settingsTable.cachedRole);
          }
          if (from < 10) {
            // See companies_table.dart's doc comment on
            // allowNegativeBalance — the "allow negative balance"
            // per-company opt-in.
            await m.addColumn(companiesTable, companiesTable.allowNegativeBalance);
          }
        },
      );
}

QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File('${dbFolder.path}${Platform.pathSeparator}sim_sales_manager.sqlite');
    return NativeDatabase.createInBackground(file);
  });
}

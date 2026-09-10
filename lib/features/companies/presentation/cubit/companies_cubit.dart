import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/activity_log/activity_action_type.dart';
import '../../../../core/activity_log/activity_logger.dart';
import '../../../../core/auth/auth_service.dart';
import '../../../../core/catalog/company_catalog.dart';
import '../../../../core/catalog/company_summary.dart';
import '../../../../core/config/env.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/number_update/number_update_provider.dart';
import '../../../../core/sync/connectivity_service.dart';
import '../../../../core/sync/sync_engine.dart';
import '../../../../core/utils/uuid.dart';
import '../../domain/entities/company.dart';
import '../../domain/entities/company_package.dart';
import '../../domain/entities/preset_company.dart';
import 'companies_state.dart';

/// Companies — the first feature migrated off mock data (Phase 3 of the
/// multi-tenant/admin architecture, see design/APP_CONTEXT.md). When a
/// real Supabase project is configured and a seller is signed in
/// (`Env.isConfigured` + `AuthService.currentOwnerId`), the list loads
/// from and writes to local Drift: `companies`/`packages` — each
/// seller's own, fully-owned records. **A seller can freely add and edit
/// their own companies**, exactly like the original single-user design;
/// "Import Ready-Made" is only a convenience that copies a company/its
/// packages from the shared, admin-curated `company_catalog`/
/// `package_catalog` once, to save re-typing — it is *not* a live link.
/// Editing an imported company afterward never touches the catalog, and
/// an admin editing the catalog never touches companies already
/// imported from it. `Company.catalogCompanyId` records where an import
/// came from, purely so the import sheet can show "already imported" and
/// so the Numbers-update feature can look up that catalog entry's
/// `number_update_url`.
///
/// Without a configured project (or before this Cubit's owner is known),
/// it falls back to the original in-memory mock list so the app/demo
/// still works offline — same conditional pattern as `LoginCubit`.
///
/// Real mode actually reaches Supabase, not just local Drift: on
/// creation this Cubit runs `SyncEngine.syncAll` (push local
/// `synced = false` rows, then pull the server's rows for this owner)
/// before loading `state`, and every write also fires a best-effort push
/// afterward (`_pushBestEffort`) so changes reach the server promptly.
/// A failed sync/push (offline, transient error) never blocks the UI —
/// it just leaves rows `synced = false` for the next successful sync to
/// pick up, per CLAUDE.md's offline-first rule.
///
/// Balance/stats fields (consumed, availableToSell, owedToCompany,
/// profitGenerated, operationsCount, usagePercent) are **derived**, not
/// stored — `_loadFromDrift` computes them by summing this company's
/// real `lines`/`shipments` rows every time it runs (see its own doc
/// comment). `recordSale`/`addShipment` still also apply an optimistic
/// in-memory mutation for instant feedback the moment a sale/shipment
/// happens, but that's just a same-session approximation — the next
/// reload always recomputes from what's actually persisted, so it can't
/// drift permanently.
class CompaniesCubit extends Cubit<CompaniesState> implements CompanyCatalog {
  final AppDatabase? _db;
  final AuthService? _auth;
  final SyncEngine? _syncEngine;
  final ConnectivityService? _connectivity;

  CompaniesCubit({AppDatabase? db, AuthService? auth, SyncEngine? syncEngine, ConnectivityService? connectivity})
    : _db = _resolveDb(db),
      _auth = _resolveAuth(auth),
      _syncEngine = syncEngine ?? (Env.isConfigured ? getIt<SyncEngine>() : null),
      _connectivity = connectivity ?? getIt<ConnectivityService>(),
      super(const CompaniesState()) {
    if (_db != null && _auth?.currentOwnerId != null) {
      _syncThenLoad();
    }
  }

  static AppDatabase? _resolveDb(AppDatabase? db) => db ?? (Env.isConfigured ? getIt<AppDatabase>() : null);
  static AuthService? _resolveAuth(AuthService? auth) => auth ?? (Env.isConfigured ? getIt<AuthService>() : null);

  bool get _isReal => _db != null && _auth?.currentOwnerId != null;

  /// Pulls/pushes with Supabase before loading `state` from Drift, so the
  /// list reflects the server the moment this Cubit is created (e.g.
  /// another device's changes). Best-effort: a failed sync (offline,
  /// transient error) just falls back to whatever's already local —
  /// never blocks the UI on network. Checking connectivity first (a
  /// cheap, instant OS-level flag) skips even attempting the network
  /// call while offline — without it, this waited out a multi-second
  /// connect/DNS timeout before falling back every single time.
  Future<void> _syncThenLoad() async {
    final engine = _syncEngine;
    final ownerId = _auth?.currentOwnerId;
    if (engine != null && ownerId != null && await (_connectivity?.isOnline ?? Future.value(true))) {
      try {
        await engine.syncAll(ownerId);
      } catch (_) {
        // Offline or transient failure — proceed with local data.
      }
    }
    await _loadFromDrift();
  }

  /// Fire-and-forget push after a local write, so changes reach Supabase
  /// promptly instead of waiting for the next connectivity-triggered
  /// sync. Failures are swallowed — the row stays `synced = false`
  /// locally and gets picked up by the next successful sync.
  Future<void> _pushBestEffort() async {
    final engine = _syncEngine;
    final ownerId = _auth?.currentOwnerId;
    if (engine == null || ownerId == null) return;
    try {
      await engine.pushPendingCompanies(ownerId);
      await engine.pushPendingPackages(ownerId);
    } catch (_) {
      // Offline or transient failure — next sync cycle will retry.
    }
  }

  /// Loads companies + their balance/stats from Drift. Balance fields
  /// (`consumed`/`availableToSell`/`owedToCompany`/`profitGenerated`/
  /// `operationsCount`/`usagePercent`) are **derived** here by summing
  /// this company's real `lines`/`shipments` rows — not read from a
  /// stored field, since none exists (a company row only carries its own
  /// identity/status). This makes them durable and self-correcting: even
  /// though `recordSale`/`addShipment` below still also apply an
  /// optimistic in-memory mutation for instant UI feedback (the
  /// underlying Line/Shipment write they're paired with is
  /// fire-and-forget, so there's no reliable moment to await before
  /// recomputing), the *next* `_loadFromDrift` — on app restart, or the
  /// next connectivity-triggered sync — always recomputes from what's
  /// actually persisted, so an imprecise optimistic guess can never
  /// drift permanently from reality.
  Future<void> _loadFromDrift() async {
    final db = _db!;
    final ownerId = _auth!.currentOwnerId!;

    final companyRows = await (db.select(db.companiesTable)..where((c) => c.ownerId.equals(ownerId))).get();
    final companyIds = companyRows.map((c) => c.id).toSet();
    final packageRows = companyIds.isEmpty
        ? <PackagesTableData>[]
        : await (db.select(db.packagesTable)..where((p) => p.companyId.isIn(companyIds))).get();
    final lineRows = companyIds.isEmpty
        ? <LinesTableData>[]
        : await (db.select(db.linesTable)..where((l) => l.ownerId.equals(ownerId) & l.companyId.isIn(companyIds))).get();
    final shipmentRows = companyIds.isEmpty
        ? <ShipmentsTableData>[]
        : await (db.select(db.shipmentsTable)..where((s) => s.ownerId.equals(ownerId) & s.companyId.isIn(companyIds))).get();

    final companies = companyRows.map((row) {
      final packages = packageRows
          .where((p) => p.companyId == row.id)
          .map((p) => CompanyPackage(id: p.id, name: p.name, simType: p.simType, wholesaleCost: p.wholesaleCost, retailPrice: p.retailPrice))
          .toList();

      final companyLines = lineRows.where((l) => l.companyId == row.id);
      final companyShipments = shipmentRows.where((s) => s.companyId == row.id);

      final consumed = companyLines.fold(0.0, (sum, l) => sum + l.wholesaleCost);
      final totalShipped = companyShipments.fold(0.0, (sum, s) => sum + s.totalAmount);
      // Clamped to zero unless this company opted into "allow negative
      // balance" (see companies_table.dart's doc comment) — without
      // that opt-in, consumption can never actually exceed shipments in
      // the first place (`NewSaleState.exceedsCompanyBalance` blocks
      // it), so the clamp is just a safety floor for that default case.
      final rawAvailable = totalShipped - consumed;
      final availableToSell = row.allowNegativeBalance ? rawAvailable : rawAvailable.clamp(0, double.infinity).toDouble();
      final owedToCompany = companyShipments.fold(0.0, (sum, s) => sum + (s.totalAmount - s.amountPaid).clamp(0, double.infinity));
      final profitGenerated = companyLines.fold(0.0, (sum, l) => sum + l.profit);
      final totalPool = consumed + availableToSell;
      final usagePercent = totalPool <= 0 ? 0 : ((consumed / totalPool) * 100).round();

      return Company(
        id: row.id,
        name: row.name,
        initials: _initialsFor(row.name),
        notes: row.notes ?? '',
        pinned: row.pinned,
        status: _statusFrom(row.status),
        packages: packages,
        catalogCompanyId: row.catalogCompanyId,
        numberUpdateProvider: numberUpdateProviderFromRow(row.numberUpdateProvider),
        logoUrl: row.logoUrl,
        numberUpdateUrl: row.numberUpdateUrl,
        consumed: consumed,
        availableToSell: availableToSell,
        owedToCompany: owedToCompany,
        profitGenerated: profitGenerated,
        operationsCount: companyLines.length,
        usagePercent: usagePercent,
        allowNegativeBalance: row.allowNegativeBalance,
      );
    }).toList();

    emit(state.copyWith(companies: companies));
  }

  /// Options offered in "Import Ready-Made": the shared catalog in real
  /// mode, the static preset list offline/in demo mode.
  Future<List<PresetCompany>> loadCatalogOptions() async {
    final db = _db;
    if (db == null) return const [];

    final catalogRows = await db.select(db.companyCatalogTable).get();
    final packageRows = await db.select(db.packageCatalogTable).get();
    return catalogRows
        .map((c) => PresetCompany(
              id: c.id,
              name: c.name,
              initials: _initialsFor(c.name),
              defaultPackages: packageRows
                  .where((p) => p.companyCatalogId == c.id)
                  .map((p) => CompanyPackage(id: p.id, name: p.name, simType: p.simType, wholesaleCost: p.wholesaleCost, retailPrice: p.suggestedRetailPrice))
                  .toList(),
              numberUpdateProvider: numberUpdateProviderFromRow(c.numberUpdateProvider),
              logoUrl: c.logoUrl,
              numberUpdateUrl: c.numberUpdateUrl,
            ))
        .toList();
  }

  void selectTab(CompanyStatus tab) {
    emit(state.copyWith(selectedTab: tab));
  }

  void addCompany({
    required String name,
    required String notes,
    required List<CompanyPackage> packages,
    NumberUpdateProviderKey? numberUpdateProvider,
    String? logoLocalPath,
    String? numberUpdateUrl,
    bool allowNegativeBalance = false,
  }) {
    getIt<ActivityLogger>().log(ActivityActionType.create, 'Added new company $name.');
    _insertCompany(
      name: name,
      notes: notes,
      packages: packages,
      catalogCompanyId: null,
      numberUpdateProvider: numberUpdateProvider,
      logoLocalPath: logoLocalPath,
      numberUpdateUrl: numberUpdateUrl,
      allowNegativeBalance: allowNegativeBalance,
    );
  }

  void updateCompany(
    String id, {
    required String name,
    required String notes,
    required List<CompanyPackage> packages,
    NumberUpdateProviderKey? numberUpdateProvider,
    String? logoLocalPath,
    bool removeLogo = false,
    String? numberUpdateUrl,
    bool allowNegativeBalance = false,
  }) {
    getIt<ActivityLogger>().log(ActivityActionType.edit, 'Updated company $name.');
    _updateCompanyAndPackages(
      id,
      name: name,
      notes: notes,
      packages: packages,
      numberUpdateProvider: numberUpdateProvider,
      logoLocalPath: logoLocalPath,
      removeLogo: removeLogo,
      numberUpdateUrl: numberUpdateUrl,
      allowNegativeBalance: allowNegativeBalance,
    );
  }

  void togglePin(String id) {
    final current = state.companies.firstWhere((c) => c.id == id);
    _updateCompanyRow(id, (c) => c.copyWith(pinned: Value(!current.pinned)));
  }

  void archive(String id) {
    final name = state.companies.firstWhere((c) => c.id == id).name;
    getIt<ActivityLogger>().log(ActivityActionType.edit, 'Archived company $name.');
    _updateCompanyRow(id, (c) => c.copyWith(status: const Value('archived')));
  }

  void restoreToActive(String id) {
    final name = state.companies.firstWhere((c) => c.id == id).name;
    getIt<ActivityLogger>().log(ActivityActionType.edit, 'Restored company $name.');
    _updateCompanyRow(id, (c) => c.copyWith(status: const Value('active')));
  }

  void softDelete(String id) {
    final name = state.companies.firstWhere((c) => c.id == id).name;
    getIt<ActivityLogger>().log(ActivityActionType.delete, 'Deleted company $name.');
    _updateCompanyRow(id, (c) => c.copyWith(status: const Value('deleted')));
  }

  void permanentlyDelete(String id) {
    if (_isReal) {
      final db = _db!;
      final ownerId = _auth!.currentOwnerId!;
      // Drift doesn't cascade deletes locally the way Postgres' `ON
      // DELETE CASCADE` does server-side (see `0002_owned_companies.sql`)
      // — packages and shipments have no historical value once the
      // company relationship itself is gone, so they're deleted outright
      // here to match the server (a real bug found in testing: a deleted
      // company's shipments kept contributing to totals/showing stale
      // balances after the company itself was gone). Lines are different
      // on purpose: a customer's sold-line history should survive a
      // company being deleted, so this only detaches the link
      // (companyId -> null) rather than deleting the rows — matches the
      // server's `on delete set null` on `lines.company_id` (see
      // `supabase/migrations/0012_lines_company_set_null.sql`), and the
      // companyName/companyInitials snapshot columns are exactly what
      // keeps a detached Line still showing its (now historical) company
      // correctly.
      (db.delete(db.packagesTable)..where((t) => t.ownerId.equals(ownerId) & t.companyId.equals(id))).go();
      (db.delete(db.shipmentsTable)..where((t) => t.ownerId.equals(ownerId) & t.companyId.equals(id))).go();
      (db.update(db.linesTable)..where((t) => t.ownerId.equals(ownerId) & t.companyId.equals(id)))
          .write(const LinesTableCompanion(companyId: Value(null)));
      (db.delete(db.companiesTable)..where((t) => t.ownerId.equals(ownerId) & t.id.equals(id))).go();
      // Not part of the `synced` queue — a deleted row has nothing left
      // to "push". Recorded as a tombstone first (see
      // pending_deletes_table.dart) so a pull that races ahead of the
      // remote delete completing can never resurrect this row locally;
      // if this is offline, `SyncEngine.pushPendingDeletes` retries it
      // on the next sync.
      unawaited(_syncEngine?.recordAndPushDelete(entityTable: 'companies', id: id, ownerId: ownerId) ?? Future.value());
    }
    emit(state.copyWith(companies: state.companies.where((c) => c.id != id).toList()));
  }

  void importPreset(PresetCompany preset) {
    getIt<ActivityLogger>().log(ActivityActionType.create, 'Imported ready-made company ${preset.name}.');
    final existing = state.companies.where((c) => c.catalogCompanyId == preset.id).toList();
    final match = existing.isEmpty ? null : existing.first;

    if (match != null) {
      // Re-importing an archived import restores it to active; a
      // currently-active one can't be re-imported (see ImportReadyMadeSheet).
      _updateCompanyRow(match.id, (c) => c.copyWith(status: const Value('active')));
      return;
    }

    _insertCompany(
      name: preset.name,
      notes: '',
      packages: preset.defaultPackages,
      catalogCompanyId: preset.id,
      numberUpdateProvider: preset.numberUpdateProvider,
      // The catalog's logo is a public URL already — just point at it
      // directly rather than downloading and re-uploading a copy. A
      // deliberate simplification: unlike every other imported field,
      // this one stays pointing at the shared catalog asset even
      // though the import itself is a one-time copy everywhere else
      // (see class doc comment) — low-stakes for a logo image, and
      // avoids duplicating storage for no real benefit.
      logoUrlOverride: preset.logoUrl,
      numberUpdateUrl: preset.numberUpdateUrl,
    );
  }

  // --- CompanyCatalog ---

  @override
  Stream<void> get changes => stream;

  @override
  List<CompanySummary> get activeCompanies => state.companies
      .where((c) => c.status == CompanyStatus.active)
      .map((c) => CompanySummary(
            id: c.id,
            name: c.name,
            initials: c.initials,
            packages: c.packages
                .map((p) => PackageSummary(id: p.id, name: p.name, simType: p.simType, wholesaleCost: p.wholesaleCost, retailPrice: p.retailPrice))
                .toList(),
            profitGenerated: c.profitGenerated,
            operationsCount: c.operationsCount,
            usagePercent: c.usagePercent,
            consumed: c.consumed,
            availableToSell: c.availableToSell,
            owedToCompany: c.owedToCompany,
            numberUpdateProvider: c.numberUpdateProvider,
            numberUpdateUrl: c.numberUpdateUrl,
            allowNegativeBalance: c.allowNegativeBalance,
          ))
      .toList();

  @override
  void recordSale({required String companyId, required double wholesaleCost, required double profit}) {
    _replace(companyId, (c) => c.applySale(wholesaleCost: wholesaleCost, profit: profit));
  }

  @override
  void reverseSale({required String companyId, required double wholesaleCost, required double profit}) {
    _replace(companyId, (c) => c.reverseSale(wholesaleCost: wholesaleCost, profit: profit));
  }

  @override
  void addShipment({required String companyId, required double totalAmount, required double amountPaid}) {
    _replace(companyId, (c) => c.applyShipment(totalAmount: totalAmount, amountPaid: amountPaid));
  }

  /// Updates the in-memory `Company` list — always used for the
  /// balance/stats fields (never persisted yet, see class doc comment),
  /// and used for everything in offline/demo mode.
  void _replace(String key, Company Function(Company) update, {bool isName = false}) {
    emit(state.copyWith(
      companies: state.companies
          .map((c) => (isName ? c.name == key : c.id == key) ? update(c) : c)
          .toList(),
    ));
  }

  Future<void> _insertCompany({
    required String name,
    required String notes,
    required List<CompanyPackage> packages,
    required String? catalogCompanyId,
    NumberUpdateProviderKey? numberUpdateProvider,
    String? logoLocalPath,
    String? logoUrlOverride,
    String? numberUpdateUrl,
    bool allowNegativeBalance = false,
  }) async {
    final db = _db!;
    final ownerId = _auth!.currentOwnerId!;
    final companyId = generateUuidV4();
    final now = DateTime.now();
    final logoUrl = logoLocalPath != null ? await _uploadLogo(ownerId, companyId, logoLocalPath) : logoUrlOverride;

    await db.into(db.companiesTable).insert(CompaniesTableCompanion.insert(
          id: companyId,
          ownerId: ownerId,
          name: name,
          notes: Value(notes.isEmpty ? null : notes),
          catalogCompanyId: Value(catalogCompanyId),
          numberUpdateProvider: Value(numberUpdateProvider == null ? null : numberUpdateProviderToRow(numberUpdateProvider)),
          logoUrl: Value(logoUrl),
          numberUpdateUrl: Value(numberUpdateUrl?.isEmpty ?? true ? null : numberUpdateUrl),
          allowNegativeBalance: Value(allowNegativeBalance),
          synced: const Value(false),
          updatedAt: now,
        ));
    if (packages.isNotEmpty) {
      await db.batch((batch) {
        batch.insertAll(
          db.packagesTable,
          packages.map((p) => PackagesTableCompanion.insert(
                id: generateUuidV4(),
                ownerId: ownerId,
                companyId: companyId,
                name: p.name,
                simType: Value(p.simType),
                wholesaleCost: Value(p.wholesaleCost),
                retailPrice: Value(p.retailPrice),
                synced: const Value(false),
                updatedAt: now,
              )),
        );
      });
    }
    await _loadFromDrift();
    unawaited(_pushBestEffort());
  }

  Future<void> _updateCompanyAndPackages(
    String companyId, {
    required String name,
    required String notes,
    required List<CompanyPackage> packages,
    NumberUpdateProviderKey? numberUpdateProvider,
    String? logoLocalPath,
    bool removeLogo = false,
    String? numberUpdateUrl,
    bool allowNegativeBalance = false,
  }) async {
    final db = _db!;
    final ownerId = _auth!.currentOwnerId!;
    final now = DateTime.now();
    // `Value.absent()` (the default when a Companion field is never
    // set) leaves that column untouched — exactly what "neither
    // replacing nor removing the logo" needs.
    final logoUrl = logoLocalPath != null
        ? Value(await _uploadLogo(ownerId, companyId, logoLocalPath))
        : (removeLogo ? const Value(null) : const Value<String?>.absent());

    await (db.update(db.companiesTable)..where((t) => t.ownerId.equals(ownerId) & t.id.equals(companyId))).write(
      CompaniesTableCompanion(
        name: Value(name),
        notes: Value(notes.isEmpty ? null : notes),
        numberUpdateProvider: Value(numberUpdateProvider == null ? null : numberUpdateProviderToRow(numberUpdateProvider)),
        logoUrl: logoUrl,
        numberUpdateUrl: Value(numberUpdateUrl?.isEmpty ?? true ? null : numberUpdateUrl),
        allowNegativeBalance: Value(allowNegativeBalance),
        synced: const Value(false),
        updatedAt: Value(now),
      ),
    );

    // Packages have no stable identity worth diffing here — the form
    // hands back its full authoritative list each save, so replace
    // wholesale: delete this company's rows, re-insert what's given.
    await (db.delete(db.packagesTable)..where((t) => t.ownerId.equals(ownerId) & t.companyId.equals(companyId))).go();
    if (packages.isNotEmpty) {
      await db.batch((batch) {
        batch.insertAll(
          db.packagesTable,
          packages.map((p) => PackagesTableCompanion.insert(
                id: generateUuidV4(),
                ownerId: ownerId,
                companyId: companyId,
                name: p.name,
                simType: Value(p.simType),
                wholesaleCost: Value(p.wholesaleCost),
                retailPrice: Value(p.retailPrice),
                synced: const Value(false),
                updatedAt: now,
              )),
        );
      });
    }
    await _loadFromDrift();
    unawaited(_pushBestEffort());
  }

  /// Writes a `companies` row update in real mode, tagging it `synced =
  /// false` per CLAUDE.md's offline-first rule, then reloads from Drift
  /// so `state` reflects exactly what's persisted.
  Future<void> _updateCompanyRow(
    String companyId,
    CompaniesTableCompanion Function(CompaniesTableCompanion base) update,
  ) async {
    final db = _db!;
    final ownerId = _auth!.currentOwnerId!;
    final companion = update(CompaniesTableCompanion(synced: const Value(false), updatedAt: Value(DateTime.now())));
    await (db.update(db.companiesTable)..where((t) => t.ownerId.equals(ownerId) & t.id.equals(companyId))).write(companion);
    await _loadFromDrift();
    unawaited(_pushBestEffort());
  }

  /// Uploads a local logo image to the public `company-logos` bucket
  /// under this owner's own folder (see
  /// `supabase/migrations/0007_company_logos_storage.sql`'s RLS shape,
  /// which depends on this exact path) and returns its public URL —
  /// no signed URL needed, logos aren't sensitive. Returns null and
  /// swallows the error on failure (offline, transient): a logo that
  /// fails to upload just leaves the company without one, same as never
  /// picking one; it never blocks the rest of the save.
  Future<String?> _uploadLogo(String ownerId, String companyId, String localPath) async {
    try {
      final ext = localPath.contains('.') ? localPath.split('.').last : 'jpg';
      final objectPath = '$ownerId/$companyId.$ext';
      final bytes = await File(localPath).readAsBytes();
      await Supabase.instance.client.storage.from('company-logos').uploadBinary(
            objectPath,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );
      return Supabase.instance.client.storage.from('company-logos').getPublicUrl(objectPath);
    } catch (_) {
      return null;
    }
  }

  CompanyStatus _statusFrom(String status) {
    switch (status) {
      case 'archived':
        return CompanyStatus.archived;
      case 'deleted':
        return CompanyStatus.deleted;
      default:
        return CompanyStatus.active;
    }
  }

  String _initialsFor(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return (words.first.substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
  }
}

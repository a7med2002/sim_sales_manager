import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/activity_log/activity_action_type.dart';
import '../../../../core/activity_log/activity_logger.dart';
import '../../../../core/auth/auth_service.dart';
import '../../../../core/catalog/company_catalog.dart';
import '../../../../core/catalog/company_summary.dart';
import '../../../../core/config/env.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/number_update/number_update_provider.dart';
import '../../../../core/sync/sync_engine.dart';
import '../../../../core/utils/uuid.dart';
import '../../data/companies_mock_data.dart';
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

  CompaniesCubit({AppDatabase? db, AuthService? auth, SyncEngine? syncEngine})
    : _db = _resolveDb(db),
      _auth = _resolveAuth(auth),
      _syncEngine = syncEngine ?? (Env.isConfigured ? getIt<SyncEngine>() : null),
      super(CompaniesState(companies: _resolveDb(db) == null ? CompaniesMockData.initialCompanies() : const [])) {
    if (_db != null && _auth?.currentOwnerId != null) {
      _syncThenLoad();
    }
  }

  static AppDatabase? _resolveDb(AppDatabase? db) => db ?? (Env.isConfigured ? getIt<AppDatabase>() : null);
  static AuthService? _resolveAuth(AuthService? auth) => auth ?? (Env.isConfigured ? getIt<AuthService>() : null);

  bool get _isReal => _db != null && _auth?.currentOwnerId != null;

  int _newIdCounter = 1;

  /// Pulls/pushes with Supabase before loading `state` from Drift, so the
  /// list reflects the server the moment this Cubit is created (e.g.
  /// another device's changes). Best-effort: a failed sync (offline,
  /// transient error) just falls back to whatever's already local —
  /// never blocks the UI on network.
  Future<void> _syncThenLoad() async {
    final engine = _syncEngine;
    final ownerId = _auth?.currentOwnerId;
    if (engine != null && ownerId != null) {
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
          .map((p) => CompanyPackage(id: p.id, name: p.name, wholesaleCost: p.wholesaleCost, retailPrice: p.retailPrice))
          .toList();

      final companyLines = lineRows.where((l) => l.companyId == row.id);
      final companyShipments = shipmentRows.where((s) => s.companyId == row.id);

      final consumed = companyLines.fold(0.0, (sum, l) => sum + l.wholesaleCost);
      final totalShipped = companyShipments.fold(0.0, (sum, s) => sum + s.totalAmount);
      final availableToSell = (totalShipped - consumed).clamp(0, double.infinity).toDouble();
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
        consumed: consumed,
        availableToSell: availableToSell,
        owedToCompany: owedToCompany,
        profitGenerated: profitGenerated,
        operationsCount: companyLines.length,
        usagePercent: usagePercent,
      );
    }).toList();

    emit(state.copyWith(companies: companies));
  }

  /// Options offered in "Import Ready-Made": the shared catalog in real
  /// mode, the static preset list offline/in demo mode.
  Future<List<PresetCompany>> loadCatalogOptions() async {
    final db = _db;
    if (db == null) return CompaniesMockData.presetCompanies;

    final catalogRows = await db.select(db.companyCatalogTable).get();
    final packageRows = await db.select(db.packageCatalogTable).get();
    return catalogRows
        .map((c) => PresetCompany(
              id: c.id,
              name: c.name,
              initials: _initialsFor(c.name),
              defaultPackages: packageRows
                  .where((p) => p.companyCatalogId == c.id)
                  .map((p) => CompanyPackage(id: p.id, name: p.name, wholesaleCost: p.wholesaleCost, retailPrice: p.suggestedRetailPrice))
                  .toList(),
              numberUpdateProvider: numberUpdateProviderFromRow(c.numberUpdateProvider),
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
  }) {
    getIt<ActivityLogger>().log(ActivityActionType.create, 'Added new company $name.');
    if (_isReal) {
      _insertCompany(name: name, notes: notes, packages: packages, catalogCompanyId: null, numberUpdateProvider: numberUpdateProvider);
      return;
    }
    final company = Company(
      id: 'company-${_newIdCounter++}',
      name: name,
      initials: _initialsFor(name),
      notes: notes,
      packages: packages,
      status: CompanyStatus.active,
      numberUpdateProvider: numberUpdateProvider,
    );
    emit(state.copyWith(companies: [...state.companies, company]));
  }

  void updateCompany(
    String id, {
    required String name,
    required String notes,
    required List<CompanyPackage> packages,
    NumberUpdateProviderKey? numberUpdateProvider,
  }) {
    getIt<ActivityLogger>().log(ActivityActionType.edit, 'Updated company $name.');
    if (_isReal) {
      _updateCompanyAndPackages(id, name: name, notes: notes, packages: packages, numberUpdateProvider: numberUpdateProvider);
      return;
    }
    _replace(
      id,
      (c) => c.copyWith(
        name: name,
        initials: _initialsFor(name),
        notes: notes,
        packages: packages,
        clearNumberUpdateProvider: numberUpdateProvider == null,
        numberUpdateProvider: numberUpdateProvider,
      ),
    );
  }

  void togglePin(String id) {
    final current = state.companies.firstWhere((c) => c.id == id);
    if (_isReal) {
      _updateCompanyRow(id, (c) => c.copyWith(pinned: Value(!current.pinned)));
      return;
    }
    _replace(id, (c) => c.copyWith(pinned: !c.pinned));
  }

  void archive(String id) {
    final name = state.companies.firstWhere((c) => c.id == id).name;
    getIt<ActivityLogger>().log(ActivityActionType.edit, 'Archived company $name.');
    if (_isReal) {
      _updateCompanyRow(id, (c) => c.copyWith(status: const Value('archived')));
      return;
    }
    _replace(id, (c) => c.copyWith(status: CompanyStatus.archived));
  }

  void restoreToActive(String id) {
    final name = state.companies.firstWhere((c) => c.id == id).name;
    getIt<ActivityLogger>().log(ActivityActionType.edit, 'Restored company $name.');
    if (_isReal) {
      _updateCompanyRow(id, (c) => c.copyWith(status: const Value('active')));
      return;
    }
    _replace(id, (c) => c.copyWith(status: CompanyStatus.active));
  }

  void softDelete(String id) {
    final name = state.companies.firstWhere((c) => c.id == id).name;
    getIt<ActivityLogger>().log(ActivityActionType.delete, 'Deleted company $name.');
    if (_isReal) {
      _updateCompanyRow(id, (c) => c.copyWith(status: const Value('deleted')));
      return;
    }
    _replace(id, (c) => c.copyWith(status: CompanyStatus.deleted));
  }

  void permanentlyDelete(String id) {
    if (_isReal) {
      final db = _db!;
      final ownerId = _auth!.currentOwnerId!;
      // Drift doesn't cascade deletes locally the way Postgres' `ON
      // DELETE CASCADE` does server-side, so the local packages have to
      // be removed explicitly — otherwise they'd be orphaned rows.
      (db.delete(db.packagesTable)..where((t) => t.ownerId.equals(ownerId) & t.companyId.equals(id))).go();
      (db.delete(db.companiesTable)..where((t) => t.ownerId.equals(ownerId) & t.id.equals(id))).go();
      // Not part of the `synced` queue — a deleted row has nothing left
      // to "push". Best-effort: if this fails (offline), the row simply
      // reappears on the next pull until deleted again while online.
      _syncEngine?.deleteCompanyRemote(id).catchError((_) {});
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
      if (_isReal) {
        _updateCompanyRow(match.id, (c) => c.copyWith(status: const Value('active')));
      } else {
        _replace(match.id, (c) => c.copyWith(status: CompanyStatus.active));
      }
      return;
    }

    if (_isReal) {
      _insertCompany(
        name: preset.name,
        notes: '',
        packages: preset.defaultPackages,
        catalogCompanyId: preset.id,
        numberUpdateProvider: preset.numberUpdateProvider,
      );
      return;
    }

    final company = Company(
      id: 'company-${_newIdCounter++}',
      name: preset.name,
      initials: preset.initials,
      packages: preset.defaultPackages,
      status: CompanyStatus.active,
      catalogCompanyId: preset.id,
      numberUpdateProvider: preset.numberUpdateProvider,
    );
    emit(state.copyWith(companies: [...state.companies, company]));
  }

  // --- CompanyCatalog ---

  @override
  List<CompanySummary> get activeCompanies => state.companies
      .where((c) => c.status == CompanyStatus.active)
      .map((c) => CompanySummary(
            id: c.id,
            name: c.name,
            initials: c.initials,
            packages: c.packages
                .map((p) => PackageSummary(id: p.id, name: p.name, wholesaleCost: p.wholesaleCost, retailPrice: p.retailPrice))
                .toList(),
            profitGenerated: c.profitGenerated,
            operationsCount: c.operationsCount,
            usagePercent: c.usagePercent,
            consumed: c.consumed,
            availableToSell: c.availableToSell,
            owedToCompany: c.owedToCompany,
            numberUpdateProvider: c.numberUpdateProvider,
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
  }) async {
    final db = _db!;
    final ownerId = _auth!.currentOwnerId!;
    final companyId = generateUuidV4();
    final now = DateTime.now();

    await db.into(db.companiesTable).insert(CompaniesTableCompanion.insert(
          id: companyId,
          ownerId: ownerId,
          name: name,
          notes: Value(notes.isEmpty ? null : notes),
          catalogCompanyId: Value(catalogCompanyId),
          numberUpdateProvider: Value(numberUpdateProvider == null ? null : numberUpdateProviderToRow(numberUpdateProvider)),
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
  }) async {
    final db = _db!;
    final ownerId = _auth!.currentOwnerId!;
    final now = DateTime.now();

    await (db.update(db.companiesTable)..where((t) => t.ownerId.equals(ownerId) & t.id.equals(companyId))).write(
      CompaniesTableCompanion(
        name: Value(name),
        notes: Value(notes.isEmpty ? null : notes),
        numberUpdateProvider: Value(numberUpdateProvider == null ? null : numberUpdateProviderToRow(numberUpdateProvider)),
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

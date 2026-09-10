import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/activity_log/activity_action_type.dart';
import '../../../../core/activity_log/activity_logger.dart';
import '../../../../core/auth/auth_service.dart';
import '../../../../core/catalog/company_catalog.dart';
import '../../../../core/catalog/company_summary.dart';
import '../../../../core/catalog/customer_catalog.dart';
import '../../../../core/catalog/customer_summary.dart';
import '../../../../core/catalog/line_summary.dart';
import '../../../../core/config/env.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/sync/connectivity_service.dart';
import '../../../../core/sync/sync_engine.dart';
import '../../../../core/utils/uuid.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/line.dart';
import 'customers_state.dart';

/// Customers, following the same real push/pull sync pattern
/// `CompaniesCubit` established. When a real Supabase project is
/// configured and a seller is signed in (`Env.isConfigured` +
/// `AuthService.currentOwnerId`), customers load from and write to local
/// Drift's `customers` table, with `SyncEngine.syncAll`/
/// `pushPendingCustomers` keeping Supabase's `customers` table in sync —
/// see `SyncEngine`'s doc comment for the push/pull shape and its
/// deliberate simplifications.
///
/// Unlike `CompaniesCubit`, customer writes are **optimistic**: `state`
/// updates synchronously from the given data and the Drift write/push
/// happens in the background (fire-and-forget). This is required by
/// [CustomerCatalog.quickAddCustomer]'s contract — New Sale needs the new
/// customer's id back immediately, synchronously, to attach a line to it
/// in the same flow — so there's no `await`-then-reload step here the
/// way `CompaniesCubit` has.
///
/// **Lines are migrated too** (`addLine`/`updateLine`/`deleteLine`/
/// `addPayment`), same optimistic + best-effort-push shape as customers,
/// backed by Drift's `lines` table. A Line's `companyId`/`packageId`
/// reference this seller's own `companies`/`packages` rows (see the
/// `Line` entity's doc comment) — `CustomerCatalog.addSaleLine` gained a
/// required `companyId` param for this reason; New Sale already has
/// `company.id` on hand when it calls it. **Deliberately still not
/// covered**: `Operations`/`Shipments` — the Company balance/stats
/// fields (`consumed`, `availableToSell`, ...) that a sale is supposed
/// to affect stay in-memory-only on `CompaniesCubit` until Shipments &
/// Operations migrates as its own feature. The initial `lines` list
/// loads from Drift like `customers` does.
class CustomersCubit extends Cubit<CustomersState> implements CustomerCatalog {
  final AppDatabase? _db;
  final AuthService? _auth;
  final SyncEngine? _syncEngine;
  final ConnectivityService? _connectivity;

  CustomersCubit({AppDatabase? db, AuthService? auth, SyncEngine? syncEngine, ConnectivityService? connectivity})
    : _db = _resolveDb(db),
      _auth = _resolveAuth(auth),
      _syncEngine = syncEngine ?? (Env.isConfigured ? getIt<SyncEngine>() : null),
      _connectivity = connectivity ?? getIt<ConnectivityService>(),
      super(const CustomersState()) {
    if (_db != null && _auth?.currentOwnerId != null) {
      _syncThenLoad();
    }
  }

  static AppDatabase? _resolveDb(AppDatabase? db) => db ?? (Env.isConfigured ? getIt<AppDatabase>() : null);
  static AuthService? _resolveAuth(AuthService? auth) => auth ?? (Env.isConfigured ? getIt<AuthService>() : null);

  bool get _isReal => _db != null && _auth?.currentOwnerId != null;

  Future<void> _syncThenLoad() async {
    final engine = _syncEngine;
    final ownerId = _auth?.currentOwnerId;
    // Checking connectivity first (a cheap, instant OS-level flag) avoids
    // ever attempting these calls while offline — without this, each one
    // individually waits out a multi-second connect/DNS timeout before
    // falling back, and with four of them in a row that easily passed
    // 10+ seconds just to reach the local data that was sitting there the
    // whole time.
    if (engine != null && ownerId != null && await (_connectivity?.isOnline ?? Future.value(true))) {
      try {
        await engine.pushPendingCustomers(ownerId);
        await engine.pushPendingLines(ownerId);
        await engine.pullCustomers(ownerId);
        await engine.pullLines(ownerId);
      } catch (_) {
        // Offline or transient failure — proceed with local data.
      }
    }
    await _loadFromDrift();
  }

  Future<void> _loadFromDrift() async {
    final db = _db!;
    final ownerId = _auth!.currentOwnerId!;
    final customerRows = await (db.select(db.customersTable)..where((c) => c.ownerId.equals(ownerId))).get();
    final lineRows = await (db.select(db.linesTable)..where((l) => l.ownerId.equals(ownerId))).get();

    // Lines only store real companyId/packageId (FKs) — the display
    // strings (companyName/companyInitials/packageName) come from
    // whichever company/package is currently loaded in CompaniesCubit,
    // looked up here rather than re-fetched from Drift directly, since
    // this Cubit doesn't otherwise depend on the Companies feature.
    final companyCatalog = Env.isConfigured ? getIt<CompanyCatalog>() : null;
    final companiesById = <String, CompanySummary>{
      for (final c in companyCatalog?.activeCompanies ?? const <CompanySummary>[]) c.id: c,
    };

    emit(state.copyWith(
      customers: customerRows.map(_customerFromRow).toList(),
      lines: lineRows.map((row) => _lineFromRow(row, companiesById)).toList(),
    ));
  }

  Line _lineFromRow(LinesTableData row, Map<String, CompanySummary> companiesById) {
    // Prefer the frozen snapshot stored on the row itself — falling back
    // to a live join only for rows written before that snapshot existed
    // (migration from schema v2 and earlier). The live join is what used
    // to run unconditionally, and is fragile: Companies and Lines sync
    // independently, so a just-added company's own pull can still be in
    // flight — or the company can be renamed/archived later — when a
    // Line referencing it loads, showing a wrong or blank company here
    // even though nothing is actually wrong with the sale record.
    final company = companiesById[row.companyId];
    final package = company?.packages.where((p) => p.id == row.packageId);
    return Line(
      id: row.id,
      customerId: row.customerId,
      simNumber: row.simNumber,
      companyId: row.companyId,
      companyName: row.companyName ?? company?.name ?? '',
      companyInitials: row.companyInitials ?? company?.initials ?? '?',
      packageId: row.packageId,
      packageName: row.packageName ?? ((package != null && package.isNotEmpty) ? package.first.name : ''),
      packageSimType: row.packageSimType ?? ((package != null && package.isNotEmpty) ? package.first.simType : null),
      purchaseDate: row.purchaseDate,
      expiryDate: row.expiryDate,
      wholesaleCost: row.wholesaleCost,
      retailPrice: row.retailPrice,
      paymentStatus: _paymentStatusFromRow(row.paymentStatus),
      amountPaid: row.amountPaid,
      amountRemaining: row.amountRemaining,
    );
  }

  PaymentStatus _paymentStatusFromRow(String status) {
    switch (status) {
      case 'paid':
        return PaymentStatus.paid;
      case 'partial':
        return PaymentStatus.partial;
      default:
        return PaymentStatus.unpaid;
    }
  }

  String _paymentStatusToRow(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return 'paid';
      case PaymentStatus.partial:
        return 'partial';
      case PaymentStatus.unpaid:
        return 'unpaid';
    }
  }

  Future<void> _pushBestEffort() async {
    final engine = _syncEngine;
    final ownerId = _auth?.currentOwnerId;
    if (engine == null || ownerId == null) return;
    try {
      await engine.pushPendingCustomers(ownerId);
    } catch (_) {
      // Offline or transient failure — next sync cycle will retry.
    }
  }

  // --- List filters ---

  void selectTab(CustomersTab tab) {
    emit(state.copyWith(tab: tab));
  }

  void searchChanged(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void statusFilterChanged(CustomerStatus? status) {
    emit(state.copyWith(statusFilter: status, clearStatusFilter: status == null));
  }

  void tagFilterChanged(String? tag) {
    emit(state.copyWith(tagFilter: tag, clearTagFilter: tag == null));
  }

  // --- Customer CRUD ---

  Customer addCustomer({
    required String name,
    required String contactNumber,
    required List<String> tags,
    required CustomerStatus status,
    required bool pinned,
    required String notes,
  }) {
    final customer = Customer(
      id: generateUuidV4(),
      name: name,
      contactNumber: contactNumber,
      tags: tags,
      status: status,
      pinned: pinned,
      notes: notes,
    );
    emit(state.copyWith(customers: [...state.customers, customer]));
    if (_isReal) unawaited(_persistNewCustomer(customer));
    getIt<ActivityLogger>().log(ActivityActionType.create, 'Added new customer $name.');
    return customer;
  }

  void updateCustomer(
    String id, {
    required String name,
    required String contactNumber,
    required List<String> tags,
    required CustomerStatus status,
    required bool pinned,
    required String notes,
  }) {
    _replaceCustomer(
      id,
      (c) => c.copyWith(
        name: name,
        contactNumber: contactNumber,
        tags: tags,
        status: status,
        pinned: pinned,
        notes: notes,
      ),
    );
    if (_isReal) unawaited(_persistUpdate(id));
    getIt<ActivityLogger>().log(ActivityActionType.edit, 'Updated customer $name.');
  }

  void softDeleteCustomer(String id) {
    final name = state.customers.firstWhere((c) => c.id == id).name;
    _replaceCustomer(id, (c) => c.copyWith(deleted: true));
    if (_isReal) unawaited(_persistUpdate(id));
    getIt<ActivityLogger>().log(ActivityActionType.delete, 'Deleted customer $name (soft delete).');
  }

  void restoreCustomer(String id) {
    final name = state.customers.firstWhere((c) => c.id == id).name;
    _replaceCustomer(id, (c) => c.copyWith(deleted: false));
    if (_isReal) unawaited(_persistUpdate(id));
    getIt<ActivityLogger>().log(ActivityActionType.edit, 'Restored customer $name.');
  }

  void permanentlyDeleteCustomer(String id) {
    if (_isReal) {
      final db = _db!;
      final ownerId = _auth!.currentOwnerId!;
      // A Line has no identity independent of its customer (unlike a
      // Company, whose Lines survive detached with a frozen name
      // snapshot — see CompaniesCubit.permanentlyDelete's doc comment):
      // `lines.customer_id` is `NOT NULL` and server-side cascades on
      // customer delete (`on delete cascade`, 0002_owned_companies.sql).
      // Drift has no local FK enforcement to mirror that automatically,
      // so without this, this customer's lines stayed orphaned in local
      // Drift and came right back into `state.lines` (and every
      // rollup built from it — dashboard "uncollected", Reports'
      // "amount to collect", ...) on the next full reload, even though
      // they'd been correctly dropped from `state` below in the
      // meantime. Deleted outright here to match the server, not just
      // detached.
      (db.delete(db.linesTable)..where((t) => t.ownerId.equals(ownerId) & t.customerId.equals(id))).go();
      (db.delete(db.customersTable)..where((t) => t.ownerId.equals(ownerId) & t.id.equals(id))).go();
      unawaited(_syncEngine?.recordAndPushDelete(entityTable: 'customers', id: id, ownerId: ownerId) ?? Future.value());
    }
    emit(state.copyWith(
      customers: state.customers.where((c) => c.id != id).toList(),
      lines: state.lines.where((l) => l.customerId != id).toList(),
    ));
  }

  void _replaceCustomer(String id, Customer Function(Customer) update) {
    emit(state.copyWith(
      customers: state.customers.map((c) => c.id == id ? update(c) : c).toList(),
    ));
  }

  Future<void> _persistNewCustomer(Customer c) async {
    final db = _db!;
    final ownerId = _auth!.currentOwnerId!;
    try {
      await db.into(db.customersTable).insert(CustomersTableCompanion.insert(
            id: c.id,
            ownerId: ownerId,
            name: c.name,
            contactNumber: c.contactNumber,
            tags: Value(c.tags.join(',')),
            status: Value(_statusToRow(c.status)),
            pinned: Value(c.pinned),
            notes: Value(c.notes.isEmpty ? null : c.notes),
            synced: const Value(false),
            updatedAt: DateTime.now(),
          ));
      await _pushBestEffort();
    } catch (_) {
      // Offline or transient failure — the local `state` update already
      // happened; this row just stays out of Drift until retried. A rare
      // edge case (Drift write itself failing) rather than the common
      // "offline" one, which _pushBestEffort already handles gracefully.
    }
  }

  Future<void> _persistUpdate(String id) async {
    final db = _db!;
    final ownerId = _auth!.currentOwnerId!;
    final c = state.customers.firstWhere((x) => x.id == id);
    try {
      await (db.update(db.customersTable)..where((t) => t.ownerId.equals(ownerId) & t.id.equals(id))).write(
        CustomersTableCompanion(
          name: Value(c.name),
          contactNumber: Value(c.contactNumber),
          tags: Value(c.tags.join(',')),
          status: Value(_statusToRow(c.status)),
          pinned: Value(c.pinned),
          notes: Value(c.notes.isEmpty ? null : c.notes),
          deleted: Value(c.deleted),
          synced: const Value(false),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await _pushBestEffort();
    } catch (_) {
      // See _persistNewCustomer.
    }
  }

  Customer _customerFromRow(CustomersTableData row) {
    return Customer(
      id: row.id,
      name: row.name,
      contactNumber: row.contactNumber,
      tags: row.tags.isEmpty ? const [] : row.tags.split(','),
      status: _statusFromRow(row.status),
      pinned: row.pinned,
      notes: row.notes ?? '',
      deleted: row.deleted,
    );
  }

  CustomerStatus _statusFromRow(String status) {
    switch (status) {
      case 'troubled':
        return CustomerStatus.troubled;
      case 'blocked':
        return CustomerStatus.blocked;
      default:
        return CustomerStatus.normal;
    }
  }

  String _statusToRow(CustomerStatus status) {
    switch (status) {
      case CustomerStatus.troubled:
        return 'troubled';
      case CustomerStatus.blocked:
        return 'blocked';
      case CustomerStatus.normal:
        return 'normal';
    }
  }

  // --- Line CRUD ---
  //
  // `addLine`/`updateLine` back Customer Detail's "+ Add Line" form
  // (`LineFormSheet`), which now picks company/package from this
  // seller's real `CompanyCatalog.activeCompanies` (same list New Sale
  // uses) rather than free text — so, like `addSaleLine`, these persist
  // for real when `_isReal`.

  void addLine(
    String customerId, {
    required String simNumber,
    required String companyId,
    required String companyName,
    required String companyInitials,
    String? packageId,
    required String packageName,
    String? packageSimType,
    required DateTime purchaseDate,
    required DateTime expiryDate,
    required double wholesaleCost,
    required double retailPrice,
    required PaymentStatus paymentStatus,
    required double amountPaid,
    required double amountRemaining,
  }) {
    final line = Line(
      id: generateUuidV4(),
      customerId: customerId,
      simNumber: simNumber,
      companyId: companyId,
      companyName: companyName,
      companyInitials: companyInitials,
      packageId: packageId,
      packageName: packageName,
      packageSimType: packageSimType,
      purchaseDate: purchaseDate,
      expiryDate: expiryDate,
      wholesaleCost: wholesaleCost,
      retailPrice: retailPrice,
      paymentStatus: paymentStatus,
      amountPaid: amountPaid,
      amountRemaining: amountRemaining,
    );
    emit(state.copyWith(lines: [...state.lines, line]));
    if (_isReal) unawaited(_persistNewLine(line));
    // New Sale's own path (addSaleLine, below) already triggers this via
    // NewSaleCubit calling both catalogs itself — this is the only
    // other place a Line gets created, so it has to trigger the
    // company-side effect (consumed/operationsCount/profitGenerated)
    // itself, or a line added here would never move the company's
    // balance at all.
    getIt<CompanyCatalog>().recordSale(companyId: companyId, wholesaleCost: line.wholesaleCost, profit: line.profit);
    final matchingCustomer = state.customers.where((c) => c.id == customerId);
    final customerName = matchingCustomer.isEmpty ? '' : matchingCustomer.first.name;
    getIt<ActivityLogger>().log(ActivityActionType.create, 'Sold a new line to $customerName ($packageName, $companyName).');
  }

  void updateLine(
    String id, {
    required String simNumber,
    required String companyId,
    required String companyName,
    required String companyInitials,
    String? packageId,
    required String packageName,
    String? packageSimType,
    required DateTime purchaseDate,
    required DateTime expiryDate,
    required double wholesaleCost,
    required double retailPrice,
    required PaymentStatus paymentStatus,
    required double amountPaid,
    required double amountRemaining,
  }) {
    final oldLine = state.lines.firstWhere((l) => l.id == id);
    emit(state.copyWith(
      lines: state.lines
          .map((l) => l.id == id
              ? l.copyWith(
                  simNumber: simNumber,
                  companyId: companyId,
                  companyName: companyName,
                  companyInitials: companyInitials,
                  packageId: packageId,
                  packageName: packageName,
                  packageSimType: packageSimType,
                  purchaseDate: purchaseDate,
                  expiryDate: expiryDate,
                  wholesaleCost: wholesaleCost,
                  retailPrice: retailPrice,
                  paymentStatus: paymentStatus,
                  amountPaid: amountPaid,
                  amountRemaining: amountRemaining,
                )
              : l)
          .toList(),
    ));
    if (_isReal) unawaited(_persistLineUpdate(id));
    // The company's consumed/available balance was computed from the
    // *old* wholesale cost (and possibly a different company entirely,
    // since the form lets you re-pick one) — reverse that, then record
    // the new values, so it doesn't go stale until the next full reload.
    final companyCatalog = getIt<CompanyCatalog>();
    final oldCompanyId = oldLine.companyId;
    // A null companyId means that line's company was already
    // permanently deleted (detached, not deleted with it — see
    // `CompaniesCubit.permanentlyDelete`) — nothing to reverse against
    // since it's no longer contributing to any company's balance.
    if (oldCompanyId != null) {
      companyCatalog.reverseSale(companyId: oldCompanyId, wholesaleCost: oldLine.wholesaleCost, profit: oldLine.profit);
    }
    companyCatalog.recordSale(companyId: companyId, wholesaleCost: wholesaleCost, profit: retailPrice - wholesaleCost);
    getIt<ActivityLogger>().log(ActivityActionType.edit, 'Updated line ${oldLine.simNumber}.');
  }

  void deleteLine(String id) {
    final line = state.lines.firstWhere((l) => l.id == id);
    if (_isReal) {
      final db = _db!;
      final ownerId = _auth!.currentOwnerId!;
      (db.delete(db.linesTable)..where((t) => t.ownerId.equals(ownerId) & t.id.equals(id))).go();
      unawaited(_syncEngine?.recordAndPushDelete(entityTable: 'lines', id: id, ownerId: ownerId) ?? Future.value());
    }
    emit(state.copyWith(lines: state.lines.where((l) => l.id != id).toList()));
    // Same reasoning as updateLine above: without this, the company's
    // consumed/available balance would keep counting a Line that no
    // longer exists until the next full reload recomputes it from Drift.
    // A null companyId (its company was already permanently deleted —
    // detached, not deleted with it) means there's no live balance left
    // to reverse against.
    final lineCompanyId = line.companyId;
    if (lineCompanyId != null) {
      getIt<CompanyCatalog>().reverseSale(companyId: lineCompanyId, wholesaleCost: line.wholesaleCost, profit: line.profit);
    }
    getIt<ActivityLogger>().log(ActivityActionType.delete, 'Deleted line ${line.simNumber}.');
  }

  /// Records a payment towards a specific line's remaining balance —
  /// e.g. the customer comes back later and pays off part or all of what
  /// they still owe on that one line (independent of their other lines).
  void addPayment(String lineId, double amount) {
    if (amount <= 0) return;
    final line = state.lines.firstWhere((l) => l.id == lineId);
    final isFullCollection = amount >= line.amountRemaining;
    emit(state.copyWith(
      lines: state.lines.map((l) => l.id == lineId ? l.applyPayment(amount) : l).toList(),
    ));
    if (_isReal) unawaited(_persistLineUpdate(lineId));
    getIt<ActivityLogger>().log(
      isFullCollection ? ActivityActionType.fullCollection : ActivityActionType.edit,
      'Collected ${amount.toStringAsFixed(2)} on ${line.simNumber} (${line.companyName}).',
    );
  }

  Future<void> _persistLineUpdate(String id) async {
    final db = _db!;
    final ownerId = _auth!.currentOwnerId!;
    final line = state.lines.firstWhere((l) => l.id == id);
    try {
      await (db.update(db.linesTable)..where((t) => t.ownerId.equals(ownerId) & t.id.equals(id))).write(
        LinesTableCompanion(
          companyId: Value(line.companyId),
          companyName: Value(line.companyName),
          companyInitials: Value(line.companyInitials),
          packageId: Value(line.packageId),
          packageName: Value(line.packageName),
          packageSimType: Value(line.packageSimType),
          simNumber: Value(line.simNumber),
          purchaseDate: Value(line.purchaseDate),
          expiryDate: Value(line.expiryDate),
          wholesaleCost: Value(line.wholesaleCost),
          retailPrice: Value(line.retailPrice),
          profit: Value(line.profit),
          paymentStatus: Value(_paymentStatusToRow(line.paymentStatus)),
          amountPaid: Value(line.amountPaid),
          amountRemaining: Value(line.amountRemaining),
          synced: const Value(false),
          updatedAt: Value(DateTime.now()),
        ),
      );
      if (_syncEngine != null) {
        await _syncEngine.pushPendingLines(ownerId);
      }
    } catch (_) {
      // Offline or transient failure — row stays local, next sync retries.
    }
  }

  // --- CustomerCatalog ---

  @override
  Stream<void> get changes => stream;

  @override
  List<CustomerSummary> get activeCustomers => state.customers
      .where((c) => !c.deleted)
      .map((c) => CustomerSummary(id: c.id, name: c.name, contactNumber: c.contactNumber, status: _toStatusSummary(c.status)))
      .toList();

  CustomerStatusSummary _toStatusSummary(CustomerStatus status) {
    switch (status) {
      case CustomerStatus.normal:
        return CustomerStatusSummary.normal;
      case CustomerStatus.troubled:
        return CustomerStatusSummary.troubled;
      case CustomerStatus.blocked:
        return CustomerStatusSummary.blocked;
    }
  }

  @override
  List<LineSummary> get allLines => state.lines.map((l) {
        final matchingCustomers = state.customers.where((c) => c.id == l.customerId);
        final customerName = matchingCustomers.isEmpty ? '' : matchingCustomers.first.name;
        final customerContact = matchingCustomers.isEmpty ? '' : matchingCustomers.first.contactNumber;
        // No matching customer at all (shouldn't normally happen now
        // that permanentlyDeleteCustomer cleans up its own lines — see
        // its doc comment) is treated the same as a soft-deleted one:
        // either way there's no live customer left to collect from.
        final customerDeleted = matchingCustomers.isEmpty || matchingCustomers.first.deleted;
        return LineSummary(
          id: l.id,
          customerName: customerName,
          customerContact: customerContact,
          customerDeleted: customerDeleted,
          simNumber: l.simNumber,
          companyId: l.companyId ?? '',
          companyName: l.companyName,
          companyInitials: l.companyInitials,
          packageName: l.packageName,
          packageSimType: l.packageSimType,
          purchaseDate: l.purchaseDate,
          expiryDate: l.expiryDate,
          wholesaleCost: l.wholesaleCost,
          retailPrice: l.retailPrice,
          amountPaid: l.amountPaid,
          amountRemaining: l.amountRemaining,
          paymentStatus: _toLinePaymentStatus(l.paymentStatus),
        );
      }).toList();

  LinePaymentStatus _toLinePaymentStatus(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return LinePaymentStatus.paid;
      case PaymentStatus.partial:
        return LinePaymentStatus.partial;
      case PaymentStatus.unpaid:
        return LinePaymentStatus.unpaid;
    }
  }

  @override
  String quickAddCustomer({required String name, required String contactNumber}) {
    final customer = addCustomer(
      name: name,
      contactNumber: contactNumber,
      tags: const [],
      status: CustomerStatus.normal,
      pinned: false,
      notes: '',
    );
    return customer.id;
  }

  @override
  void addSaleLine({
    required String customerId,
    required String simNumber,
    required String companyId,
    required String companyName,
    required String companyInitials,
    String? packageId,
    required String packageName,
    String? packageSimType,
    required DateTime purchaseDate,
    required DateTime expiryDate,
    required double wholesaleCost,
    required double retailPrice,
    required double amountPaid,
  }) {
    final amountRemaining = (retailPrice - amountPaid).clamp(0, double.infinity).toDouble();
    final PaymentStatus paymentStatus;
    if (amountPaid <= 0) {
      paymentStatus = PaymentStatus.unpaid;
    } else if (amountPaid >= retailPrice) {
      paymentStatus = PaymentStatus.paid;
    } else {
      paymentStatus = PaymentStatus.partial;
    }

    final line = Line(
      id: generateUuidV4(),
      customerId: customerId,
      simNumber: simNumber,
      companyId: companyId,
      companyName: companyName,
      companyInitials: companyInitials,
      packageId: packageId,
      packageName: packageName,
      packageSimType: packageSimType,
      purchaseDate: purchaseDate,
      expiryDate: expiryDate,
      wholesaleCost: wholesaleCost,
      retailPrice: retailPrice,
      paymentStatus: paymentStatus,
      amountPaid: amountPaid,
      amountRemaining: amountRemaining,
    );
    emit(state.copyWith(lines: [...state.lines, line]));
    if (_isReal) unawaited(_persistNewLine(line));
    final matchingCustomer = state.customers.where((c) => c.id == customerId);
    final customerName = matchingCustomer.isEmpty ? '' : matchingCustomer.first.name;
    getIt<ActivityLogger>().log(ActivityActionType.create, 'Sold a new line to $customerName ($packageName, $companyName).');
  }

  Future<void> _persistNewLine(Line line) async {
    final db = _db!;
    final ownerId = _auth!.currentOwnerId!;
    try {
      await db.into(db.linesTable).insert(LinesTableCompanion.insert(
            id: line.id,
            ownerId: ownerId,
            customerId: line.customerId,
            companyId: Value(line.companyId),
            companyName: Value(line.companyName),
            companyInitials: Value(line.companyInitials),
            packageId: Value(line.packageId),
            packageName: Value(line.packageName),
            packageSimType: Value(line.packageSimType),
            simNumber: line.simNumber,
            purchaseDate: line.purchaseDate,
            expiryDate: line.expiryDate,
            wholesaleCost: Value(line.wholesaleCost),
            retailPrice: Value(line.retailPrice),
            profit: Value(line.profit),
            paymentStatus: Value(_paymentStatusToRow(line.paymentStatus)),
            amountPaid: Value(line.amountPaid),
            amountRemaining: Value(line.amountRemaining),
            synced: const Value(false),
            updatedAt: DateTime.now(),
          ));
      if (_syncEngine != null) {
        await _syncEngine.pushPendingLines(ownerId);
      }
    } catch (_) {
      // Offline or transient failure — row stays local, next sync retries.
    }
  }
}

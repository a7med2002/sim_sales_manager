import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/activity_log/activity_action_type.dart';
import '../../../../core/activity_log/activity_logger.dart';
import '../../../../core/auth/auth_service.dart';
import '../../../../core/catalog/company_catalog.dart';
import '../../../../core/catalog/customer_catalog.dart';
import '../../../../core/catalog/line_summary.dart';
import '../../../../core/config/env.dart';
import '../../../../core/constants/period_filter.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/sync/sync_engine.dart';
import '../../../../core/utils/uuid.dart';
import '../../domain/entities/shipment.dart';
import 'shipments_operations_state.dart';

/// Shipments & Operations combines two tabs in one cubit (same pattern
/// Companies uses for its own tabs).
///
/// **Shipments** now migrated for real, same conditional pattern as
/// Companies/Customers/Lines: when `Env.isConfigured` + a signed-in
/// owner, shipments load from and write to Drift's `shipments` table
/// (optimistic writes, same shape as `CustomersCubit`'s Lines — a
/// shipment's own id is known before the async Drift insert completes,
/// so `state` updates immediately and the write happens in the
/// background). Adding one still also calls `CompanyCatalog.addShipment`
/// for an instant optimistic nudge to that company's balance — see
/// `CompaniesCubit._loadFromDrift`'s doc comment for why that balance is
/// now *derived* from real `shipments`/`lines` rows on every reload
/// rather than trusted as a running total.
///
/// **Operations** reads real Lines through `CustomerCatalog` (no writes:
/// "+ Add Operation" opens the same New Sale flow rather than
/// duplicating it) — this side was already real before this pass, since
/// Lines migrated first.
class ShipmentsOperationsCubit extends Cubit<ShipmentsOperationsState> {
  final CompanyCatalog _companyCatalog;
  final AppDatabase? _db;
  final AuthService? _auth;
  final SyncEngine? _syncEngine;

  ShipmentsOperationsCubit({
    required CompanyCatalog companyCatalog,
    required CustomerCatalog customerCatalog,
    AppDatabase? db,
    AuthService? auth,
    SyncEngine? syncEngine,
  })  : _companyCatalog = companyCatalog,
        _db = _resolveDb(db),
        _auth = _resolveAuth(auth),
        _syncEngine = syncEngine ?? (Env.isConfigured ? getIt<SyncEngine>() : null),
        super(ShipmentsOperationsState(
          companies: companyCatalog.activeCompanies,
          shipments: const [],
          lines: customerCatalog.allLines,
          now: DateTime.now(),
        )) {
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
    if (engine != null && ownerId != null) {
      try {
        await engine.pushPendingShipments(ownerId);
        await engine.pullShipments(ownerId);
      } catch (_) {
        // Offline or transient failure — proceed with local data.
      }
    }
    await _loadFromDrift();
  }

  Future<void> _loadFromDrift() async {
    final db = _db!;
    final ownerId = _auth!.currentOwnerId!;
    final rows = await (db.select(db.shipmentsTable)..where((s) => s.ownerId.equals(ownerId))).get();
    final companiesById = {for (final c in _companyCatalog.activeCompanies) c.id: c};

    final shipments = rows.map((row) {
      final company = companiesById[row.companyId];
      return Shipment(
        id: row.id,
        companyId: row.companyId,
        companyName: company?.name ?? '',
        companyInitials: company?.initials ?? '?',
        type: row.type == 'credit_limit' ? ShipmentType.creditLimit : ShipmentType.prepaid,
        totalAmount: row.totalAmount,
        amountPaid: row.amountPaid,
        paymentMethod: row.paymentMethod ?? '',
        date: row.shipmentDate,
        referenceNumber: row.referenceNumber ?? '',
        notes: row.notes ?? '',
      );
    }).toList();

    emit(state.copyWith(shipments: shipments));
  }

  void selectTab(int index) => emit(state.copyWith(tabIndex: index));

  // --- Shipments tab ---

  void shipmentCompanyFilterChanged(String? companyName) =>
      emit(state.copyWith(shipmentCompanyFilter: companyName, clearShipmentCompanyFilter: companyName == null));

  void shipmentPeriodChanged(PeriodFilter period) => emit(state.copyWith(shipmentPeriod: period));

  void shipmentCustomRangeChanged(DateTimeRange range) =>
      emit(state.copyWith(shipmentPeriod: PeriodFilter.custom, shipmentCustomRange: range));

  void shipmentPageSizeChanged(int pageSize) => emit(state.copyWith(shipmentPageSize: pageSize));

  void addShipment({
    required String companyId,
    required String companyName,
    required String companyInitials,
    required ShipmentType type,
    required double totalAmount,
    required double amountPaid,
    required String paymentMethod,
    required DateTime date,
    required String referenceNumber,
    required String notes,
  }) {
    final shipment = Shipment(
      id: generateUuidV4(),
      companyId: companyId,
      companyName: companyName,
      companyInitials: companyInitials,
      type: type,
      totalAmount: totalAmount,
      amountPaid: amountPaid,
      paymentMethod: paymentMethod,
      date: date,
      referenceNumber: referenceNumber,
      notes: notes,
    );

    _companyCatalog.addShipment(companyId: companyId, totalAmount: totalAmount, amountPaid: amountPaid);

    emit(state.copyWith(
      shipments: [shipment, ...state.shipments],
      companies: _companyCatalog.activeCompanies,
    ));

    if (_isReal) unawaited(_persistNewShipment(shipment));
    final typeLabel = type == ShipmentType.creditLimit ? 'credit limit' : 'prepaid';
    getIt<ActivityLogger>().log(
      ActivityActionType.create,
      'Added a new shipment to $companyName for ${totalAmount.toStringAsFixed(2)} ($typeLabel).',
    );
  }

  Future<void> _persistNewShipment(Shipment shipment) async {
    final db = _db!;
    final ownerId = _auth!.currentOwnerId!;
    try {
      await db.into(db.shipmentsTable).insert(ShipmentsTableCompanion.insert(
            id: shipment.id,
            ownerId: ownerId,
            companyId: shipment.companyId,
            type: shipment.type == ShipmentType.creditLimit ? 'credit_limit' : 'prepaid',
            totalAmount: Value(shipment.totalAmount),
            amountPaid: Value(shipment.amountPaid),
            amountRemaining: Value(shipment.amountRemaining),
            paymentMethod: Value(shipment.paymentMethod.isEmpty ? null : shipment.paymentMethod),
            referenceNumber: Value(shipment.referenceNumber.isEmpty ? null : shipment.referenceNumber),
            shipmentDate: shipment.date,
            notes: Value(shipment.notes.isEmpty ? null : shipment.notes),
            synced: const Value(false),
            updatedAt: DateTime.now(),
          ));
      if (_syncEngine != null) {
        await _syncEngine.pushPendingShipments(ownerId);
      }
    } catch (_) {
      // Offline or transient failure — row stays local, next sync retries.
    }
  }

  // --- Operations tab ---

  void operationsPeriodChanged(PeriodFilter period) => emit(state.copyWith(operationsPeriod: period));

  void operationsCustomRangeChanged(DateTimeRange range) =>
      emit(state.copyWith(operationsPeriod: PeriodFilter.custom, operationsCustomRange: range));

  void operationsStatusFilterChanged(LinePaymentStatus? status) =>
      emit(state.copyWith(operationsStatusFilter: status, clearOperationsStatusFilter: status == null));

  void operationsSearchChanged(String query) => emit(state.copyWith(operationsSearchQuery: query));
}

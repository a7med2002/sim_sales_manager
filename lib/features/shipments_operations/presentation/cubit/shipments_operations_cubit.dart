import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/catalog/company_catalog.dart';
import '../../../../core/catalog/customer_catalog.dart';
import '../../../../core/catalog/line_summary.dart';
import '../../../../core/constants/period_filter.dart';
import '../../data/shipments_mock_data.dart';
import '../../domain/entities/shipment.dart';
import 'shipments_operations_state.dart';

/// Shipments & Operations combines two tabs in one cubit (same pattern
/// Companies uses for its own tabs). Shipments are mock-only (no real
/// shipment log exists elsewhere), but adding one calls
/// `CompanyCatalog.addShipment` for real, actually moving that
/// company's balance — same as New Sale's `recordSale`. Operations
/// reads real Lines through `CustomerCatalog` (no writes: "+ Add
/// Operation" opens the same New Sale flow rather than duplicating it).
class ShipmentsOperationsCubit extends Cubit<ShipmentsOperationsState> {
  final CompanyCatalog _companyCatalog;
  int _shipmentIdCounter = 1;

  ShipmentsOperationsCubit({required CompanyCatalog companyCatalog, required CustomerCatalog customerCatalog})
      : _companyCatalog = companyCatalog,
        super(ShipmentsOperationsState(
          companies: companyCatalog.activeCompanies,
          shipments: ShipmentsMockData.initialShipments(),
          lines: customerCatalog.allLines,
          now: DateTime.now(),
        ));

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
      id: 'shipment-${_shipmentIdCounter++}',
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
  }

  // --- Operations tab ---

  void operationsPeriodChanged(PeriodFilter period) => emit(state.copyWith(operationsPeriod: period));

  void operationsCustomRangeChanged(DateTimeRange range) =>
      emit(state.copyWith(operationsPeriod: PeriodFilter.custom, operationsCustomRange: range));

  void operationsStatusFilterChanged(LinePaymentStatus? status) =>
      emit(state.copyWith(operationsStatusFilter: status, clearOperationsStatusFilter: status == null));

  void operationsSearchChanged(String query) => emit(state.copyWith(operationsSearchQuery: query));
}

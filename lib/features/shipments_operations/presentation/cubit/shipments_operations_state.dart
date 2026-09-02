import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show DateTimeRange;

import '../../../../core/catalog/company_summary.dart';
import '../../../../core/catalog/line_summary.dart';
import '../../../../core/constants/period_filter.dart';
import '../../../../core/utils/period_filter_matcher.dart';
import '../../domain/entities/shipment.dart';

class FollowUpBreakdown extends Equatable {
  final int overdue;
  final int today;
  final int expiringSoon;

  const FollowUpBreakdown({required this.overdue, required this.today, required this.expiringSoon});

  int get total => overdue + today + expiringSoon;

  @override
  List<Object?> get props => [overdue, today, expiringSoon];
}

class ShipmentsOperationsState extends Equatable {
  final int tabIndex; // 0 = Shipments, 1 = Operations
  final DateTime now;

  // Shared company list (for balance cards + dropdowns on both tabs).
  final List<CompanySummary> companies;

  // --- Shipments tab ---
  final List<Shipment> shipments;
  final String? shipmentCompanyFilter;
  final PeriodFilter shipmentPeriod;
  final DateTimeRange? shipmentCustomRange;
  final int shipmentPageSize;

  // --- Operations tab ---
  final List<LineSummary> lines;
  final PeriodFilter operationsPeriod;
  final DateTimeRange? operationsCustomRange;
  final LinePaymentStatus? operationsStatusFilter;
  final String operationsSearchQuery;

  const ShipmentsOperationsState({
    required this.companies,
    required this.shipments,
    required this.lines,
    required this.now,
    this.tabIndex = 0,
    this.shipmentCompanyFilter,
    this.shipmentPeriod = PeriodFilter.all,
    this.shipmentCustomRange,
    this.shipmentPageSize = 50,
    this.operationsPeriod = PeriodFilter.all,
    this.operationsCustomRange,
    this.operationsStatusFilter,
    this.operationsSearchQuery = '',
  });

  // --- Shipments derived data ---

  List<Shipment> get filteredShipments {
    final filtered = shipments.where((s) {
      if (!matchesPeriod(s.date, shipmentPeriod, now, customRange: shipmentCustomRange)) return false;
      if (shipmentCompanyFilter != null && s.companyName != shipmentCompanyFilter) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (shipmentPageSize == -1) return filtered;
    return filtered.take(shipmentPageSize).toList();
  }

  double get totalShipmentsAmount => filteredShipments.fold(0.0, (sum, s) => sum + s.totalAmount);
  double get totalPaidAmount => filteredShipments.fold(0.0, (sum, s) => sum + s.amountPaid);
  double get totalRemainingAmount => filteredShipments.fold(0.0, (sum, s) => sum + s.amountRemaining);

  // --- Operations derived data ---

  /// Fixed "at-a-glance" counts — always computed over every line,
  /// independent of the Duration/Status/search filters below (same
  /// pattern as Profits' Year/Month/Week/Today cards).
  int get partiallyPaidCount => lines.where((l) => l.paymentStatus == LinePaymentStatus.partial).length;
  int get unpaidCount => lines.where((l) => l.paymentStatus == LinePaymentStatus.unpaid).length;
  double get amountToCollect => lines.fold(0.0, (sum, l) => sum + l.amountRemaining);

  FollowUpBreakdown get needsFollowUp {
    var overdue = 0;
    var today = 0;
    var soon = 0;
    for (final line in lines) {
      final expiry = line.expiryDate;
      final isToday = expiry.year == now.year && expiry.month == now.month && expiry.day == now.day;
      if (isToday) {
        today++;
      } else if (expiry.isBefore(now)) {
        overdue++;
      } else if (expiry.difference(now).inDays <= 7) {
        soon++;
      }
    }
    return FollowUpBreakdown(overdue: overdue, today: today, expiringSoon: soon);
  }

  List<LineSummary> get filteredLines {
    final query = operationsSearchQuery.trim().toLowerCase();
    return lines.where((l) {
      if (!matchesPeriod(l.purchaseDate, operationsPeriod, now, customRange: operationsCustomRange)) return false;
      if (operationsStatusFilter != null && l.paymentStatus != operationsStatusFilter) return false;
      if (query.isNotEmpty && !l.simNumber.toLowerCase().contains(query) && !l.id.toLowerCase().contains(query)) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
  }

  ShipmentsOperationsState copyWith({
    int? tabIndex,
    List<CompanySummary>? companies,
    List<Shipment>? shipments,
    bool clearShipmentCompanyFilter = false,
    String? shipmentCompanyFilter,
    PeriodFilter? shipmentPeriod,
    DateTimeRange? shipmentCustomRange,
    int? shipmentPageSize,
    List<LineSummary>? lines,
    PeriodFilter? operationsPeriod,
    DateTimeRange? operationsCustomRange,
    bool clearOperationsStatusFilter = false,
    LinePaymentStatus? operationsStatusFilter,
    String? operationsSearchQuery,
  }) {
    return ShipmentsOperationsState(
      companies: companies ?? this.companies,
      shipments: shipments ?? this.shipments,
      lines: lines ?? this.lines,
      now: now,
      tabIndex: tabIndex ?? this.tabIndex,
      shipmentCompanyFilter: clearShipmentCompanyFilter ? null : (shipmentCompanyFilter ?? this.shipmentCompanyFilter),
      shipmentPeriod: shipmentPeriod ?? this.shipmentPeriod,
      shipmentCustomRange: shipmentCustomRange ?? this.shipmentCustomRange,
      shipmentPageSize: shipmentPageSize ?? this.shipmentPageSize,
      operationsPeriod: operationsPeriod ?? this.operationsPeriod,
      operationsCustomRange: operationsCustomRange ?? this.operationsCustomRange,
      operationsStatusFilter: clearOperationsStatusFilter ? null : (operationsStatusFilter ?? this.operationsStatusFilter),
      operationsSearchQuery: operationsSearchQuery ?? this.operationsSearchQuery,
    );
  }

  @override
  List<Object?> get props => [
        tabIndex,
        companies,
        shipments,
        shipmentCompanyFilter,
        shipmentPeriod,
        shipmentCustomRange,
        shipmentPageSize,
        lines,
        operationsPeriod,
        operationsCustomRange,
        operationsStatusFilter,
        operationsSearchQuery,
        now,
      ];
}

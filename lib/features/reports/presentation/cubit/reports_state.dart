import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show DateTimeRange;

import '../../../../core/catalog/company_summary.dart';
import '../../../../core/catalog/line_summary.dart';
import '../../../../core/constants/period_filter.dart';
import '../../../../core/utils/period_filter_matcher.dart';

class ReportsState extends Equatable {
  final List<LineSummary> lines;
  final List<CompanySummary> companies;
  final String repName;
  final PeriodFilter period;
  final DateTimeRange? customRange;
  final String? companyFilter;
  final DateTime now;

  const ReportsState({
    required this.lines,
    required this.companies,
    required this.repName,
    required this.now,
    this.period = PeriodFilter.all,
    this.customRange,
    this.companyFilter,
  });

  List<LineSummary> get filteredLines {
    final filtered = lines.where((l) {
      if (!matchesPeriod(l.purchaseDate, period, now, customRange: customRange)) return false;
      if (companyFilter != null && l.companyName != companyFilter) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
    return filtered;
  }

  double get totalProfit => filteredLines.fold(0.0, (sum, l) => sum + l.profit);
  double get totalSales => filteredLines.fold(0.0, (sum, l) => sum + l.retailPrice);
  int get linesSold => filteredLines.length;
  int get operationsCount => filteredLines.length;
  // Excludes deleted customers' lines — see LineSummary.customerDeleted's
  // doc comment: that debt/follow-up is no longer collectible/actionable
  // through the app once its customer is gone. totalProfit/totalSales/
  // linesSold/operationsCount above stay full-history on purpose — a
  // completed sale's profit doesn't stop being real just because the
  // customer record was later deleted.
  double get amountToCollect =>
      filteredLines.where((l) => !l.customerDeleted).fold(0.0, (sum, l) => sum + l.amountRemaining);
  int get partiallyPaidCount =>
      filteredLines.where((l) => !l.customerDeleted && l.paymentStatus == LinePaymentStatus.partial).length;
  int get unpaidCount =>
      filteredLines.where((l) => !l.customerDeleted && l.paymentStatus == LinePaymentStatus.unpaid).length;

  ReportsState copyWith({
    List<LineSummary>? lines,
    List<CompanySummary>? companies,
    PeriodFilter? period,
    DateTimeRange? customRange,
    bool clearCompanyFilter = false,
    String? companyFilter,
  }) {
    return ReportsState(
      lines: lines ?? this.lines,
      companies: companies ?? this.companies,
      repName: repName,
      now: now,
      period: period ?? this.period,
      customRange: customRange ?? this.customRange,
      companyFilter: clearCompanyFilter ? null : (companyFilter ?? this.companyFilter),
    );
  }

  @override
  List<Object?> get props => [lines, companies, repName, period, customRange, companyFilter, now];
}

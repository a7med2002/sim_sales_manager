import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show DateTimeRange;

import '../../../../core/catalog/company_summary.dart';
import '../../../../core/catalog/line_summary.dart';
import '../../../../core/constants/period_filter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/period_filter_matcher.dart';
import '../../domain/entities/chart_point.dart';
import '../../domain/entities/company_balance.dart';
import '../../domain/entities/dashboard_stats.dart';

/// Real figures derived from every sold Line (via `CustomerCatalog`) and
/// every active Company's real balance (via `CompanyCatalog`) — same
/// pattern `ProfitsState`/`ReportsState` already established, not mock
/// data.
class HomeState extends Equatable {
  final List<LineSummary> lines;
  final List<CompanySummary> companies;
  final String userName;
  final PeriodFilter selectedPeriod;
  final DateTimeRange? customRange;
  final DateTime now;

  const HomeState({
    required this.lines,
    required this.companies,
    required this.userName,
    required this.now,
    this.selectedPeriod = PeriodFilter.all,
    this.customRange,
  });

  List<LineSummary> get _selectedPeriodLines =>
      lines.where((l) => matchesPeriod(l.purchaseDate, selectedPeriod, now, customRange: customRange)).toList();

  /// Stat cards for the selected period.
  DashboardStats get stats {
    final matching = _selectedPeriodLines;
    return DashboardStats(
      operations: matching.length,
      companies: matching.map((l) => l.companyId).where((id) => id.isNotEmpty).toSet().length,
      totalSales: matching.fold(0.0, (sum, l) => sum + l.retailPrice),
      newLines: matching.length,
      uncollected: matching.fold(0.0, (sum, l) => sum + l.amountRemaining),
      totalProfit: matching.fold(0.0, (sum, l) => sum + l.profit),
    );
  }

  /// "Your balance with supplier companies" — a current snapshot, not
  /// period-filtered (matches the original mock's own behavior: this
  /// section never changed with the period pill either).
  List<CompanyBalance> get companyBalances => companies
      .map((c) => CompanyBalance(
            id: c.id,
            name: c.name,
            initials: c.initials,
            // CompanySummary has no single "type" (a company can have
            // both prepaid and credit-limit shipments) — this is a
            // cosmetic label only, so infer it: any amount owed implies
            // at least one credit-limit-style shipment.
            type: c.owedToCompany > 0 ? ShipmentType.creditLimit : ShipmentType.prepaid,
            usagePercent: c.usagePercent,
            consumed: c.consumed,
            availableToSell: c.availableToSell,
            owedToCompany: c.owedToCompany,
          ))
      .toList();

  /// Last 6 calendar months (including the current one), oldest first —
  /// zero-filled for months with no sales. Same bucketing approach as
  /// `ProfitsState.profitOverTime`.
  List<SalesProfitPoint> get salesProfitData {
    final sales = <DateTime, double>{for (var i = 5; i >= 0; i--) DateTime(now.year, now.month - i, 1): 0};
    final profit = <DateTime, double>{for (var i = 5; i >= 0; i--) DateTime(now.year, now.month - i, 1): 0};
    for (final line in lines) {
      final key = DateTime(line.purchaseDate.year, line.purchaseDate.month, 1);
      if (sales.containsKey(key)) {
        sales[key] = sales[key]! + line.retailPrice;
        profit[key] = profit[key]! + line.profit;
      }
    }
    return sales.keys.map((month) => SalesProfitPoint(label: monthAbbreviation(month), sales: sales[month]!, profit: profit[month]!)).toList();
  }

  List<ProfitTrendPoint> get profitTrendData {
    final buckets = <DateTime, double>{for (var i = 5; i >= 0; i--) DateTime(now.year, now.month - i, 1): 0};
    for (final line in lines) {
      final key = DateTime(line.purchaseDate.year, line.purchaseDate.month, 1);
      if (buckets.containsKey(key)) buckets[key] = buckets[key]! + line.profit;
    }
    return buckets.entries.map((e) => ProfitTrendPoint(label: monthAbbreviation(e.key), profit: e.value)).toList();
  }

  HomeState copyWith({
    List<LineSummary>? lines,
    List<CompanySummary>? companies,
    String? userName,
    PeriodFilter? selectedPeriod,
    DateTimeRange? customRange,
  }) {
    return HomeState(
      lines: lines ?? this.lines,
      companies: companies ?? this.companies,
      userName: userName ?? this.userName,
      now: now,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      customRange: customRange ?? this.customRange,
    );
  }

  @override
  List<Object?> get props => [lines, companies, userName, selectedPeriod, customRange, now];
}

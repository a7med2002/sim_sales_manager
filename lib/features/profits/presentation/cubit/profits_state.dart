import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show DateTimeRange;

import '../../../../core/catalog/company_summary.dart';
import '../../../../core/catalog/line_summary.dart';
import '../../../../core/constants/period_filter.dart';
import '../../../../core/utils/period_filter_matcher.dart';

/// One point on the "Profit Over Time" chart.
class ProfitPoint extends Equatable {
  final DateTime month;
  final double profit;

  const ProfitPoint({required this.month, required this.profit});

  @override
  List<Object?> get props => [month, profit];
}

/// Real figures derived from every sold Line (via `CustomerCatalog`) and
/// every active Company's running profit total (via `CompanyCatalog`) —
/// not mock data, since the app already tracks real profit per sale.
class ProfitsState extends Equatable {
  final List<LineSummary> lines;
  final List<CompanySummary> companies;
  final PeriodFilter selectedPeriod;
  final DateTimeRange? customRange;
  final DateTime now;

  const ProfitsState({
    required this.lines,
    required this.companies,
    required this.now,
    this.selectedPeriod = PeriodFilter.thisMonth,
    this.customRange,
  });

  double _profitWhere(bool Function(DateTime) matches) =>
      lines.where((l) => matches(l.purchaseDate)).fold(0.0, (sum, l) => sum + l.profit);

  int _countWhere(bool Function(DateTime) matches) => lines.where((l) => matches(l.purchaseDate)).length;

  double get yearProfit => _profitWhere((d) => d.year == now.year);
  int get yearOperations => _countWhere((d) => d.year == now.year);

  double get monthProfit => _profitWhere((d) => d.year == now.year && d.month == now.month);
  int get monthOperations => _countWhere((d) => d.year == now.year && d.month == now.month);

  double get weekProfit => _profitWhere((d) => !d.isAfter(now) && now.difference(d).inDays <= 7);
  int get weekOperations => _countWhere((d) => !d.isAfter(now) && now.difference(d).inDays <= 7);

  double get todayProfit => _profitWhere((d) => d.year == now.year && d.month == now.month && d.day == now.day);
  int get todayOperations => _countWhere((d) => d.year == now.year && d.month == now.month && d.day == now.day);

  List<LineSummary> get _selectedPeriodLines =>
      lines.where((l) => matchesPeriod(l.purchaseDate, selectedPeriod, now, customRange: customRange)).toList();

  int get selectedOperationsCount => _selectedPeriodLines.length;
  double get selectedNetProfit => _selectedPeriodLines.fold(0.0, (sum, l) => sum + l.profit);
  double get selectedTotalSales => _selectedPeriodLines.fold(0.0, (sum, l) => sum + l.retailPrice);

  /// Last 6 calendar months (including the current one), oldest first —
  /// zero-filled for months with no sales.
  List<ProfitPoint> get profitOverTime {
    final buckets = <DateTime, double>{
      for (var i = 5; i >= 0; i--) DateTime(now.year, now.month - i, 1): 0,
    };
    for (final line in lines) {
      final key = DateTime(line.purchaseDate.year, line.purchaseDate.month, 1);
      if (buckets.containsKey(key)) {
        buckets[key] = buckets[key]! + line.profit;
      }
    }
    return buckets.entries.map((e) => ProfitPoint(month: e.key, profit: e.value)).toList();
  }

  List<CompanySummary> get bestCompaniesByProfit {
    final sorted = [...companies]..sort((a, b) => b.profitGenerated.compareTo(a.profitGenerated));
    return sorted;
  }

  ProfitsState copyWith({
    List<LineSummary>? lines,
    List<CompanySummary>? companies,
    PeriodFilter? selectedPeriod,
    DateTimeRange? customRange,
  }) {
    return ProfitsState(
      lines: lines ?? this.lines,
      companies: companies ?? this.companies,
      now: now,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      customRange: customRange ?? this.customRange,
    );
  }

  @override
  List<Object?> get props => [lines, companies, selectedPeriod, customRange, now];
}

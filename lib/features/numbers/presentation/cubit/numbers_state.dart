import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show DateTimeRange;

import '../../../../core/catalog/company_summary.dart';
import '../../../../core/catalog/line_summary.dart';
import '../../../../core/constants/period_filter.dart';
import '../../../../core/utils/period_filter_matcher.dart';

class NumbersState extends Equatable {
  final List<LineSummary> lines;
  final List<CompanySummary> companies;
  final PeriodFilter period;
  final DateTimeRange? customRange;
  final String? companyFilter;
  final LineHealthStatus? statusFilter;
  final String searchQuery;
  final int pageSize;
  final DateTime now;

  const NumbersState({
    required this.lines,
    required this.companies,
    required this.now,
    this.period = PeriodFilter.all,
    this.customRange,
    this.companyFilter,
    this.statusFilter,
    this.searchQuery = '',
    this.pageSize = 50,
  });

  List<LineSummary> get filteredLines {
    final query = searchQuery.trim().toLowerCase();
    final filtered = lines.where((line) {
      if (!matchesPeriod(line.purchaseDate, period, now, customRange: customRange)) return false;
      if (companyFilter != null && line.companyName != companyFilter) return false;
      if (statusFilter != null && line.statusAt(now) != statusFilter) return false;
      if (query.isNotEmpty && !line.simNumber.toLowerCase().contains(query)) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));

    if (pageSize == -1) return filtered;
    return filtered.take(pageSize).toList();
  }

  int get totalMatchCount {
    final query = searchQuery.trim().toLowerCase();
    return lines.where((line) {
      if (!matchesPeriod(line.purchaseDate, period, now, customRange: customRange)) return false;
      if (companyFilter != null && line.companyName != companyFilter) return false;
      if (statusFilter != null && line.statusAt(now) != statusFilter) return false;
      if (query.isNotEmpty && !line.simNumber.toLowerCase().contains(query)) return false;
      return true;
    }).length;
  }

  NumbersState copyWith({
    List<LineSummary>? lines,
    List<CompanySummary>? companies,
    PeriodFilter? period,
    DateTimeRange? customRange,
    bool clearCompanyFilter = false,
    String? companyFilter,
    bool clearStatusFilter = false,
    LineHealthStatus? statusFilter,
    String? searchQuery,
    int? pageSize,
  }) {
    return NumbersState(
      lines: lines ?? this.lines,
      companies: companies ?? this.companies,
      now: now,
      period: period ?? this.period,
      customRange: customRange ?? this.customRange,
      companyFilter: clearCompanyFilter ? null : (companyFilter ?? this.companyFilter),
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      searchQuery: searchQuery ?? this.searchQuery,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props =>
      [lines, companies, period, customRange, companyFilter, statusFilter, searchQuery, pageSize, now];
}

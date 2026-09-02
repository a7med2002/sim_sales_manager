import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show DateTimeRange;

import '../../../../core/constants/period_filter.dart';
import '../../domain/entities/chart_point.dart';
import '../../domain/entities/company_balance.dart';
import '../../domain/entities/dashboard_stats.dart';

class HomeState extends Equatable {
  final String userName;
  final PeriodFilter selectedPeriod;
  final DateTimeRange? customRange;
  final DashboardStats stats;
  final List<CompanyBalance> companyBalances;
  final List<SalesProfitPoint> salesProfitData;
  final List<ProfitTrendPoint> profitTrendData;

  const HomeState({
    required this.userName,
    required this.selectedPeriod,
    required this.stats,
    required this.companyBalances,
    required this.salesProfitData,
    required this.profitTrendData,
    this.customRange,
  });

  HomeState copyWith({
    PeriodFilter? selectedPeriod,
    DateTimeRange? customRange,
    DashboardStats? stats,
  }) {
    return HomeState(
      userName: userName,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      customRange: customRange ?? this.customRange,
      stats: stats ?? this.stats,
      companyBalances: companyBalances,
      salesProfitData: salesProfitData,
      profitTrendData: profitTrendData,
    );
  }

  @override
  List<Object?> get props =>
      [userName, selectedPeriod, customRange, stats, companyBalances, salesProfitData, profitTrendData];
}

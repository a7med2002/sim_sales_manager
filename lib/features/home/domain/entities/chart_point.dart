import 'package:equatable/equatable.dart';

/// One month's bar-chart pair for the "Sales & Profit" chart.
class SalesProfitPoint extends Equatable {
  final String label;
  final double sales;
  final double profit;

  const SalesProfitPoint({required this.label, required this.sales, required this.profit});

  @override
  List<Object?> get props => [label, sales, profit];
}

/// One point on the "Profit Trend" line chart.
class ProfitTrendPoint extends Equatable {
  final String label;
  final double profit;

  const ProfitTrendPoint({required this.label, required this.profit});

  @override
  List<Object?> get props => [label, profit];
}

import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final int operations;
  final int companies;
  final double totalSales;
  final int newLines;
  final double uncollected;
  final double totalProfit;

  const DashboardStats({
    required this.operations,
    required this.companies,
    required this.totalSales,
    required this.newLines,
    required this.uncollected,
    required this.totalProfit,
  });

  @override
  List<Object?> get props => [operations, companies, totalSales, newLines, uncollected, totalProfit];
}

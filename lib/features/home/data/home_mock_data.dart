import '../../../core/constants/period_filter.dart';
import '../domain/entities/chart_point.dart';
import '../domain/entities/company_balance.dart';
import '../domain/entities/dashboard_stats.dart';
import '../presentation/cubit/home_state.dart';

/// Static mock/dummy data so the Home dashboard looks and feels alive
/// without any backend. Replace with a real repository once Drift/Supabase
/// are wired up.
class HomeMockData {
  HomeMockData._();

  static HomeState initialState() {
    return HomeState(
      userName: 'Ahmed',
      selectedPeriod: PeriodFilter.all,
      stats: statsFor(PeriodFilter.all),
      companyBalances: companyBalances,
      salesProfitData: salesProfitData,
      profitTrendData: profitTrendData,
    );
  }

  static DashboardStats statsFor(PeriodFilter period) {
    switch (period) {
      case PeriodFilter.all:
        return const DashboardStats(
          operations: 11,
          companies: 3,
          totalSales: 448,
          newLines: 11,
          uncollected: 140,
          totalProfit: 134,
        );
      case PeriodFilter.today:
        return const DashboardStats(
          operations: 1,
          companies: 1,
          totalSales: 45,
          newLines: 1,
          uncollected: 0,
          totalProfit: 12,
        );
      case PeriodFilter.thisWeek:
        return const DashboardStats(
          operations: 4,
          companies: 2,
          totalSales: 168,
          newLines: 4,
          uncollected: 40,
          totalProfit: 48,
        );
      case PeriodFilter.thisMonth:
        return const DashboardStats(
          operations: 9,
          companies: 4,
          totalSales: 367,
          newLines: 9,
          uncollected: 105,
          totalProfit: 110,
        );
      case PeriodFilter.threeMonths:
        return const DashboardStats(
          operations: 11,
          companies: 4,
          totalSales: 448,
          newLines: 11,
          uncollected: 140,
          totalProfit: 134,
        );
      case PeriodFilter.sixMonths:
        return const DashboardStats(
          operations: 15,
          companies: 4,
          totalSales: 612,
          newLines: 15,
          uncollected: 160,
          totalProfit: 178,
        );
      case PeriodFilter.thisYear:
        return const DashboardStats(
          operations: 22,
          companies: 4,
          totalSales: 940,
          newLines: 22,
          uncollected: 190,
          totalProfit: 260,
        );
      case PeriodFilter.custom:
        return const DashboardStats(
          operations: 0,
          companies: 0,
          totalSales: 0,
          newLines: 0,
          uncollected: 0,
          totalProfit: 0,
        );
    }
  }

  static const companyBalances = [
    CompanyBalance(
      id: 'jawwal',
      name: 'Jawwal',
      initials: 'J',
      type: ShipmentType.prepaid,
      usagePercent: 8,
      consumed: 168,
      availableToSell: 1832,
      owedToCompany: 300,
    ),
    CompanyBalance(
      id: 'ooredoo',
      name: 'Ooredoo',
      initials: 'O',
      type: ShipmentType.creditLimit,
      usagePercent: 9,
      consumed: 84,
      availableToSell: 816,
      owedToCompany: 600,
    ),
    CompanyBalance(
      id: 'airalo',
      name: 'Airalo eSIM',
      initials: 'AE',
      type: ShipmentType.prepaid,
      usagePercent: 10,
      consumed: 62,
      availableToSell: 538,
      owedToCompany: 0,
    ),
  ];

  static const salesProfitData = [
    SalesProfitPoint(label: 'Mar', sales: 0, profit: 0),
    SalesProfitPoint(label: 'Apr', sales: 0, profit: 0),
    SalesProfitPoint(label: 'May', sales: 0, profit: 0),
    SalesProfitPoint(label: 'Jun', sales: 0, profit: 0),
    SalesProfitPoint(label: 'Jul', sales: 230, profit: 25),
    SalesProfitPoint(label: 'Aug', sales: 340, profit: 95),
  ];

  static const profitTrendData = [
    ProfitTrendPoint(label: 'Mar', profit: 0),
    ProfitTrendPoint(label: 'Apr', profit: 0),
    ProfitTrendPoint(label: 'May', profit: 0),
    ProfitTrendPoint(label: 'Jun', profit: 2),
    ProfitTrendPoint(label: 'Jul', profit: 45),
    ProfitTrendPoint(label: 'Aug', profit: 100),
  ];
}

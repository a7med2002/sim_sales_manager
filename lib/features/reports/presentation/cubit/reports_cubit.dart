import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/catalog/company_catalog.dart';
import '../../../../core/catalog/customer_catalog.dart';
import '../../../../core/constants/period_filter.dart';
import 'reports_state.dart';

/// Reports reads real figures through [CustomerCatalog]/[CompanyCatalog]
/// (see core/catalog/ for why) — no writes happen here. `repName` is
/// this single-user app's owner name (per APP_CONTEXT.md, no multi-rep
/// system — every operation is attributed to the one user).
class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit({required CustomerCatalog customerCatalog, required CompanyCatalog companyCatalog, required String repName})
      : super(ReportsState(
          lines: customerCatalog.allLines,
          companies: companyCatalog.activeCompanies,
          repName: repName,
          now: DateTime.now(),
        ));

  void selectPeriod(PeriodFilter period) => emit(state.copyWith(period: period));

  void selectCustomRange(DateTimeRange range) => emit(state.copyWith(period: PeriodFilter.custom, customRange: range));

  void selectCompany(String? companyName) =>
      emit(state.copyWith(companyFilter: companyName, clearCompanyFilter: companyName == null));
}

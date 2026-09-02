import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/catalog/company_catalog.dart';
import '../../../../core/catalog/customer_catalog.dart';
import '../../../../core/catalog/line_summary.dart';
import '../../../../core/constants/period_filter.dart';
import 'numbers_state.dart';

/// Numbers is a read-only log of every sold Line/SIM across every
/// customer — it reads through [CustomerCatalog]/[CompanyCatalog]
/// instead of importing Customers/Companies directly (see
/// core/catalog/ for why). No writes happen here.
class NumbersCubit extends Cubit<NumbersState> {
  final CustomerCatalog _customerCatalog;

  NumbersCubit({required CustomerCatalog customerCatalog, required CompanyCatalog companyCatalog})
      : _customerCatalog = customerCatalog,
        super(NumbersState(
          lines: customerCatalog.allLines,
          companies: companyCatalog.activeCompanies,
          now: DateTime.now(),
        ));

  void refresh() {
    emit(state.copyWith(lines: _customerCatalog.allLines));
  }

  void periodChanged(PeriodFilter period) => emit(state.copyWith(period: period));

  void customRangeChanged(DateTimeRange range) =>
      emit(state.copyWith(period: PeriodFilter.custom, customRange: range));

  void companyFilterChanged(String? companyName) =>
      emit(state.copyWith(companyFilter: companyName, clearCompanyFilter: companyName == null));

  void statusFilterChanged(LineHealthStatus? status) =>
      emit(state.copyWith(statusFilter: status, clearStatusFilter: status == null));

  void searchChanged(String query) => emit(state.copyWith(searchQuery: query));

  void pageSizeChanged(int pageSize) => emit(state.copyWith(pageSize: pageSize));
}

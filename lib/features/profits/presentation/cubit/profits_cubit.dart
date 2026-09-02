import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/catalog/company_catalog.dart';
import '../../../../core/catalog/customer_catalog.dart';
import '../../../../core/constants/period_filter.dart';
import 'profits_state.dart';

/// Profits reads real figures through [CustomerCatalog]/[CompanyCatalog]
/// (see core/catalog/ for why) — no writes happen here.
class ProfitsCubit extends Cubit<ProfitsState> {
  ProfitsCubit({required CustomerCatalog customerCatalog, required CompanyCatalog companyCatalog})
      : super(ProfitsState(
          lines: customerCatalog.allLines,
          companies: companyCatalog.activeCompanies,
          now: DateTime.now(),
        ));

  void selectPeriod(PeriodFilter period) => emit(state.copyWith(selectedPeriod: period));

  void selectCustomRange(DateTimeRange range) =>
      emit(state.copyWith(selectedPeriod: PeriodFilter.custom, customRange: range));
}

import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/period_filter.dart';
import '../../data/home_mock_data.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeMockData.initialState());

  void selectPeriod(PeriodFilter period) {
    emit(state.copyWith(selectedPeriod: period, stats: HomeMockData.statsFor(period)));
  }

  /// Home's stats are still static mock data per period (see
  /// `HomeMockData`, not yet migrated to real derived figures like
  /// Profits/Reports), so a custom range has nothing real to filter —
  /// this reuses the same "custom" placeholder stats the pill already
  /// fell back to before, but now reached through an actual picker
  /// interaction instead of silently switching with no feedback.
  void selectCustomRange(DateTimeRange range) {
    emit(state.copyWith(
      selectedPeriod: PeriodFilter.custom,
      customRange: range,
      stats: HomeMockData.statsFor(PeriodFilter.custom),
    ));
  }
}

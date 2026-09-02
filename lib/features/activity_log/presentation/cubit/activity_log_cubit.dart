import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/activity_log_mock_data.dart';
import 'activity_log_state.dart';

/// Read-only for now — see `ActivityLogMockData` for why the data is
/// still static.
class ActivityLogCubit extends Cubit<ActivityLogState> {
  ActivityLogCubit() : super(ActivityLogState(entries: ActivityLogMockData.initialEntries()));

  void searchChanged(String query) => emit(state.copyWith(searchQuery: query));

  void pageSizeChanged(int pageSize) => emit(state.copyWith(pageSize: pageSize));
}

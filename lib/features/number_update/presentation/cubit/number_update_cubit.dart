import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/number_update_mock_data.dart';
import '../../domain/entities/number_update_entry.dart';
import 'number_update_state.dart';

/// Number Update: mock-only for now, per explicit instruction to build the
/// UI first — the real behavior (an automatic per-company lookup against
/// each supplier's own status-check URL) is a later pass. `submitUpdate`
/// simulates a successful manual refresh in the meantime; that's the only
/// place a future real implementation needs to change.
class NumberUpdateCubit extends Cubit<NumberUpdateState> {
  int _idCounter = 100;

  NumberUpdateCubit() : super(NumberUpdateState(log: NumberUpdateMockData.initialLog()));

  void phoneNumberChanged(String value) => emit(state.copyWith(phoneNumber: value));

  Future<void> submitUpdate() async {
    final number = state.phoneNumber.trim();
    if (number.isEmpty || state.isSubmitting) return;

    emit(state.copyWith(isSubmitting: true));
    await Future.delayed(const Duration(milliseconds: 900));

    final entry = NumberUpdateEntry(
      id: 'update-${_idCounter++}',
      phoneNumber: number,
      timestamp: DateTime.now(),
      status: NumberUpdateStatus.success,
      message: 'Status refreshed from the supplier platform.',
    );
    emit(state.copyWith(isSubmitting: false, log: [entry, ...state.log]));
  }
}

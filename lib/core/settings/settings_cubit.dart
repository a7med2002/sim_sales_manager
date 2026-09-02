import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_settings.dart';

/// Runtime-only for now (see `AppSettings`) — will persist via local
/// storage/Drift once that layer exists.
class SettingsCubit extends Cubit<AppSettings> {
  SettingsCubit() : super(const AppSettings());

  void updateCurrencySymbol(String symbol) {
    final trimmed = symbol.trim();
    if (trimmed.isEmpty) return;
    emit(state.copyWith(currencySymbol: trimmed));
  }
}

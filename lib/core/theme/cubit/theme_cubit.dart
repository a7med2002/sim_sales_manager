import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Global light/dark mode toggle. Runtime-only for now — persistence to
/// local storage will be added once the Drift/settings layer exists.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light);

  void toggle() {
    emit(state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }
}

import 'package:equatable/equatable.dart';

import '../constants/app_constants.dart';

/// App-wide preferences editable from Settings. Kept in `core/` (not a
/// feature) because `core/utils/currency_formatter.dart` — used by every
/// feature — needs to read `currencySymbol` reactively, and core must
/// never depend on a feature.
class AppSettings extends Equatable {
  final String currencySymbol;

  const AppSettings({this.currencySymbol = AppConstants.currencySymbol});

  AppSettings copyWith({String? currencySymbol}) {
    return AppSettings(currencySymbol: currencySymbol ?? this.currencySymbol);
  }

  @override
  List<Object?> get props => [currencySymbol];
}

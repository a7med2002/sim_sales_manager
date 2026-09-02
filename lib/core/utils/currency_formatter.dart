import '../di/service_locator.dart';
import '../settings/settings_cubit.dart';

String get _currencySymbol => getIt<SettingsCubit>().state.currencySymbol;

/// Formats a value as currency with the app's currency symbol and
/// thousands separators, e.g. 1832.0 -> "₪1,832.00".
String formatCurrency(double value) {
  final isNegative = value < 0;
  final fixed = value.abs().toStringAsFixed(2);
  final parts = fixed.split('.');
  final intPart = parts[0];

  final buffer = StringBuffer();
  for (var i = 0; i < intPart.length; i++) {
    final remaining = intPart.length - i;
    if (i != 0 && remaining % 3 == 0) buffer.write(',');
    buffer.write(intPart[i]);
  }

  return '${isNegative ? '-' : ''}$_currencySymbol$buffer.${parts[1]}';
}

/// Compact currency for chart axis labels, e.g. 340.0 -> "₪340".
String formatCurrencyCompact(double value) {
  return '$_currencySymbol${value.round()}';
}

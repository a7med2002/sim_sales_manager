import 'package:flutter/material.dart';

/// Opens the platform date-range picker for the "Custom" period option,
/// shared by every page with a `PeriodFilter` row (Home, Numbers, Profits,
/// Reports, Shipments & Operations) so "Custom" behaves identically
/// everywhere instead of each page wiring its own dialog. Returns `null`
/// if the user cancels — callers should leave the previously-selected
/// period untouched in that case, not switch to an empty "Custom" range.
///
/// Known limitation (Flutter framework, not this app): on very narrow
/// screens, `showDateRangePicker`'s built-in "fullscreen" layout packs its
/// header title and two actions into a single `Row` with no `Flexible` of
/// its own, which can overflow by a small margin regardless of font or
/// theme — reproduced even after resetting the dialog back to Flutter's
/// default Roboto type ramp, so it isn't caused by this app's custom
/// `fontFamily`. Only a fully custom date-range picker widget would avoid
/// it; out of scope here since it's cosmetic (debug-only overflow
/// banner; release builds just clip silently) and affects a stock
/// Flutter widget, not app-specific code.
Future<DateTimeRange?> pickCustomDateRange(BuildContext context, {DateTimeRange? initialRange}) {
  final now = DateTime.now();
  return showDateRangePicker(
    context: context,
    firstDate: DateTime(2020),
    lastDate: DateTime(2100),
    currentDate: now,
    initialDateRange: initialRange,
  );
}

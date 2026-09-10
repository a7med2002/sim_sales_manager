import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' show DateTimeRange;

const _monthKeys = [
  'jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec',
];

String _monthLabel(DateTime date) => 'common.months.${_monthKeys[date.month - 1]}'.tr();

/// Formats a date as "24 Aug 2026" — used across list rows/tables
/// (Customers, Numbers, Activity Log, ...) instead of each page
/// re-implementing the same month-name formatting. `.toLocal()` is a
/// deliberate safety net: every DateTime read back from Supabase
/// (`SyncEngine`'s `_xFromRow` mappers, and the admin cubits that read
/// straight from Supabase) is already converted at the source, but this
/// is the one place that guarantees a UTC value can never reach the
/// screen even if a future call site forgets to convert it —
/// `.toLocal()` on an already-local `DateTime` is a no-op, so this is
/// always safe to call.
String formatDate(DateTime date) {
  final local = date.toLocal();
  return '${local.day} ${_monthLabel(local)} ${local.year}';
}

/// Formats a date + time as "24 Aug 2026, 9:12 AM" — used wherever the
/// time-of-day matters too (Activity Log timestamps, Number Update
/// history, ...). See `formatDate`'s doc comment for why `.toLocal()`.
String formatDateTime(DateTime date) {
  final local = date.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour >= 12 ? 'common.pm'.tr() : 'common.am'.tr();
  return '${formatDate(local)}, $hour:$minute $period';
}

/// A *short* month abbreviation for tight spaces (chart axis labels —
/// Profits' "Profit Over Time"), kept separate from `formatDate`'s fuller
/// month name: English is already short ("Aug"), but Arabic month names
/// are full words and were overlapping each other across 6 narrow axis
/// slots — this uses a dedicated, deliberately short set of Arabic
/// abbreviations instead of reusing the full name.
String monthAbbreviation(DateTime date) => 'common.monthsShort.${_monthKeys[date.month - 1]}'.tr();

/// Formats a picked custom date range as "12 Aug – 20 Aug" for display on
/// the "Custom" filter pill itself, once a range has actually been chosen
/// — short enough to fit a pill, using the same short month abbreviation
/// as chart axis labels rather than `formatDate`'s fuller name.
String formatDateRangeShort(DateTimeRange range) {
  String short(DateTime d) => '${d.day} ${monthAbbreviation(d)}';
  return '${short(range.start)} – ${short(range.end)}';
}

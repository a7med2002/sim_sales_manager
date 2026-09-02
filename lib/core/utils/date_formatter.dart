import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' show DateTimeRange;

const _monthKeys = [
  'jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec',
];

String _monthLabel(DateTime date) => 'common.months.${_monthKeys[date.month - 1]}'.tr();

/// Formats a date as "24 Aug 2026" — used across list rows/tables
/// (Customers, Numbers, Activity Log, ...) instead of each page
/// re-implementing the same month-name formatting.
String formatDate(DateTime date) {
  return '${date.day} ${_monthLabel(date)} ${date.year}';
}

/// Formats a date + time as "24 Aug 2026, 9:12 AM" — used wherever the
/// time-of-day matters too (Activity Log timestamps, Trusted Devices'
/// first/last login and verification times).
String formatDateTime(DateTime date) {
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'common.pm'.tr() : 'common.am'.tr();
  return '${formatDate(date)}, $hour:$minute $period';
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

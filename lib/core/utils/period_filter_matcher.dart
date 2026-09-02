import 'package:flutter/material.dart' show DateTimeRange;

import '../constants/period_filter.dart';

/// Whether [date] falls within [period], relative to [now]. Shared by any
/// page that filters a real list of dated records by a `PeriodFilter`
/// (Numbers, Profits, Reports, Shipments & Operations). For `custom`,
/// [customRange] is the date range picked via `pickCustomDateRange` —
/// if the user has selected "Custom" but hasn't actually picked a range
/// yet (or a caller doesn't pass one), it falls back to matching
/// everything, same as `all`, rather than matching nothing.
bool matchesPeriod(DateTime date, PeriodFilter period, DateTime now, {DateTimeRange? customRange}) {
  switch (period) {
    case PeriodFilter.all:
      return true;
    case PeriodFilter.custom:
      if (customRange == null) return true;
      final start = DateTime(customRange.start.year, customRange.start.month, customRange.start.day);
      final end = DateTime(customRange.end.year, customRange.end.month, customRange.end.day, 23, 59, 59, 999);
      return !date.isBefore(start) && !date.isAfter(end);
    case PeriodFilter.today:
      return date.year == now.year && date.month == now.month && date.day == now.day;
    case PeriodFilter.thisWeek:
      return !date.isAfter(now) && now.difference(date).inDays <= 7;
    case PeriodFilter.thisMonth:
      return date.year == now.year && date.month == now.month;
    case PeriodFilter.threeMonths:
      return !date.isAfter(now) && now.difference(date).inDays <= 90;
    case PeriodFilter.sixMonths:
      return !date.isAfter(now) && now.difference(date).inDays <= 180;
    case PeriodFilter.thisYear:
      return date.year == now.year;
  }
}

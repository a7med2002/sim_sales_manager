import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sim_sales_manager/core/constants/period_filter.dart';
import 'package:sim_sales_manager/core/utils/period_filter_matcher.dart';

/// Pure-Dart tests for the "Custom" period's date-range matching — the
/// actual logic behind every page's "Custom" filter pill (Home, Numbers,
/// Profits, Reports, Shipments & Operations). Tested directly here rather
/// than by driving Flutter's native `showDateRangePicker` dialog through
/// a widget test, which would be far more fragile for the same reason
/// this codebase already avoids fighting `DropdownButtonFormField`/
/// `PopupMenuButton` reopen quirks in widget tests elsewhere.
void main() {
  final now = DateTime(2026, 8, 30);

  test('falls back to matching everything when no range has been picked yet', () {
    expect(matchesPeriod(DateTime(2020, 1, 1), PeriodFilter.custom, now), isTrue);
    expect(matchesPeriod(DateTime(2030, 1, 1), PeriodFilter.custom, now), isTrue);
  });

  test('matches dates inside the picked range, inclusive of both ends', () {
    final range = DateTimeRange(start: DateTime(2026, 8, 10), end: DateTime(2026, 8, 20));
    expect(matchesPeriod(DateTime(2026, 8, 10), PeriodFilter.custom, now, customRange: range), isTrue); // start of range
    expect(matchesPeriod(DateTime(2026, 8, 20, 23, 0), PeriodFilter.custom, now, customRange: range), isTrue); // later same day as end
    expect(matchesPeriod(DateTime(2026, 8, 15), PeriodFilter.custom, now, customRange: range), isTrue); // middle
  });

  test('excludes dates outside the picked range', () {
    final range = DateTimeRange(start: DateTime(2026, 8, 10), end: DateTime(2026, 8, 20));
    expect(matchesPeriod(DateTime(2026, 8, 9), PeriodFilter.custom, now, customRange: range), isFalse);
    expect(matchesPeriod(DateTime(2026, 8, 21), PeriodFilter.custom, now, customRange: range), isFalse);
  });

  test('a single-day range only matches that one day', () {
    final range = DateTimeRange(start: DateTime(2026, 8, 15), end: DateTime(2026, 8, 15));
    expect(matchesPeriod(DateTime(2026, 8, 15, 8), PeriodFilter.custom, now, customRange: range), isTrue);
    expect(matchesPeriod(DateTime(2026, 8, 15, 23, 59), PeriodFilter.custom, now, customRange: range), isTrue);
    expect(matchesPeriod(DateTime(2026, 8, 14, 23, 59), PeriodFilter.custom, now, customRange: range), isFalse);
    expect(matchesPeriod(DateTime(2026, 8, 16), PeriodFilter.custom, now, customRange: range), isFalse);
  });
}

import 'package:flutter/material.dart';

import '../constants/period_filter.dart';
import '../utils/date_formatter.dart';
import '../utils/date_range_picker.dart';
import 'filter_pill.dart';

/// Horizontal period-filter pill row (All/Today/.../Custom), shared by
/// every page with a `PeriodFilter` (Home, Numbers, Profits, Reports,
/// Shipments & Operations — the last one uses it twice, once per tab).
/// Tapping "Custom" opens a real date-range picker instead of just
/// selecting the bare enum value; once a range is picked, that pill's own
/// label shows the picked range (e.g. "12 Aug – 20 Aug") instead of the
/// word "Custom", so the choice stays visible instead of disappearing
/// back into a generic label. Cancelling the picker leaves whatever was
/// previously selected untouched.
class PeriodFilterRow extends StatelessWidget {
  final PeriodFilter selectedPeriod;
  final DateTimeRange? customRange;
  final ValueChanged<PeriodFilter> onPeriodSelected;
  final ValueChanged<DateTimeRange> onCustomRangeSelected;

  const PeriodFilterRow({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodSelected,
    required this.onCustomRangeSelected,
    this.customRange,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: FilterPillRow(
        labels: PeriodFilter.values.map((p) {
          if (p == PeriodFilter.custom && selectedPeriod == PeriodFilter.custom && customRange != null) {
            return formatDateRangeShort(customRange!);
          }
          return p.label;
        }).toList(),
        selectedIndex: PeriodFilter.values.indexOf(selectedPeriod),
        onSelected: (i) async {
          final period = PeriodFilter.values[i];
          if (period == PeriodFilter.custom) {
            final range = await pickCustomDateRange(context, initialRange: customRange);
            if (range != null) onCustomRangeSelected(range);
            return;
          }
          onPeriodSelected(period);
        },
      ),
    );
  }
}

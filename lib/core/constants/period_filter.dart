import 'package:easy_localization/easy_localization.dart';

/// Shared period-filter options reused across Home, Profits, Reports,
/// Numbers, and Shipments & Operations pages.
enum PeriodFilter {
  all,
  today,
  thisWeek,
  thisMonth,
  threeMonths,
  sixMonths,
  thisYear,
  custom,
}

extension PeriodFilterLabel on PeriodFilter {
  /// `tr()` works without a BuildContext once `EasyLocalization` is mounted
  /// anywhere in the tree, which is convenient here — this label is used
  /// from plain data mapping (`.map((p) => p.label)`), not widget build.
  String get label {
    switch (this) {
      case PeriodFilter.all:
        return 'periodFilter.all'.tr();
      case PeriodFilter.today:
        return 'periodFilter.today'.tr();
      case PeriodFilter.thisWeek:
        return 'periodFilter.thisWeek'.tr();
      case PeriodFilter.thisMonth:
        return 'periodFilter.thisMonth'.tr();
      case PeriodFilter.threeMonths:
        return 'periodFilter.threeMonths'.tr();
      case PeriodFilter.sixMonths:
        return 'periodFilter.sixMonths'.tr();
      case PeriodFilter.thisYear:
        return 'periodFilter.thisYear'.tr();
      case PeriodFilter.custom:
        return 'periodFilter.custom'.tr();
    }
  }
}

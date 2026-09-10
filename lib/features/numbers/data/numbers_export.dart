import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/catalog/line_summary.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/package_display.dart';
import '../../../../core/utils/table_export.dart';

/// Exports [lines] (already filtered/sorted by the caller — see
/// `NumbersState.exportLines`, which deliberately ignores the page-size
/// cap so an export always covers everything matching the current
/// filters, not just what's on screen) to [format] via the shared
/// `core/utils/table_export.dart` builder.
Future<void> exportNumbers({
  required BuildContext context,
  required List<LineSummary> lines,
  required TableExportFormat format,
}) {
  final headers = [
    'numbers.table.number'.tr(),
    'numbers.table.company'.tr(),
    'numbers.table.package'.tr(),
    'numbers.table.status'.tr(),
    'numbers.table.dateAdded'.tr(),
    'numbers.table.expiryDate'.tr(),
  ];
  final now = DateTime.now();
  final rows = lines
      .map((l) => [
            l.simNumber,
            l.companyName,
            packageDisplayLabel(l.packageName, l.packageSimType),
            l.statusAt(now).label,
            formatDate(l.purchaseDate),
            formatDate(l.expiryDate),
          ])
      .toList();

  return exportTable(
    context: context,
    title: 'numbers.title'.tr(),
    headers: headers,
    rows: rows,
    format: format,
    fileNamePrefix: 'numbers',
  );
}

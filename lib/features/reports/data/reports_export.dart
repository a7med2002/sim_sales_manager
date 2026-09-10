import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/catalog/line_summary.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/package_display.dart';
import '../../../../core/utils/table_export.dart';

/// Exports the Reports page's operations table (same columns as
/// `_OperationsTable`) via the shared `core/utils/table_export.dart`
/// builder.
Future<void> exportReportLines({
  required BuildContext context,
  required List<LineSummary> lines,
  required String repName,
  required TableExportFormat format,
}) {
  final headers = [
    'reports.table.date'.tr(),
    'reports.table.simNumber'.tr(),
    'reports.table.customer'.tr(),
    'reports.table.company'.tr(),
    'reports.table.package'.tr(),
    'reports.table.salePrice'.tr(),
    'reports.table.profit'.tr(),
    'reports.table.payment'.tr(),
    'reports.table.rep'.tr(),
  ];
  final rows = lines
      .map((l) => [
            formatDate(l.purchaseDate),
            l.simNumber,
            l.customerName,
            l.companyName,
            packageDisplayLabel(l.packageName, l.packageSimType),
            formatCurrency(l.retailPrice),
            formatCurrency(l.profit),
            l.paymentStatus.label,
            repName,
          ])
      .toList();

  return exportTable(
    context: context,
    title: 'reports.title'.tr(),
    headers: headers,
    rows: rows,
    format: format,
    fileNamePrefix: 'report',
  );
}

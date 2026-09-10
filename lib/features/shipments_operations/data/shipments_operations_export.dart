import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/catalog/line_summary.dart';
import '../../../../core/utils/package_display.dart';
import '../../../../core/utils/table_export.dart';

/// Exports the Operations tab's table (same columns shown on screen)
/// via the shared `core/utils/table_export.dart` builder.
Future<void> exportOperationLines({
  required BuildContext context,
  required List<LineSummary> lines,
  required TableExportFormat format,
}) {
  final headers = [
    'shipmentsOperations.operationsTab.table.simNumber'.tr(),
    'shipmentsOperations.operationsTab.table.company'.tr(),
    'shipmentsOperations.operationsTab.table.customer'.tr(),
    'shipmentsOperations.operationsTab.table.contact'.tr(),
    'shipmentsOperations.operationsTab.table.duration'.tr(),
  ];
  final rows = lines
      .map((l) => [
            l.simNumber,
            l.companyName,
            l.customerName,
            l.customerContact,
            packageDisplayLabel(l.packageName, l.packageSimType),
          ])
      .toList();

  return exportTable(
    context: context,
    title: 'shipmentsOperations.title'.tr(),
    headers: headers,
    rows: rows,
    format: format,
    fileNamePrefix: 'operations',
  );
}

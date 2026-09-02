import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/catalog/company_catalog.dart';
import '../../../../core/catalog/customer_catalog.dart';
import '../../../../core/catalog/line_summary.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/navigation/new_sale_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/balance_progress_card.dart';
import '../../../../core/widgets/company_filter_dropdown.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/filter_pill.dart';
import '../../../../core/widgets/page_size_dropdown.dart';
import '../../../../core/widgets/period_filter_row.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../domain/entities/shipment.dart';
import '../cubit/shipments_operations_cubit.dart';
import '../cubit/shipments_operations_state.dart';
import '../widgets/operation_detail_sheet.dart';
import '../widgets/shipment_form_sheet.dart';

/// Shipments & Operations: the largest and last of More's 8 sub-pages.
/// Two tabs — Shipments (balance top-ups) and Operations (the sale
/// transaction log) — matching APP_CONTEXT.md's "1. Shipments &
/// Operations" spec (no reference screenshot exists for this page).
class ShipmentsOperationsPage extends StatelessWidget {
  const ShipmentsOperationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ShipmentsOperationsCubit(companyCatalog: getIt<CompanyCatalog>(), customerCatalog: getIt<CustomerCatalog>()),
      child: const _ShipmentsOperationsView(),
    );
  }
}

class _ShipmentsOperationsView extends StatelessWidget {
  const _ShipmentsOperationsView();

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('common.comingSoon'.tr())));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: BlocBuilder<ShipmentsOperationsCubit, ShipmentsOperationsState>(
          builder: (context, state) {
            final cubit = context.read<ShipmentsOperationsCubit>();

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal).copyWith(
                top: AppSpacing.md,
                bottom: AppSpacing.xl,
              ),
              children: [
                AppTopBar(title: 'shipmentsOperations.title'.tr(), showBack: true),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: FilterPill(label: 'shipmentsOperations.tabs.shipments'.tr(), isActive: state.tabIndex == 0, onTap: () => cubit.selectTab(0)),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: FilterPill(label: 'shipmentsOperations.tabs.operations'.tr(), isActive: state.tabIndex == 1, onTap: () => cubit.selectTab(1)),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (state.tabIndex == 0) _ShipmentsTab(state: state, cubit: cubit) else _OperationsTab(state: state, cubit: cubit, onComingSoon: () => _comingSoon(context)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ShipmentsTab extends StatelessWidget {
  final ShipmentsOperationsState state;
  final ShipmentsOperationsCubit cubit;

  const _ShipmentsTab({required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shipments = state.filteredShipments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: colors.border),
          ),
          child: Text(
            'shipmentsOperations.shipmentsTab.infoBanner'.tr(),
            style: AppTextStyles.body(colors.textSecondary),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => ShipmentFormSheet.show(
              context,
              companies: state.companies,
              onSave: (company, type, total, paid, method, date, ref, notes) => cubit.addShipment(
                companyId: company.id,
                companyName: company.name,
                companyInitials: company.initials,
                type: type,
                totalAmount: total,
                amountPaid: paid,
                paymentMethod: method,
                date: date,
                referenceNumber: ref,
                notes: notes,
              ),
            ),
            icon: Icon(Icons.add_rounded, color: colors.onPrimaryAction, size: 18),
            label: Text('shipmentsOperations.shipmentsTab.newShipment'.tr(), style: AppTextStyles.cardTitle(colors.onPrimaryAction)),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primaryAction,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button)),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('shipmentsOperations.shipmentsTab.balanceSectionTitle'.tr(), style: AppTextStyles.overline(colors.textSecondary)),
        const SizedBox(height: AppSpacing.sm),
        if (state.companies.isEmpty)
          EmptyState(
            icon: Icons.apartment_rounded,
            title: 'shipmentsOperations.shipmentsTab.empty.title'.tr(),
            description: 'shipmentsOperations.shipmentsTab.empty.description'.tr(),
          )
        else
          ...state.companies.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
                child: BalanceProgressCard(
                  name: c.name,
                  initials: c.initials,
                  typeLabel: '',
                  usagePercent: c.usagePercent,
                  consumed: c.consumed,
                  availableToSell: c.availableToSell,
                  owedToCompany: c.owedToCompany,
                ),
              )),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: colors.primaryAction, width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(child: _TotalStat(label: 'shipmentsOperations.shipmentsTab.totalShipments'.tr(), value: formatCurrency(state.totalShipmentsAmount))),
              Expanded(child: _TotalStat(label: 'shipmentsOperations.shipmentsTab.paid'.tr(), value: formatCurrency(state.totalPaidAmount))),
              Expanded(
                child: _TotalStat(
                  label: 'shipmentsOperations.shipmentsTab.remaining'.tr(),
                  value: formatCurrency(state.totalRemainingAmount),
                  valueColor: state.totalRemainingAmount > 0 ? colors.danger : null,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        CompanyFilterDropdown(
          companies: state.companies,
          value: state.shipmentCompanyFilter,
          onChanged: cubit.shipmentCompanyFilterChanged,
        ),
        const SizedBox(height: AppSpacing.sm),
        PeriodFilterRow(
          selectedPeriod: state.shipmentPeriod,
          customRange: state.shipmentCustomRange,
          onPeriodSelected: cubit.shipmentPeriodChanged,
          onCustomRangeSelected: cubit.shipmentCustomRangeChanged,
        ),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerRight,
          child: PageSizeDropdown(value: state.shipmentPageSize, onChanged: cubit.shipmentPageSizeChanged),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (shipments.isEmpty)
          EmptyState(
            icon: Icons.local_shipping_outlined,
            title: 'shipmentsOperations.shipmentsTab.emptyShipments.title'.tr(),
            description: 'shipmentsOperations.shipmentsTab.emptyShipments.description'.tr(),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadii.card),
              border: Border.all(color: colors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.card),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(colors.background),
                  headingTextStyle: AppTextStyles.body(colors.textSecondary).copyWith(fontWeight: FontWeight.w600),
                  dataTextStyle: AppTextStyles.body(colors.textPrimary),
                  dividerThickness: 1,
                  columns: [
                    DataColumn(label: Text('shipmentsOperations.shipmentsTab.table.company'.tr())),
                    DataColumn(label: Text('shipmentsOperations.shipmentsTab.table.type'.tr())),
                    DataColumn(label: Text('shipmentsOperations.shipmentsTab.table.date'.tr())),
                    DataColumn(label: Text('shipmentsOperations.shipmentsTab.table.totalAmount'.tr())),
                  ],
                  rows: shipments
                      .map((s) => DataRow(
                            onSelectChanged: (_) => _showShipmentDetail(context, s),
                            cells: [
                              DataCell(Text(s.companyName)),
                              DataCell(Text(s.type.label)),
                              DataCell(Text(formatDate(s.date))),
                              DataCell(Text(formatCurrency(s.totalAmount))),
                            ],
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showShipmentDetail(BuildContext context, Shipment shipment) {
    final colors = context.colors;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: BoxDecoration(color: colors.background, borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.card))),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('shipmentsOperations.shipmentsTab.detail.title'.tr(), style: AppTextStyles.sectionHeader(colors.textPrimary)),
                    GestureDetector(onTap: () => Navigator.of(sheetContext).pop(), child: Icon(Icons.close_rounded, color: colors.textSecondary)),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _detailRow(context, 'shipmentsOperations.shipmentsTab.detail.company'.tr(), shipment.companyName),
                _detailRow(context, 'shipmentsOperations.shipmentsTab.detail.type'.tr(), shipment.type.label),
                _detailRow(context, 'shipmentsOperations.shipmentsTab.detail.date'.tr(), formatDate(shipment.date)),
                _detailRow(context, 'shipmentsOperations.shipmentsTab.detail.totalAmount'.tr(), formatCurrency(shipment.totalAmount)),
                _detailRow(context, 'shipmentsOperations.shipmentsTab.detail.amountPaid'.tr(), formatCurrency(shipment.amountPaid)),
                _detailRow(context, 'shipmentsOperations.shipmentsTab.detail.remaining'.tr(), formatCurrency(shipment.amountRemaining), valueColor: shipment.amountRemaining > 0 ? colors.danger : null),
                _detailRow(context, 'shipmentsOperations.shipmentsTab.detail.paymentMethod'.tr(), shipment.paymentMethod),
                if (shipment.referenceNumber.isNotEmpty) _detailRow(context, 'shipmentsOperations.shipmentsTab.detail.referenceNumber'.tr(), shipment.referenceNumber),
                if (shipment.notes.isNotEmpty) _detailRow(context, 'shipmentsOperations.shipmentsTab.detail.notes'.tr(), shipment.notes),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value, {Color? valueColor}) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body(colors.textSecondary)),
          Flexible(
            child: Text(value, style: AppTextStyles.cardTitle(valueColor ?? colors.textPrimary), textAlign: TextAlign.right, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class _TotalStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _TotalStat({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.body(colors.textSecondary)),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.cardTitle(valueColor ?? colors.textPrimary)),
      ],
    );
  }
}

class _OperationsTab extends StatefulWidget {
  final ShipmentsOperationsState state;
  final ShipmentsOperationsCubit cubit;
  final VoidCallback onComingSoon;

  const _OperationsTab({required this.state, required this.cubit, required this.onComingSoon});

  @override
  State<_OperationsTab> createState() => _OperationsTabState();
}

class _OperationsTabState extends State<_OperationsTab> {
  final Set<String> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = widget.state;
    final cubit = widget.cubit;
    final followUp = state.needsFollowUp;
    final lines = state.filteredLines;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.hourglass_bottom_rounded,
                iconColor: colors.warning,
                title: 'shipmentsOperations.operationsTab.partiallyPaid'.tr(),
                value: '${state.partiallyPaidCount}',
              ),
            ),
            const SizedBox(width: AppSpacing.cardGap),
            Expanded(
              child: StatCard(icon: Icons.cancel_outlined, iconColor: colors.danger, title: 'shipmentsOperations.operationsTab.unpaid'.tr(), value: '${state.unpaidCount}'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.cardGap),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.notifications_active_outlined,
                iconColor: colors.warning,
                title: 'shipmentsOperations.operationsTab.needsFollowUp'.tr(),
                value: '${followUp.total}',
                caption: 'shipmentsOperations.operationsTab.followUpCaption'.tr(namedArgs: {
                  'overdue': '${followUp.overdue}',
                  'today': '${followUp.today}',
                  'soon': '${followUp.expiringSoon}',
                }),
              ),
            ),
            const SizedBox(width: AppSpacing.cardGap),
            Expanded(
              child: StatCard(
                icon: Icons.error_outline_rounded,
                iconColor: colors.danger,
                title: 'shipmentsOperations.operationsTab.toCollect'.tr(),
                value: formatCurrency(state.amountToCollect),
                valueColor: state.amountToCollect > 0 ? colors.danger : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        PeriodFilterRow(
          selectedPeriod: state.operationsPeriod,
          customRange: state.operationsCustomRange,
          onPeriodSelected: cubit.operationsPeriodChanged,
          onCustomRangeSelected: cubit.operationsCustomRangeChanged,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _statusPill(context, 'common.all'.tr(), null),
            _statusPill(context, LinePaymentStatus.paid.label, LinePaymentStatus.paid),
            _statusPill(context, LinePaymentStatus.partial.label, LinePaymentStatus.partial),
            _statusPill(context, LinePaymentStatus.unpaid.label, LinePaymentStatus.unpaid),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          onChanged: cubit.operationsSearchChanged,
          style: AppTextStyles.body(colors.textPrimary),
          decoration: InputDecoration(
            hintText: 'shipmentsOperations.operationsTab.searchHint'.tr(),
            hintStyle: AppTextStyles.body(colors.textSecondary),
            prefixIcon: Icon(Icons.search_rounded, color: colors.textSecondary, size: 20),
            filled: true,
            fillColor: colors.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.button), borderSide: BorderSide(color: colors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.button), borderSide: BorderSide(color: colors.border)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.button),
              borderSide: BorderSide(color: colors.primaryAction, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            ElevatedButton.icon(
              onPressed: () => NewSaleLauncher.open(context),
              icon: Icon(Icons.add_rounded, color: colors.onPrimaryAction, size: 16),
              label: Text('shipmentsOperations.operationsTab.addOperation'.tr(), style: AppTextStyles.body(colors.onPrimaryAction)),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primaryAction,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button)),
                elevation: 0,
              ),
            ),
            OutlinedButton.icon(
              onPressed: widget.onComingSoon,
              icon: Icon(Icons.table_chart_outlined, size: 16, color: colors.textPrimary),
              label: Text('shipmentsOperations.operationsTab.exportExcel'.tr(), style: AppTextStyles.body(colors.textPrimary)),
              style: OutlinedButton.styleFrom(foregroundColor: colors.textPrimary, side: BorderSide(color: colors.border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button))),
            ),
            OutlinedButton.icon(
              onPressed: widget.onComingSoon,
              icon: Icon(Icons.file_upload_outlined, size: 16, color: colors.textPrimary),
              label: Text('shipmentsOperations.operationsTab.import'.tr(), style: AppTextStyles.body(colors.textPrimary)),
              style: OutlinedButton.styleFrom(foregroundColor: colors.textPrimary, side: BorderSide(color: colors.border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button))),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (lines.isEmpty)
          EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'shipmentsOperations.operationsTab.empty.title'.tr(),
            description: 'shipmentsOperations.operationsTab.empty.description'.tr(),
          )
        else
          Container(
            decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(AppRadii.card), border: Border.all(color: colors.border)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.card),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(colors.background),
                  headingTextStyle: AppTextStyles.body(colors.textSecondary).copyWith(fontWeight: FontWeight.w600),
                  dataTextStyle: AppTextStyles.body(colors.textPrimary),
                  dividerThickness: 1,
                  columns: [
                    const DataColumn(label: Text('')),
                    DataColumn(label: Text('shipmentsOperations.operationsTab.table.simNumber'.tr())),
                    DataColumn(label: Text('shipmentsOperations.operationsTab.table.company'.tr())),
                    DataColumn(label: Text('shipmentsOperations.operationsTab.table.customer'.tr())),
                    DataColumn(label: Text('shipmentsOperations.operationsTab.table.contact'.tr())),
                    DataColumn(label: Text('shipmentsOperations.operationsTab.table.duration'.tr())),
                  ],
                  rows: lines
                      .map((line) => DataRow(
                            onSelectChanged: (_) => OperationDetailSheet.show(context, line),
                            cells: [
                              DataCell(Checkbox(
                                value: _selectedIds.contains(line.id),
                                onChanged: (checked) => setState(() {
                                  if (checked ?? false) {
                                    _selectedIds.add(line.id);
                                  } else {
                                    _selectedIds.remove(line.id);
                                  }
                                }),
                              )),
                              DataCell(Text(line.simNumber)),
                              DataCell(Text(line.companyName)),
                              DataCell(Text(line.customerName)),
                              DataCell(Text(line.customerContact)),
                              DataCell(Text(line.packageName)),
                            ],
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _statusPill(BuildContext context, String label, LinePaymentStatus? status) {
    final colors = context.colors;
    final isActive = widget.state.operationsStatusFilter == status;
    return GestureDetector(
      onTap: () => widget.cubit.operationsStatusFilterChanged(status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isActive ? colors.primaryAction : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: isActive ? colors.primaryAction : colors.border),
        ),
        child: Text(label, style: AppTextStyles.body(isActive ? colors.onPrimaryAction : colors.textPrimary).copyWith(fontWeight: FontWeight.w500)),
      ),
    );
  }
}

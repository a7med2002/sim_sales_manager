import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/catalog/customer_catalog.dart';
import '../../../../core/catalog/line_summary.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/company.dart';
import '../cubit/companies_cubit.dart';
import '../widgets/company_form_sheet.dart';

/// Company Detail: header (name/notes + edit), balance-usage card (same
/// consumed/available/owed shape as the Companies list card), and every
/// Line ever bought from this company — read-only here (editing a Line
/// stays a Customer Detail action, so this only reads through
/// `CustomerCatalog.allLines`, never `Line`/`LineCard` from the
/// Customers feature directly — no cross-feature imports except through
/// core/, per CLAUDE.md).
class CompanyDetailPage extends StatelessWidget {
  final String companyId;

  const CompanyDetailPage({super.key, required this.companyId});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cubit = context.watch<CompaniesCubit>();
    final company = cubit.state.companies.firstWhere((c) => c.id == companyId);
    final lines = getIt<CustomerCatalog>().allLines.where((l) => l.companyId == companyId).toList()
      ..sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal).copyWith(
            top: AppSpacing.md,
            bottom: AppSpacing.xl,
          ),
          children: [
            _DetailHeader(company: company),
            const SizedBox(height: AppSpacing.md),
            _CompanySummaryCard(company: company),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'companies.detail.linesSection'.tr(namedArgs: {'count': '${lines.length}'}),
              style: AppTextStyles.overline(colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (lines.isEmpty)
              EmptyState(
                icon: Icons.sim_card_outlined,
                title: 'companies.detail.emptyLinesTitle'.tr(),
                description: 'companies.detail.emptyLinesDescription'.tr(),
              )
            else
              ...lines.map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
                  child: _LineTile(line: line),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  final Company company;

  const _DetailHeader({required this.company});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cubit = context.read<CompaniesCubit>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(company.name, style: AppTextStyles.pageTitle(colors.textPrimary)),
              if (company.notes.isNotEmpty) Text(company.notes, style: AppTextStyles.body(colors.textSecondary)),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => CompanyFormSheet.show(
            context,
            company: company,
            onSave: (name, notes, packages) => cubit.updateCompany(company.id, name: name, notes: notes, packages: packages),
          ),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: colors.border)),
            alignment: Alignment.center,
            child: Icon(Icons.edit_outlined, size: 18, color: colors.textPrimary),
          ),
        ),
      ],
    );
  }
}

class _CompanySummaryCard extends StatelessWidget {
  final Company company;

  const _CompanySummaryCard({required this.company});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _SummaryStat(label: 'companies.card.packagesOperations'.tr(namedArgs: {
                'packages': '${company.packages.length}',
                'operations': '${company.operationsCount}',
              })),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('companies.card.profitGenerated'.tr(), style: AppTextStyles.body(colors.textSecondary)),
              Text(formatCurrency(company.profitGenerated), style: AppTextStyles.cardTitle(colors.success)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('companies.card.balanceUsed'.tr(), style: AppTextStyles.body(colors.textSecondary)),
              Text('${company.usagePercent}%', style: AppTextStyles.body(colors.textSecondary)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: LinearProgressIndicator(
              value: (company.usagePercent / 100).clamp(0, 1).toDouble(),
              minHeight: 6,
              backgroundColor: colors.border,
              valueColor: AlwaysStoppedAnimation(colors.primaryAction),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _DataColumn(label: 'companies.card.consumed'.tr(), value: formatCurrency(company.consumed), color: colors.textPrimary),
              _DataColumn(label: 'companies.card.availableToSell'.tr(), value: formatCurrency(company.availableToSell), color: colors.textPrimary),
              _DataColumn(
                label: 'companies.card.owedToCompany'.tr(),
                value: formatCurrency(company.owedToCompany),
                color: company.owedToCompany > 0 ? colors.danger : colors.textPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;

  const _SummaryStat({required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Text(label, style: AppTextStyles.body(colors.textSecondary));
  }
}

class _DataColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DataColumn({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.body(colors.textSecondary)),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.cardTitle(color)),
        ],
      ),
    );
  }
}

class _LineTile extends StatelessWidget {
  final LineSummary line;

  const _LineTile({required this.line});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final status = line.statusAt(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(line.packageName, style: AppTextStyles.cardTitle(colors.textPrimary)),
                    Text(
                      '${line.customerName} · ${line.simNumber}',
                      style: AppTextStyles.body(colors.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _paymentBadge(line.paymentStatus),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(height: 1, color: colors.border),
          const SizedBox(height: AppSpacing.sm),
          _row(context, 'customers.line.purchaseDate'.tr(), formatDate(line.purchaseDate)),
          _row(context, 'customers.line.retailSalePrice'.tr(), formatCurrency(line.retailPrice)),
          _row(context, 'customers.line.profit'.tr(), formatCurrency(line.profit), valueColor: colors.success),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('customers.line.expiryDate'.tr(), style: AppTextStyles.body(colors.textSecondary)),
              _lineHealthBadge(status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value, {Color? valueColor}) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body(colors.textSecondary)),
          Text(value, style: AppTextStyles.body(valueColor ?? colors.textPrimary).copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _paymentBadge(LinePaymentStatus status) {
    switch (status) {
      case LinePaymentStatus.paid:
        return StatusBadge(label: status.label, type: StatusBadgeType.success);
      case LinePaymentStatus.partial:
        return StatusBadge(label: status.label, type: StatusBadgeType.warning);
      case LinePaymentStatus.unpaid:
        return StatusBadge(label: status.label, type: StatusBadgeType.danger);
    }
  }

  Widget _lineHealthBadge(LineHealthStatus status) {
    switch (status) {
      case LineHealthStatus.active:
        return StatusBadge(label: status.label, type: StatusBadgeType.success);
      case LineHealthStatus.expiringSoon:
        return StatusBadge(label: status.label, type: StatusBadgeType.warning);
      case LineHealthStatus.expired:
        return StatusBadge(label: status.label, type: StatusBadgeType.danger);
    }
  }
}

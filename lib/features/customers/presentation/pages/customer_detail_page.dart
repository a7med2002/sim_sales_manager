import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/catalog/company_catalog.dart';
import '../../../../core/catalog/company_summary.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/notifications/notifications_cubit.dart';
import '../../../../core/notifications/notifications_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/contact_launcher.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/line.dart';
import '../cubit/customers_cubit.dart';
import '../cubit/customers_state.dart';
import '../widgets/add_payment_sheet.dart';
import '../widgets/additional_service_sheet.dart';
import '../widgets/customer_form_sheet.dart';
import '../widgets/line_card.dart';
import '../widgets/line_form_sheet.dart';

/// Customer Detail: header (name/contact + edit/delete or restore/delete
/// actions), summary card, "+ Add Line", and the full list of the
/// customer's Lines/SIMs. Matches design/screenshots/customer details.png.
class CustomerDetailPage extends StatelessWidget {
  final String customerId;

  const CustomerDetailPage({super.key, required this.customerId});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocBuilder<CustomersCubit, CustomersState>(
      builder: (context, state) {
        final cubit = context.read<CustomersCubit>();
        final customer = state.customers.firstWhere((c) => c.id == customerId);
        final lines = state.linesFor(customerId);
        final companies = getIt<CompanyCatalog>().activeCompanies;
        final totalSpent = state.totalSpentFor(customerId);
        final totalOwed = state.totalOwedFor(customerId);

        CompanySummary? companyFor(String? companyId) {
          if (companyId == null) return null;
          for (final c in companies) {
            if (c.id == companyId) return c;
          }
          return null;
        }

        void addLine(
          String sim,
          String companyId,
          String company,
          String initials,
          String? packageId,
          String package,
          String? packageSimType,
          DateTime purchase,
          DateTime expiry,
          double wholesale,
          double retail,
          PaymentStatus status,
          double paid,
          double remaining,
        ) =>
            cubit.addLine(
              customerId,
              simNumber: sim,
              companyId: companyId,
              companyName: company,
              companyInitials: initials,
              packageId: packageId,
              packageName: package,
              packageSimType: packageSimType,
              purchaseDate: purchase,
              expiryDate: expiry,
              wholesaleCost: wholesale,
              retailPrice: retail,
              paymentStatus: status,
              amountPaid: paid,
              amountRemaining: remaining,
            );

        return Scaffold(
          backgroundColor: colors.background,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => LineFormSheet.show(context, companies: companies, onSave: addLine),
            backgroundColor: colors.primaryAction,
            foregroundColor: colors.onPrimaryAction,
            icon: const Icon(Icons.add_rounded),
            label: Text('customers.detail.addLine'.tr(), style: AppTextStyles.cardTitle(colors.onPrimaryAction)),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal).copyWith(
                top: AppSpacing.md,
                bottom: AppSpacing.xl,
              ),
              children: [
                _DetailHeader(customer: customer, cubit: cubit),
                const SizedBox(height: AppSpacing.md),
                _CustomerSummaryCard(customer: customer),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(child: _SummaryStat(label: 'customers.detail.linesStat'.tr(), value: '${lines.length}')),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: _SummaryStat(label: 'customers.detail.totalSpentStat'.tr(), value: formatCurrency(totalSpent))),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _SummaryStat(
                        label: 'customers.detail.owedStat'.tr(),
                        value: formatCurrency(totalOwed),
                        valueColor: totalOwed > 0 ? colors.danger : null,
                      ),
                    ),
                  ],
                ),
                if (totalOwed > 0) ...[
                  const SizedBox(height: AppSpacing.md),
                  _DebtReminderRow(customerId: customerId, customerName: customer.name, amountOwed: totalOwed),
                ],
                const SizedBox(height: AppSpacing.lg),
                Text('customers.detail.linesSection'.tr(), style: AppTextStyles.overline(colors.textSecondary)),
                const SizedBox(height: AppSpacing.sm),
                if (lines.isEmpty)
                  EmptyState(
                    icon: Icons.sim_card_outlined,
                    title: 'customers.detail.emptyLinesTitle'.tr(),
                    description: 'customers.detail.emptyLinesDescription'.tr(),
                  )
                else
                  ...lines.map(
                    (line) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
                      child: LineCard(
                        line: line,
                        onEdit: () => LineFormSheet.show(
                          context,
                          line: line,
                          companies: companies,
                          onSave: (sim, companyId, company, initials, packageId, package, packageSimType, purchase, expiry, wholesale, retail, status, paid, remaining) =>
                              cubit.updateLine(
                            line.id,
                            simNumber: sim,
                            companyId: companyId,
                            companyName: company,
                            companyInitials: initials,
                            packageId: packageId,
                            packageName: package,
                            packageSimType: packageSimType,
                            purchaseDate: purchase,
                            expiryDate: expiry,
                            wholesaleCost: wholesale,
                            retailPrice: retail,
                            paymentStatus: status,
                            amountPaid: paid,
                            amountRemaining: remaining,
                          ),
                        ),
                        onDelete: () => showConfirmDialog(
                          context,
                          title: 'customers.detail.deleteLineDialog.title'.tr(),
                          message: 'customers.detail.deleteLineDialog.message'.tr(),
                          confirmLabel: 'customers.detail.deleteLineDialog.confirm'.tr(),
                          onConfirm: () => cubit.deleteLine(line.id),
                        ),
                        onAddPayment: () => AddPaymentSheet.show(
                          context,
                          line: line,
                          onAdd: (amount) => cubit.addPayment(line.id, amount),
                        ),
                        onAddService: () => AdditionalServiceSheet.show(
                          context,
                          line: line,
                          company: companyFor(line.companyId),
                          onSave: (gb, deduct, charge) => cubit.addAdditionalService(
                            lineId: line.id,
                            amountDeducted: deduct,
                            amountCharged: charge,
                            gbAdded: gb,
                          ),
                        ),
                        onMarkServiceCollected: (serviceId) => cubit.markAdditionalServiceCollected(serviceId),
                        onUndoServiceCollected: (serviceId) => cubit.markAdditionalServiceUncollected(serviceId),
                        onEditService: (service) => AdditionalServiceSheet.show(
                          context,
                          line: line,
                          company: companyFor(line.companyId),
                          existing: service,
                          onSave: (gb, deduct, charge) => cubit.updateAdditionalService(
                            serviceId: service.id,
                            amountDeducted: deduct,
                            amountCharged: charge,
                            gbAdded: gb,
                          ),
                        ),
                        additionalServices: state.additionalServicesFor(line.id),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DetailHeader extends StatelessWidget {
  final Customer customer;
  final CustomersCubit cubit;

  const _DetailHeader({required this.customer, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
              Text(customer.name, style: AppTextStyles.pageTitle(colors.textPrimary)),
              Text(customer.contactNumber, style: AppTextStyles.body(colors.textSecondary)),
            ],
          ),
        ),
        _IconButton(
          icon: Icons.chat_rounded,
          color: colors.success,
          onTap: () => ContactLauncher.openWhatsApp(customer.contactNumber),
        ),
        const SizedBox(width: AppSpacing.xs),
        _IconButton(
          icon: Icons.sms_outlined,
          onTap: () => ContactLauncher.openSms(customer.contactNumber),
        ),
        const SizedBox(width: AppSpacing.xs),
        if (customer.deleted) ...[
          _IconButton(
            icon: Icons.restore_rounded,
            onTap: () {
              cubit.restoreCustomer(customer.id);
              Navigator.of(context).maybePop();
            },
          ),
          const SizedBox(width: AppSpacing.xs),
          _IconButton(
            icon: Icons.delete_forever_rounded,
            color: colors.danger,
            onTap: () => _confirmDeleteForever(context),
          ),
        ] else ...[
          _IconButton(
            icon: Icons.edit_outlined,
            onTap: () => CustomerFormSheet.show(
              context,
              customer: customer,
              onSave: (name, contact, tags, status, pinned, notes) => cubit.updateCustomer(
                customer.id,
                name: name,
                contactNumber: contact,
                tags: tags,
                status: status,
                pinned: pinned,
                notes: notes,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          _IconButton(
            icon: Icons.delete_outline_rounded,
            color: colors.danger,
            onTap: () => _confirmSoftDelete(context),
          ),
        ],
      ],
    );
  }

  void _confirmSoftDelete(BuildContext context) {
    showConfirmDialog(
      context,
      title: 'customers.deleteDialog.title'.tr(namedArgs: {'name': customer.name}),
      message: 'customers.deleteDialog.message'.tr(),
      confirmLabel: 'customers.deleteDialog.confirm'.tr(),
      onConfirm: () {
        cubit.softDeleteCustomer(customer.id);
        Navigator.of(context).maybePop();
      },
    );
  }

  void _confirmDeleteForever(BuildContext context) {
    showConfirmDialog(
      context,
      title: 'customers.deletePermanentDialog.title'.tr(namedArgs: {'name': customer.name}),
      message: 'customers.deletePermanentDialog.message'.tr(),
      confirmLabel: 'customers.deletePermanentDialog.confirm'.tr(),
      onConfirm: () {
        cubit.permanentlyDeleteCustomer(customer.id);
        Navigator.of(context).maybePop();
      },
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  const _IconButton({required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: colors.border)),
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: color ?? colors.textPrimary),
      ),
    );
  }
}

class _CustomerSummaryCard extends StatelessWidget {
  final Customer customer;

  const _CustomerSummaryCard({required this.customer});

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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: colors.background, shape: BoxShape.circle, border: Border.all(color: colors.border)),
                alignment: Alignment.center,
                child: Text(_initialsFor(customer.name), style: AppTextStyles.cardTitle(colors.textPrimary)),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(child: Text(customer.name, style: AppTextStyles.cardTitle(colors.textPrimary))),
                        const SizedBox(width: AppSpacing.xs),
                        _statusBadge(customer.status),
                      ],
                    ),
                    Text(customer.contactNumber, style: AppTextStyles.body(colors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          if (customer.tags.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: customer.tags
                  .map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                        decoration: BoxDecoration(
                          color: colors.background,
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                          border: Border.all(color: colors.border),
                        ),
                        child: Text(tag, style: AppTextStyles.badge(colors.textSecondary)),
                      ))
                  .toList(),
            ),
          ],
          if (customer.notes.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(height: 1, color: colors.border),
            const SizedBox(height: AppSpacing.sm),
            Text(customer.notes, style: AppTextStyles.body(colors.textSecondary)),
          ],
        ],
      ),
    );
  }

  Widget _statusBadge(CustomerStatus status) {
    switch (status) {
      case CustomerStatus.normal:
        return StatusBadge(label: status.label, type: StatusBadgeType.success);
      case CustomerStatus.troubled:
        return StatusBadge(label: status.label, type: StatusBadgeType.warning);
      case CustomerStatus.blocked:
        return StatusBadge(label: status.label, type: StatusBadgeType.danger);
    }
  }

  String _initialsFor(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return (words.first.substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryStat({required this.label, required this.value, this.valueColor});

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
          Text(label.toUpperCase(), style: AppTextStyles.body(colors.textSecondary).copyWith(fontSize: 10)),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.cardTitle(valueColor ?? colors.textPrimary)),
        ],
      ),
    );
  }
}

/// "Remind me in N days" for a customer who still owes money —
/// schedules a local notification via `NotificationsCubit`, auto-
/// cancelled the moment their balance is settled (see
/// `CustomersCubit.addPayment`). Only shown when `totalOwed > 0`.
class _DebtReminderRow extends StatefulWidget {
  final String customerId;
  final String customerName;
  final double amountOwed;

  const _DebtReminderRow({required this.customerId, required this.customerName, required this.amountOwed});

  @override
  State<_DebtReminderRow> createState() => _DebtReminderRowState();
}

class _DebtReminderRowState extends State<_DebtReminderRow> {
  static const _minDays = 1;
  static const _maxDays = 30;

  int _days = 3;

  void _changeDays(int delta) {
    setState(() => _days = (_days + delta).clamp(_minDays, _maxDays));
  }

  void _schedule() {
    getIt<NotificationsCubit>().scheduleDebtReminder(
      customerId: widget.customerId,
      customerName: widget.customerName,
      amountOwed: widget.amountOwed,
      days: _days,
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('notifications.customerDebtReminder.sent'.tr())));
  }

  void _cancel() {
    getIt<NotificationsCubit>().cancelDebtReminder(widget.customerId);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('notifications.customerDebtReminder.cancelled'.tr())));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // Reads the real persisted reminder (if any) straight from
    // NotificationsCubit instead of tracking a local "did I just tap
    // schedule" flag — a plain widget-state flag resets to false the
    // instant this page is rebuilt (e.g. navigating away and back),
    // which used to make an actually-still-scheduled reminder look
    // unscheduled again with no way to tell the two apart.
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      bloc: getIt<NotificationsCubit>(),
      builder: (context, _) {
        final pending = getIt<NotificationsCubit>().pendingDebtReminder(widget.customerId);

        return Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: colors.warning.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(color: colors.warning.withValues(alpha: 0.12), shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Icon(Icons.notifications_active_outlined, size: 16, color: colors.warning),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text('notifications.customerDebtReminder.buttonLabel'.tr(), style: AppTextStyles.cardTitle(colors.textPrimary)),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (pending != null) ...[
                Text(
                  'notifications.customerDebtReminder.scheduledFor'.tr(namedArgs: {'date': _formatDate(pending.fireAt)}),
                  style: AppTextStyles.body(colors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 40,
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _cancel,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colors.danger),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button)),
                    ),
                    child: Text('notifications.customerDebtReminder.cancelButton'.tr(), style: AppTextStyles.body(colors.danger)),
                  ),
                ),
              ] else
                Row(
                  children: [
                    // A compact +/- stepper instead of a 30-item dropdown
                    // menu (which used to pop open tall enough to cover
                    // most of the screen) — same 1-30 range, far less
                    // visual weight.
                    Container(
                      decoration:
                          BoxDecoration(borderRadius: BorderRadius.circular(AppRadii.button), border: Border.all(color: colors.border)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _StepperButton(icon: Icons.remove_rounded, onTap: _days > _minDays ? () => _changeDays(-1) : null),
                          SizedBox(
                            width: 64,
                            child: Text(
                              '$_days ${'notifications.customerDebtReminder.daysUnit'.tr()}',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.cardTitle(colors.textPrimary),
                            ),
                          ),
                          _StepperButton(icon: Icons.add_rounded, onTap: _days < _maxDays ? () => _changeDays(1) : null),
                        ],
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: _schedule,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primaryAction,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button)),
                          elevation: 0,
                        ),
                        child: Text(
                          'notifications.customerDebtReminder.setButton'.tr(),
                          style: AppTextStyles.body(colors.onPrimaryAction),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)}/${local.year} ${two(local.hour)}:${two(local.minute)}';
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Icon(icon, size: 16, color: enabled ? colors.textPrimary : colors.border),
      ),
    );
  }
}

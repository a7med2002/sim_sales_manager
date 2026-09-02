import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/catalog/customer_summary.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/status_badge.dart';
import '../cubit/new_sale_cubit.dart';
import '../cubit/new_sale_state.dart';

/// Step 1: search/select an existing customer, or add a new one inline.
class CustomerStep extends StatelessWidget {
  final NewSaleState state;

  const CustomerStep({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cubit = context.read<NewSaleCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: cubit.customerSearchChanged,
          style: AppTextStyles.cardTitle(colors.textPrimary),
          decoration: InputDecoration(
            hintText: 'newSale.customerStep.searchHint'.tr(),
            hintStyle: AppTextStyles.cardTitle(colors.textSecondary),
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
        GestureDetector(
          onTap: cubit.toggleNewCustomerForm,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.button),
              border: Border.all(color: colors.border, style: BorderStyle.solid),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  state.showNewCustomerForm ? Icons.close_rounded : Icons.person_add_alt_1_outlined,
                  color: colors.textPrimary,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  state.showNewCustomerForm ? 'newSale.customerStep.cancelNewCustomer'.tr() : 'newSale.customerStep.newCustomer'.tr(),
                  style: AppTextStyles.cardTitle(colors.textPrimary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (state.showNewCustomerForm) ...[
          Text('newSale.customerStep.nameLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            onChanged: cubit.newCustomerNameChanged,
            style: AppTextStyles.cardTitle(colors.textPrimary),
            decoration: _decoration(colors),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('newSale.customerStep.contactLabel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            onChanged: cubit.newCustomerContactChanged,
            keyboardType: TextInputType.phone,
            style: AppTextStyles.cardTitle(colors.textPrimary),
            decoration: _decoration(colors, hint: '0599123456'),
          ),
        ] else if (state.filteredCustomers.isEmpty)
          EmptyState(
            icon: Icons.people_outline_rounded,
            title: 'newSale.customerStep.emptyTitle'.tr(),
            description: 'newSale.customerStep.emptyDescription'.tr(),
          )
        else
          ...state.filteredCustomers.map((c) => _CustomerRow(
                customer: c,
                isSelected: c.id == state.selectedCustomerId,
                onTap: () => cubit.selectCustomer(c.id),
              )),
      ],
    );
  }

  InputDecoration _decoration(AppColors colors, {String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.cardTitle(colors.textSecondary),
      filled: true,
      fillColor: colors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.button), borderSide: BorderSide(color: colors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.button), borderSide: BorderSide(color: colors.border)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.button),
        borderSide: BorderSide(color: colors.primaryAction, width: 1.5),
      ),
    );
  }
}

class _CustomerRow extends StatelessWidget {
  final CustomerSummary customer;
  final bool isSelected;
  final VoidCallback onTap;

  const _CustomerRow({required this.customer, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: isSelected ? colors.primaryAction : colors.border, width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: colors.background, shape: BoxShape.circle, border: Border.all(color: colors.border)),
              alignment: Alignment.center,
              child: Text(_initialsFor(customer.name), style: AppTextStyles.cardTitle(colors.textPrimary)),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(customer.name, style: AppTextStyles.cardTitle(colors.textPrimary)),
                  Text(customer.contactNumber, style: AppTextStyles.body(colors.textSecondary)),
                ],
              ),
            ),
            if (customer.status != CustomerStatusSummary.normal)
              StatusBadge(
                label: customer.status.label,
                type: customer.status == CustomerStatusSummary.blocked ? StatusBadgeType.danger : StatusBadgeType.warning,
              ),
          ],
        ),
      ),
    );
  }

  String _initialsFor(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return (words.first.substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
  }
}

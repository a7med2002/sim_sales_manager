import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/catalog/company_catalog.dart';
import '../../../../core/catalog/customer_catalog.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/new_sale_cubit.dart';
import '../cubit/new_sale_state.dart';
import '../widgets/confirm_step.dart';
import '../widgets/customer_step.dart';
import '../widgets/package_price_step.dart';
import '../widgets/payment_step.dart';
import '../widgets/step_progress_header.dart';

/// The multi-step "New Sale" modal (Customer -> Package & Price ->
/// Payment -> Confirm) reachable from the bottom nav's "+" button from
/// anywhere in the app. See design/screenshots/new sale - *.png.
class NewSaleSheet extends StatelessWidget {
  final void Function(String summary) onSaved;

  const NewSaleSheet._({required this.onSaved});

  static Future<void> show(BuildContext context) {
    final rootContext = context;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => NewSaleCubit(
          companyCatalog: getIt<CompanyCatalog>(),
          customerCatalog: getIt<CustomerCatalog>(),
        ),
        child: NewSaleSheet._(
          onSaved: (summary) {
            if (rootContext.mounted) {
              _showSaleSavedBanner(rootContext, summary);
            }
          },
        ),
      ),
    );
  }

  static void _showSaleSavedBanner(BuildContext context, String summary) {
    final colors = context.colors;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: colors.surface,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.card), side: BorderSide(color: colors.border)),
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(color: colors.success, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('newSale.saleSaved'.tr(), style: AppTextStyles.cardTitle(colors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(summary, style: AppTextStyles.body(colors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocConsumer<NewSaleCubit, NewSaleState>(
      listener: (context, state) {
        if (state.saved) {
          Navigator.of(context).pop();
          onSaved(state.savedSummary ?? '');
        }
      },
      builder: (context, state) {
        final cubit = context.read<NewSaleCubit>();

        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.card)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
                  child: StepProgressHeader(
                    stepNumber: state.step.index + 1,
                    stepLabel: _labelFor(state.step),
                    showBack: state.step != NewSaleStep.customer,
                    onBack: cubit.goBack,
                    onClose: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: _stepContent(state),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _canProceed(state) ? (state.step == NewSaleStep.confirm ? cubit.confirmAndSave : cubit.goNext) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primaryAction,
                        foregroundColor: colors.onPrimaryAction,
                        disabledBackgroundColor: colors.primaryAction.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button)),
                        elevation: 0,
                      ),
                      child: Text(
                        state.step == NewSaleStep.confirm ? 'newSale.confirmAndSave'.tr() : 'newSale.next'.tr(),
                        style: AppTextStyles.cardTitle(colors.onPrimaryAction),
                      ),
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

  Widget _stepContent(NewSaleState state) {
    switch (state.step) {
      case NewSaleStep.customer:
        return CustomerStep(state: state);
      case NewSaleStep.packageAndPrice:
        return PackagePriceStep(state: state);
      case NewSaleStep.payment:
        return PaymentStep(state: state);
      case NewSaleStep.confirm:
        return ConfirmStep(state: state);
    }
  }

  bool _canProceed(NewSaleState state) {
    switch (state.step) {
      case NewSaleStep.customer:
        return state.canGoNextFromCustomerStep;
      case NewSaleStep.packageAndPrice:
        return state.canGoNextFromPackageStep;
      case NewSaleStep.payment:
        return true;
      case NewSaleStep.confirm:
        return true;
    }
  }

  String _labelFor(NewSaleStep step) {
    switch (step) {
      case NewSaleStep.customer:
        return 'newSale.stepLabels.customer'.tr();
      case NewSaleStep.packageAndPrice:
        return 'newSale.stepLabels.packageAndPrice'.tr();
      case NewSaleStep.payment:
        return 'newSale.stepLabels.payment'.tr();
      case NewSaleStep.confirm:
        return 'newSale.stepLabels.confirm'.tr();
    }
  }
}

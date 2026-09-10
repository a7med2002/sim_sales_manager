import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/number_update_entry.dart';
import '../cubit/number_update_cubit.dart';
import '../cubit/number_update_state.dart';
import '../widgets/form_webview_updater.dart';

/// Number Update: matches design/screenshots/numbers update.png (translated
/// to English + this app's own visual style, per the reference's design and
/// logic — not its exact look). Real automated multi-supplier lookup —
/// see `NumberUpdateCubit`'s doc comment.
class NumberUpdatePage extends StatelessWidget {
  const NumberUpdatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NumberUpdateCubit(
        runSmileSimFlow: (phoneNumber) => FormWebViewUpdater.run(context, phoneNumber, url: 'https://rn.smilesim.net/'),
        runSkyFlow: (phoneNumber) => FormWebViewUpdater.run(context, phoneNumber, url: 'https://www.refreshsims.net/'),
      ),
      child: const _NumberUpdateView(),
    );
  }
}

class _NumberUpdateView extends StatefulWidget {
  const _NumberUpdateView();

  @override
  State<_NumberUpdateView> createState() => _NumberUpdateViewState();
}

class _NumberUpdateViewState extends State<_NumberUpdateView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: BlocBuilder<NumberUpdateCubit, NumberUpdateState>(
          builder: (context, state) {
            final cubit = context.read<NumberUpdateCubit>();
            final entries = state.entriesForCurrentNumber;

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal).copyWith(
                top: AppSpacing.md,
                bottom: AppSpacing.xl,
              ),
              children: [
                AppTopBar(
                  title: 'numberUpdate.title'.tr(),
                  subtitle: 'numberUpdate.subtitle'.tr(),
                  showBack: true,
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AppRadii.card),
                    border: Border.all(color: colors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('numberUpdate.enterNumberLabel'.tr(), style: AppTextStyles.cardTitle(colors.textPrimary)),
                      const SizedBox(height: AppSpacing.xs),
                      TextField(
                        controller: _controller,
                        keyboardType: TextInputType.phone,
                        style: AppTextStyles.cardTitle(colors.textPrimary),
                        onChanged: cubit.phoneNumberChanged,
                        decoration: InputDecoration(
                          hintText: 'numberUpdate.numberHint'.tr(),
                          hintStyle: AppTextStyles.cardTitle(colors.textSecondary),
                          filled: true,
                          fillColor: colors.background,
                          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.button), borderSide: BorderSide(color: colors.border)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.button), borderSide: BorderSide(color: colors.border)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadii.button),
                            borderSide: BorderSide(color: colors.primaryAction, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: state.phoneNumber.trim().isEmpty || state.isSubmitting ? null : cubit.submitUpdate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primaryAction,
                            foregroundColor: colors.onPrimaryAction,
                            disabledBackgroundColor: colors.primaryAction.withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button)),
                            elevation: 0,
                          ),
                          child: state.isSubmitting
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: colors.onPrimaryAction),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.refresh_rounded, color: colors.onPrimaryAction, size: 18),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text('numberUpdate.updateButton'.tr(), style: AppTextStyles.cardTitle(colors.onPrimaryAction)),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AppRadii.card),
                    border: Border.all(color: colors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('numberUpdate.recentUpdatesTitle'.tr(), style: AppTextStyles.cardTitle(colors.textPrimary)),
                      const SizedBox(height: AppSpacing.sm),
                      if (entries.isEmpty)
                        EmptyState(
                          icon: Icons.history_rounded,
                          title: 'numberUpdate.empty.title'.tr(),
                          description: 'numberUpdate.empty.description'.tr(),
                        )
                      else
                        Column(
                          children: [
                            for (final entry in entries) ...[
                              _UpdateHistoryRow(entry: entry),
                              if (entry != entries.last) Container(height: 1, color: colors.border),
                            ],
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  decoration: BoxDecoration(
                    color: colors.danger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadii.card),
                    border: Border.all(color: colors.danger.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: colors.danger, size: 18),
                          const SizedBox(width: AppSpacing.xs),
                          Text('numberUpdate.importantNotes'.tr(), style: AppTextStyles.cardTitle(colors.danger)),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _NoteBullet(
                        text: 'numberUpdate.notes.activationDelay'.tr(),
                        colors: colors,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _NoteBullet(
                        text: 'numberUpdate.notes.notFoundContactSupport'.tr(),
                        colors: colors,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NoteBullet extends StatelessWidget {
  final String text;
  final AppColors colors;

  const _NoteBullet({required this.text, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Container(width: 4, height: 4, decoration: BoxDecoration(color: colors.danger, shape: BoxShape.circle)),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(child: Text(text, style: AppTextStyles.body(colors.danger))),
      ],
    );
  }
}

class _UpdateHistoryRow extends StatelessWidget {
  final NumberUpdateEntry entry;

  const _UpdateHistoryRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final badgeType = switch (entry.status) {
      NumberUpdateStatus.success => StatusBadgeType.success,
      NumberUpdateStatus.notFound => StatusBadgeType.danger,
      NumberUpdateStatus.failed => StatusBadgeType.warning,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formatDateTime(entry.timestamp), style: AppTextStyles.body(colors.textSecondary)),
                const SizedBox(height: 2),
                Text(entry.message, style: AppTextStyles.body(colors.textPrimary)),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          StatusBadge(label: entry.status.label, type: badgeType),
        ],
      ),
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/support/support_request_type.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/admin_support_request.dart';
import '../cubit/admin_support_feedback_cubit.dart';
import '../widgets/admin_support_request_detail_sheet.dart';

/// Admin → Support & Feedback: every seller's submitted request, newest
/// first — tap one to see the full message, who sent it, and reply by
/// email or open an attachment (`AdminSupportRequestDetailSheet`).
class AdminSupportFeedbackPage extends StatelessWidget {
  const AdminSupportFeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminSupportFeedbackCubit(),
      child: const _AdminSupportFeedbackView(),
    );
  }
}

class _AdminSupportFeedbackView extends StatelessWidget {
  const _AdminSupportFeedbackView();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: BlocBuilder<AdminSupportFeedbackCubit, AdminSupportFeedbackState>(
          builder: (context, state) {
            final cubit = context.read<AdminSupportFeedbackCubit>();

            return RefreshIndicator(
              onRefresh: cubit.load,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal).copyWith(
                  top: AppSpacing.md,
                  bottom: AppSpacing.xl,
                ),
                children: [
                  AppTopBar(
                    title: 'admin.supportFeedback.title'.tr(),
                    subtitle: 'admin.supportFeedback.subtitle'.tr(namedArgs: {'count': '${state.requests.length}'}),
                    showBack: true,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (state.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Text(state.errorMessage!.tr(), style: AppTextStyles.body(colors.danger)),
                    ),
                  if (state.isLoading && state.requests.isEmpty)
                    const Padding(padding: EdgeInsets.symmetric(vertical: AppSpacing.xl), child: Center(child: CircularProgressIndicator()))
                  else if (state.requests.isEmpty)
                    EmptyState(
                      icon: Icons.headset_mic_outlined,
                      title: 'admin.supportFeedback.emptyTitle'.tr(),
                      description: 'admin.supportFeedback.emptyDescription'.tr(),
                    )
                  else
                    ...state.requests.map(
                      (request) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
                        child: _RequestCard(
                          request: request,
                          onTap: () => AdminSupportRequestDetailSheet.show(context, request: request, cubit: cubit),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final AdminSupportRequest request;
  final VoidCallback onTap;

  const _RequestCard({required this.request, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Container(
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
                Expanded(
                  child: Text(
                    request.senderName.isEmpty ? request.senderEmail : request.senderName,
                    style: AppTextStyles.cardTitle(colors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                _typeBadge(request.type),
              ],
            ),
            const SizedBox(height: 4),
            Text(request.message, style: AppTextStyles.body(colors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Text(formatDateTime(request.createdAt), style: AppTextStyles.body(colors.textSecondary)),
                if (request.attachmentUrl != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Icon(Icons.image_outlined, size: 16, color: colors.textSecondary),
                ],
                if (request.voiceNoteUrl != null) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.graphic_eq_rounded, size: 16, color: colors.textSecondary),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeBadge(SupportRequestType type) {
    switch (type) {
      case SupportRequestType.adminSurvey:
      case SupportRequestType.suggestion:
        return StatusBadge(label: type.label, type: StatusBadgeType.neutral);
      case SupportRequestType.problem:
        return StatusBadge(label: type.label, type: StatusBadgeType.danger);
    }
  }
}

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/list_row.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/support_request.dart';
import '../cubit/support_feedback_cubit.dart';
import '../cubit/support_feedback_state.dart';

/// Support & Feedback: submit a suggestion, a problem/bug report, or fill
/// out an admin survey — with an optional photo or short voice note.
/// Matches APP_CONTEXT.md's "5. More → Support & Feedback" spec (no
/// reference screenshot exists for this page).
class SupportFeedbackPage extends StatelessWidget {
  const SupportFeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SupportFeedbackCubit(),
      child: const _SupportFeedbackView(),
    );
  }
}

class _SupportFeedbackView extends StatefulWidget {
  const _SupportFeedbackView();

  @override
  State<_SupportFeedbackView> createState() => _SupportFeedbackViewState();
}

class _SupportFeedbackViewState extends State<_SupportFeedbackView> {
  late final TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _showAttachPhotoSheet(BuildContext context) {
    final colors = context.colors;
    final cubit = context.read<SupportFeedbackCubit>();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.card)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.sm),
              ListRow(
                icon: Icons.camera_alt_outlined,
                title: 'supportFeedback.takePhoto'.tr(),
                showChevron: false,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  cubit.attachPhoto(ImageSource.camera);
                },
              ),
              ListRow(
                icon: Icons.photo_library_outlined,
                title: 'supportFeedback.chooseFromGallery'.tr(),
                showChevron: false,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  cubit.attachPhoto(ImageSource.gallery);
                },
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: BlocConsumer<SupportFeedbackCubit, SupportFeedbackState>(
          listener: (context, state) {
            if (state.message.isEmpty && _messageController.text.isNotEmpty) {
              _messageController.clear();
            }
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.errorMessage!.tr())));
            }
            if (state.justSubmitted) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text('supportFeedback.submitted'.tr())));
            }
          },
          builder: (context, state) {
            final cubit = context.read<SupportFeedbackCubit>();

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal).copyWith(
                top: AppSpacing.md,
                bottom: AppSpacing.xl,
              ),
              children: [
                Row(
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
                          Text('supportFeedback.title'.tr(), style: AppTextStyles.pageTitle(colors.textPrimary)),
                          const SizedBox(height: 4),
                          Text(
                            'supportFeedback.subtitle'.tr(),
                            style: AppTextStyles.body(colors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: SupportRequestType.values
                      .map((type) => _TypePill(
                            type: type,
                            isActive: state.selectedType == type,
                            onTap: () => cubit.selectType(type),
                          ))
                      .toList(),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _messageController,
                  onChanged: cubit.messageChanged,
                  maxLines: 6,
                  maxLength: supportMessageMaxLength,
                  style: AppTextStyles.body(colors.textPrimary),
                  buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                  decoration: InputDecoration(
                    hintText: _placeholderFor(state.selectedType),
                    hintStyle: AppTextStyles.body(colors.textSecondary),
                    filled: true,
                    fillColor: colors.surface,
                    contentPadding: const EdgeInsets.all(AppSpacing.md),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.card), borderSide: BorderSide(color: colors.border)),
                    enabledBorder:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.card), borderSide: BorderSide(color: colors.border)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.card),
                      borderSide: BorderSide(color: colors.primaryAction, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${state.message.length}/$supportMessageMaxLength',
                    style: AppTextStyles.body(colors.textSecondary),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _showAttachPhotoSheet(context),
                      icon: Icon(Icons.attach_file_rounded, size: 16, color: colors.textPrimary),
                      label: Text('supportFeedback.attachPhoto'.tr(), style: AppTextStyles.body(colors.textPrimary)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.textPrimary,
                        side: BorderSide(color: colors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button)),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: state.isRecording ? cubit.stopRecording : cubit.startRecording,
                      icon: Icon(
                        state.isRecording ? Icons.stop_circle_outlined : Icons.mic_none_rounded,
                        size: 16,
                        color: state.isRecording ? colors.danger : colors.textPrimary,
                      ),
                      label: Text(
                        state.isRecording
                            ? 'supportFeedback.stopRecording'.tr(namedArgs: {'time': _formatSeconds(state.recordingSeconds)})
                            : 'supportFeedback.recordVoiceNote'.tr(),
                        style: AppTextStyles.body(state.isRecording ? colors.danger : colors.textPrimary),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.textPrimary,
                        side: BorderSide(color: state.isRecording ? colors.danger : colors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button)),
                      ),
                    ),
                  ],
                ),
                if (state.photoPath != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _AttachmentPreview(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(File(state.photoPath!), width: 36, height: 36, fit: BoxFit.cover),
                    ),
                    label: 'supportFeedback.photoAttached'.tr(),
                    onRemove: cubit.removePhoto,
                  ),
                ],
                if (state.voiceNotePath != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _AttachmentPreview(
                    leading: Icon(Icons.graphic_eq_rounded, color: colors.textPrimary),
                    label: 'supportFeedback.voiceNoteAttached'.tr(namedArgs: {'time': _formatSeconds(state.voiceNoteSeconds ?? 0)}),
                    onRemove: cubit.removeVoiceNote,
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: state.canSubmit ? cubit.submit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primaryAction,
                      foregroundColor: colors.onPrimaryAction,
                      disabledBackgroundColor: colors.primaryAction.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button)),
                      elevation: 0,
                    ),
                    child: Text('supportFeedback.submit'.tr(), style: AppTextStyles.cardTitle(colors.onPrimaryAction)),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Center(
                  child: Text(
                    'supportFeedback.requestsLeftToday'.tr(namedArgs: {
                      'count': '${state.remainingToday}',
                      'limit': '$supportDailyRequestLimit',
                    }),
                    style: AppTextStyles.body(colors.textSecondary),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('supportFeedback.previousRequestsSection'.tr(), style: AppTextStyles.overline(colors.textSecondary)),
                const SizedBox(height: AppSpacing.sm),
                if (state.previousRequests.isEmpty)
                  EmptyState(
                    icon: Icons.headset_mic_outlined,
                    title: 'supportFeedback.empty.title'.tr(),
                    description: 'supportFeedback.empty.description'.tr(),
                  )
                else
                  ...state.previousRequests.map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
                      child: _PreviousRequestCard(request: r),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _placeholderFor(SupportRequestType type) {
    switch (type) {
      case SupportRequestType.adminSurvey:
        return 'supportFeedback.placeholders.adminSurvey'.tr();
      case SupportRequestType.suggestion:
        return 'supportFeedback.placeholders.suggestion'.tr();
      case SupportRequestType.problem:
        return 'supportFeedback.placeholders.problem'.tr();
    }
  }

  String _formatSeconds(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _TypePill extends StatelessWidget {
  final SupportRequestType type;
  final bool isActive;
  final VoidCallback onTap;

  const _TypePill({required this.type, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isProblem = type == SupportRequestType.problem;

    // Problem always keeps a red outline to "stand out, matches urgency"
    // per APP_CONTEXT.md, active or not. The other two pills behave like
    // a normal FilterPill.
    final borderColor = isProblem ? colors.danger : (isActive ? colors.primaryAction : colors.border);
    final backgroundColor = isActive ? (isProblem ? colors.danger : colors.primaryAction) : Colors.transparent;
    final Color textColor;
    if (isActive) {
      textColor = isProblem ? Colors.white : colors.onPrimaryAction;
    } else {
      textColor = isProblem ? colors.danger : colors.textPrimary;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: borderColor),
        ),
        child: Text(type.label, style: AppTextStyles.body(textColor).copyWith(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _AttachmentPreview extends StatelessWidget {
  final Widget leading;
  final String label;
  final VoidCallback onRemove;

  const _AttachmentPreview({required this.leading, required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.button),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(label, style: AppTextStyles.body(colors.textPrimary))),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded, size: 18, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _PreviousRequestCard extends StatelessWidget {
  final SupportRequest request;

  const _PreviousRequestCard({required this.request});

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _badgeFor(request.type),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  formatDateTime(request.createdAt),
                  style: AppTextStyles.body(colors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(request.message, style: AppTextStyles.body(colors.textPrimary)),
          if (request.photoPath != null || request.voiceNotePath != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                if (request.photoPath != null) Icon(Icons.image_outlined, size: 16, color: colors.textSecondary),
                if (request.photoPath != null && request.voiceNotePath != null) const SizedBox(width: AppSpacing.xs),
                if (request.voiceNotePath != null) Icon(Icons.graphic_eq_rounded, size: 16, color: colors.textSecondary),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _badgeFor(SupportRequestType type) {
    switch (type) {
      case SupportRequestType.adminSurvey:
        return StatusBadge(label: type.label, type: StatusBadgeType.neutral);
      case SupportRequestType.suggestion:
        return StatusBadge(label: type.label, type: StatusBadgeType.success);
      case SupportRequestType.problem:
        return StatusBadge(label: type.label, type: StatusBadgeType.danger);
    }
  }
}

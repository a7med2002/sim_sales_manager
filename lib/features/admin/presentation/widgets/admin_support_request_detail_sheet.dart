import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/support/support_request_type.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/admin_support_request.dart';
import '../cubit/admin_support_feedback_cubit.dart';

/// Full view of one support request: who sent it, the message, and the
/// two attachments a seller might have included — shown **inline**, the
/// same way the seller's own compose screen previews them (an image
/// widget for the photo, a real play/pause/progress player for the
/// voice note), not handed off to some external app via a raw link.
/// Both are private Storage objects, so each is fetched as a short-lived
/// signed URL up front (`AdminSupportFeedbackCubit.signedAttachmentUrl`)
/// the moment this sheet opens, rather than on tap.
class AdminSupportRequestDetailSheet extends StatefulWidget {
  final AdminSupportRequest request;
  final AdminSupportFeedbackCubit cubit;

  const AdminSupportRequestDetailSheet({super.key, required this.request, required this.cubit});

  static Future<void> show(BuildContext context, {required AdminSupportRequest request, required AdminSupportFeedbackCubit cubit}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AdminSupportRequestDetailSheet(request: request, cubit: cubit),
    );
  }

  @override
  State<AdminSupportRequestDetailSheet> createState() => _AdminSupportRequestDetailSheetState();
}

class _AdminSupportRequestDetailSheetState extends State<AdminSupportRequestDetailSheet> {
  final AudioPlayer _player = AudioPlayer();

  bool _loadingPhoto = false;
  bool _loadingVoice = false;
  String? _photoUrl;
  String? _voiceUrl;
  bool _photoError = false;
  bool _voiceError = false;

  bool _isPlayingVoice = false;
  Duration _voicePosition = Duration.zero;
  Duration _voiceDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadAttachments();
    _player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _isPlayingVoice = false;
        _voicePosition = Duration.zero;
      });
    });
    _player.onPositionChanged.listen((position) {
      if (!mounted) return;
      setState(() => _voicePosition = position);
    });
    _player.onDurationChanged.listen((duration) {
      if (!mounted) return;
      setState(() => _voiceDuration = duration);
    });
  }

  Future<void> _loadAttachments() async {
    final request = widget.request;
    if (request.attachmentUrl != null) {
      setState(() => _loadingPhoto = true);
      final url = await widget.cubit.signedAttachmentUrl(request.attachmentUrl!);
      if (!mounted) return;
      setState(() {
        _loadingPhoto = false;
        _photoUrl = url;
        _photoError = url == null;
      });
    }
    if (request.voiceNoteUrl != null) {
      setState(() => _loadingVoice = true);
      final url = await widget.cubit.signedAttachmentUrl(request.voiceNoteUrl!);
      if (!mounted) return;
      setState(() {
        _loadingVoice = false;
        _voiceUrl = url;
        _voiceError = url == null;
      });
    }
  }

  Future<void> _toggleVoicePlayback() async {
    final url = _voiceUrl;
    if (url == null) return;
    if (_isPlayingVoice) {
      await _player.pause();
      setState(() => _isPlayingVoice = false);
    } else {
      await _player.play(UrlSource(url));
      setState(() => _isPlayingVoice = true);
    }
  }

  Future<void> _replyByEmail() async {
    final request = widget.request;
    final uri = Uri(
      scheme: 'mailto',
      path: request.senderEmail,
      query: 'subject=${Uri.encodeComponent('admin.supportFeedback.replySubject'.tr())}',
    );
    await launchUrl(uri);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final request = widget.request;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        decoration: BoxDecoration(color: colors.background, borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.card))),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(request.type.label, style: AppTextStyles.sectionHeader(colors.textPrimary)),
                  GestureDetector(onTap: () => Navigator.of(context).pop(), child: Icon(Icons.close_rounded, color: colors.textSecondary)),
                ],
              ),
              const SizedBox(height: 4),
              Text(formatDateTime(request.createdAt), style: AppTextStyles.body(colors.textSecondary)),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.card),
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: colors.background, shape: BoxShape.circle, border: Border.all(color: colors.border)),
                      alignment: Alignment.center,
                      child: Text(_initialsFor(request.senderName.isEmpty ? request.senderEmail : request.senderName), style: AppTextStyles.cardTitle(colors.textPrimary)),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.senderName.isEmpty ? request.senderEmail : request.senderName,
                            style: AppTextStyles.cardTitle(colors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(request.senderEmail, style: AppTextStyles.body(colors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('admin.supportFeedback.messageLabel'.tr(), style: AppTextStyles.overline(colors.textSecondary)),
              const SizedBox(height: AppSpacing.xs),
              Text(request.message, style: AppTextStyles.body(colors.textPrimary)),
              if (request.attachmentUrl != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Text('admin.supportFeedback.viewPhoto'.tr(), style: AppTextStyles.overline(colors.textSecondary)),
                const SizedBox(height: AppSpacing.sm),
                _PhotoAttachment(isLoading: _loadingPhoto, url: _photoUrl, hasError: _photoError),
              ],
              if (request.voiceNoteUrl != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Text('admin.supportFeedback.listenVoiceNote'.tr(), style: AppTextStyles.overline(colors.textSecondary)),
                const SizedBox(height: AppSpacing.sm),
                _VoicePlayer(
                  isLoading: _loadingVoice,
                  hasError: _voiceError,
                  isPlaying: _isPlayingVoice,
                  position: _voicePosition,
                  duration: _voiceDuration,
                  onToggle: _toggleVoicePlayback,
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _replyByEmail,
                  icon: Icon(Icons.email_outlined, color: colors.onPrimaryAction, size: 18),
                  label: Text('admin.supportFeedback.replyByEmail'.tr(), style: AppTextStyles.cardTitle(colors.onPrimaryAction)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primaryAction,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
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

class _PhotoAttachment extends StatelessWidget {
  final bool isLoading;
  final String? url;
  final bool hasError;

  const _PhotoAttachment({required this.isLoading, required this.url, required this.hasError});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (isLoading) {
      return Container(
        height: 160,
        decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(AppRadii.card), border: Border.all(color: colors.border)),
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }
    if (hasError || url == null) {
      return _ErrorBox(text: 'admin.supportFeedback.attachmentError'.tr());
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Image.network(
        url!,
        fit: BoxFit.contain,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => _ErrorBox(text: 'admin.supportFeedback.attachmentError'.tr()),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            height: 160,
            decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(AppRadii.card)),
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

class _VoicePlayer extends StatelessWidget {
  final bool isLoading;
  final bool hasError;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final VoidCallback onToggle;

  const _VoicePlayer({
    required this.isLoading,
    required this.hasError,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.onToggle,
  });

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(AppRadii.card), border: Border.all(color: colors.border)),
        child: Row(
          children: [
            SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: colors.textSecondary)),
            const SizedBox(width: AppSpacing.sm),
            Text('admin.supportFeedback.loadingAttachment'.tr(), style: AppTextStyles.body(colors.textSecondary)),
          ],
        ),
      );
    }
    if (hasError) {
      return _ErrorBox(text: 'admin.supportFeedback.attachmentError'.tr());
    }

    final progress = duration.inMilliseconds == 0 ? 0.0 : (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(AppRadii.card), border: Border.all(color: colors.border)),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Icon(
              isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
              size: 36,
              color: colors.primaryAction,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: colors.border,
                    valueColor: AlwaysStoppedAnimation(colors.primaryAction),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatDuration(position)} / ${_formatDuration(duration)}',
                  style: AppTextStyles.body(colors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String text;

  const _ErrorBox({required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(AppRadii.card), border: Border.all(color: colors.border)),
      child: Text(text, style: AppTextStyles.body(colors.danger)),
    );
  }
}

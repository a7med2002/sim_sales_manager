import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'update_cubit.dart';
import 'update_state.dart';

/// Wraps a page to trigger an update check on first build and show a
/// dialog once `UpdateCubit` finds one — dismissible unless the release
/// is `mandatory`. `HomePage` is the only place this is used today (the
/// landing page right after sign-in).
class UpdateGate extends StatefulWidget {
  final Widget child;

  const UpdateGate({super.key, required this.child});

  @override
  State<UpdateGate> createState() => _UpdateGateState();
}

class _UpdateGateState extends State<UpdateGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<UpdateCubit>().check();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UpdateCubit, UpdateState>(
      listenWhen: (previous, current) =>
          current.status == UpdateStatus.available && previous.status != UpdateStatus.available,
      listener: (context, state) {
        showDialog(
          context: context,
          barrierDismissible: !(state.release?.mandatory ?? false),
          builder: (_) => BlocProvider.value(
            value: context.read<UpdateCubit>(),
            child: const _UpdateDialogContent(),
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _UpdateDialogContent extends StatelessWidget {
  const _UpdateDialogContent();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return BlocConsumer<UpdateCubit, UpdateState>(
      // `download()`/`dismiss()` both reset state back to `idle` when
      // there's nothing left for this dialog to show — either handing
      // off to the OS installer, or the user chose "Later".
      listenWhen: (previous, current) => previous.status != UpdateStatus.idle && current.status == UpdateStatus.idle,
      listener: (context, state) => Navigator.of(context, rootNavigator: true).maybePop(),
      builder: (context, state) {
        final release = state.release;
        if (release == null) return const SizedBox.shrink();
        final downloading = state.status == UpdateStatus.downloading;

        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.card)),
          title: Text(
            (release.mandatory ? 'update.mandatoryTitle' : 'update.title').tr(),
            style: AppTextStyles.sectionHeader(colors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'update.versionLabel'.tr(namedArgs: {'version': release.versionName}),
                style: AppTextStyles.body(colors.textSecondary),
              ),
              if (release.releaseNotes != null && release.releaseNotes!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(release.releaseNotes!, style: AppTextStyles.body(colors.textPrimary)),
              ],
              if (state.status == UpdateStatus.error) ...[
                const SizedBox(height: AppSpacing.sm),
                Text('update.errors.downloadFailed'.tr(), style: AppTextStyles.body(colors.danger)),
              ],
              if (downloading) ...[
                const SizedBox(height: AppSpacing.md),
                LinearProgressIndicator(
                  value: state.progress > 0 ? state.progress : null,
                  color: colors.primaryAction,
                  backgroundColor: colors.background,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text('update.downloading'.tr(), style: AppTextStyles.body(colors.textSecondary)),
              ],
            ],
          ),
          actions: [
            if (!release.mandatory && !downloading)
              TextButton(
                onPressed: () => context.read<UpdateCubit>().dismiss(),
                child: Text('update.later'.tr(), style: AppTextStyles.cardTitle(colors.textSecondary)),
              ),
            ElevatedButton(
              onPressed: downloading ? null : () => context.read<UpdateCubit>().download(),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primaryAction,
                foregroundColor: colors.onPrimaryAction,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button)),
                elevation: 0,
              ),
              child: Text('update.updateNow'.tr(), style: AppTextStyles.cardTitle(colors.onPrimaryAction)),
            ),
          ],
        );
      },
    );
  }
}

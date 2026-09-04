import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../config/env.dart';
import '../di/service_locator.dart';
import '../sync/bloc/sync_bloc.dart';
import '../sync/bloc/sync_event.dart';
import '../sync/bloc/sync_state.dart';
import '../theme/app_colors.dart';

/// The "subtle sync-status indicator" CLAUDE.md's offline-first section
/// calls for — a small icon, never a blocking spinner. Self-contained
/// (owns its own `BlocProvider`/`BlocBuilder`) so every `AppTopBar` call
/// site doesn't need to know `SyncBloc` exists; renders nothing when
/// there's no real backend to sync with (`Env.isConfigured` false —
/// offline/demo mode is *expected* to be offline, showing an "offline"
/// badge there would just be noise). Tap to retry a sync manually.
class SyncStatusIndicator extends StatelessWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Env.isConfigured) return const SizedBox.shrink();

    return BlocProvider.value(
      value: getIt<SyncBloc>(),
      child: BlocBuilder<SyncBloc, SyncState>(
        builder: (context, state) {
          final colors = context.colors;
          final (icon, color, tooltipKey) = switch (state.status) {
            SyncStatus.offline => (Icons.cloud_off_outlined, colors.textSecondary, 'sync.status.offline'),
            SyncStatus.syncing => (Icons.cloud_sync_outlined, colors.textSecondary, 'sync.status.syncing'),
            SyncStatus.idle => (Icons.cloud_done_outlined, colors.success, 'sync.status.idle'),
            SyncStatus.error => (Icons.cloud_off_outlined, colors.danger, 'sync.status.error'),
          };

          return Tooltip(
            message: tooltipKey.tr(),
            child: GestureDetector(
              onTap: () => context.read<SyncBloc>().add(const SyncRequested()),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(icon, size: 18, color: color),
              ),
            ),
          );
        },
      ),
    );
  }
}

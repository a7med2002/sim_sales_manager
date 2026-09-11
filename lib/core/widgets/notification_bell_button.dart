import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../di/service_locator.dart';
import '../navigation/route_names.dart';
import '../notifications/notifications_cubit.dart';
import '../notifications/notifications_state.dart';
import '../theme/app_colors.dart';
import 'circular_icon_button.dart';

/// Bell icon + unread-count badge for `AppTopBar`'s `actions` slot —
/// self-contained (owns its own `BlocProvider`/`BlocBuilder`), same
/// pattern as `SyncStatusIndicator`. Shares `CircularIconButton`'s look
/// with every other top-bar icon (sync status, dark/light toggle) so
/// they all read as the same family of controls.
class NotificationBellButton extends StatelessWidget {
  const NotificationBellButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocProvider.value(
      value: getIt<NotificationsCubit>(),
      child: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          final unread = state.unreadCount;
          return CircularIconButton(
            icon: Icons.notifications_none_rounded,
            iconColor: colors.textPrimary,
            onTap: () => Navigator.of(context).pushNamed(RouteNames.notifications),
            badge: unread > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    constraints: const BoxConstraints(minWidth: 16),
                    decoration: BoxDecoration(color: colors.danger, borderRadius: BorderRadius.circular(8)),
                    alignment: Alignment.center,
                    child: Text(
                      unread > 9 ? '9+' : '$unread',
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../di/service_locator.dart';
import '../navigation/route_names.dart';
import '../notifications/notifications_cubit.dart';
import '../notifications/notifications_state.dart';
import '../theme/app_colors.dart';

/// Bell icon + unread-count badge for `AppTopBar`'s `actions` slot —
/// self-contained (owns its own `BlocProvider`/`BlocBuilder`), same
/// pattern as `SyncStatusIndicator`, so call sites don't need to know
/// `NotificationsCubit` exists.
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
          return GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(RouteNames.notifications),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.notifications_none_rounded, size: 22, color: colors.textPrimary),
                  if (unread > 0)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        constraints: const BoxConstraints(minWidth: 16),
                        decoration: BoxDecoration(color: colors.danger, borderRadius: BorderRadius.circular(8)),
                        alignment: Alignment.center,
                        child: Text(
                          unread > 9 ? '9+' : '$unread',
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The shared look for every small icon action that sits in a page's top
/// bar (dark/light mode toggle, sync status, notifications bell, ...) —
/// a 40x40 bordered circle around an 18px icon, with room for a small
/// badge overlay (unread count, pending-sync count, ...) pinned to its
/// top-end corner. Centralized so these icons can never quietly drift
/// out of sync with each other's size/level again.
class CircularIconButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final Widget? badge;
  final String? tooltip;

  const CircularIconButton({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.badge,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final button = GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: colors.border),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Icon(icon, color: iconColor, size: 18),
            if (badge != null)
              PositionedDirectional(top: -2, end: -2, child: badge!),
          ],
        ),
      ),
    );

    return tooltip != null ? Tooltip(message: tooltip!, child: button) : button;
  }
}

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Shows an uploaded logo when one exists, falling back to initials
/// otherwise — the one shared "avatar" look for anything with a name +
/// an optional logo (a seller's own company, an admin catalog entry).
/// Falls back to initials on a network error too (a deleted/unreachable
/// logo shouldn't ever break the layout).
class LogoAvatar extends StatelessWidget {
  final String initials;
  final String? logoUrl;
  final double size;

  const LogoAvatar({super.key, required this.initials, this.logoUrl, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final url = logoUrl;

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: colors.background, shape: BoxShape.circle, border: Border.all(color: colors.border)),
      alignment: Alignment.center,
      child: url == null || url.isEmpty
          ? Text(initials, style: AppTextStyles.cardTitle(colors.textPrimary))
          : Image.network(
              url,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Text(initials, style: AppTextStyles.cardTitle(colors.textPrimary)),
            ),
    );
  }
}

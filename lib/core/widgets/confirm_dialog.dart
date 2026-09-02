import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_text_styles.dart';

/// Generic confirm/cancel dialog for destructive or important actions
/// (delete, permanently delete, logout, ...). Shared across Companies,
/// Customers and More/Settings instead of each page building its own
/// `AlertDialog`. The dialog closes itself before calling [onConfirm].
Future<void> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required VoidCallback onConfirm,
}) {
  final colors = context.colors;

  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.card)),
      title: Text(title, style: AppTextStyles.cardTitle(colors.textPrimary)),
      content: Text(message, style: AppTextStyles.body(colors.textSecondary)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text('common.cancel'.tr(), style: AppTextStyles.body(colors.textSecondary)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            onConfirm();
          },
          child: Text(confirmLabel, style: AppTextStyles.body(colors.danger).copyWith(fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );
}

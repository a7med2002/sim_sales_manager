import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

import '../widgets/confirm_dialog.dart';
import 'route_names.dart';

/// Shared logout confirmation, used by both More's Logout row and
/// Settings' Logout button (APP_CONTEXT.md: they should behave the
/// same). Clears the whole nav stack down to Login.
void confirmLogout(BuildContext context) {
  showConfirmDialog(
    context,
    title: 'logout.title'.tr(),
    message: 'logout.message'.tr(),
    confirmLabel: 'logout.confirm'.tr(),
    onConfirm: () => Navigator.of(context).pushNamedAndRemoveUntil(RouteNames.login, (route) => false),
  );
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

import '../auth/auth_service.dart';
import '../config/env.dart';
import '../di/service_locator.dart';
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
    onConfirm: () async {
      // Must actually clear the Supabase session, not just navigate away
      // — otherwise `main()`'s "already signed in? skip Login" check
      // would just bounce the user right back in on next launch.
      if (Env.isConfigured) {
        await getIt<AuthService>().signOut();
        // Every feature Cubit is a get_it lazy singleton holding this
        // session's data in memory — reset them too, so a different
        // account signing in on the same device afterward (or just a
        // fresh sign-in) doesn't briefly see the previous owner's data
        // before anything happens to reload.
        await getIt.reset();
        setupServiceLocator();
      }
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(RouteNames.login, (route) => false);
      }
    },
  );
}

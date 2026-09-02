import 'package:flutter/widgets.dart';

/// New Sale is reachable from the bottom nav's "+" button on *any* page
/// (Home, Companies, Customers, ...), but those pages must not import the
/// New Sale feature's page file directly (see CLAUDE.md: no cross-feature
/// imports except through core/). `main.dart` registers the actual opener
/// once at startup; pages call [NewSaleLauncher.open] instead.
class NewSaleLauncher {
  NewSaleLauncher._();

  static void Function(BuildContext context)? _open;

  static void register(void Function(BuildContext context) open) {
    _open = open;
  }

  static void open(BuildContext context) {
    _open?.call(context);
  }
}

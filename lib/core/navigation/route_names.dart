/// Named routes used for navigation between features, so feature pages
/// never import each other directly (see CLAUDE.md: no cross-feature
/// imports except through core/).
class RouteNames {
  RouteNames._();

  static const String login = '/login';
  static const String home = '/home';
  static const String companies = '/companies';
  static const String customers = '/customers';
  static const String more = '/more';
  static const String settings = '/settings';
  static const String numbers = '/numbers';
  static const String activityLog = '/activity-log';
  static const String trustedDevices = '/trusted-devices';
  static const String supportFeedback = '/support-feedback';
  static const String profits = '/profits';
  static const String reports = '/reports';
  static const String shipmentsOperations = '/shipments-operations';
  static const String numberUpdate = '/number-update';
}

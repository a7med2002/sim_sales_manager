import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sim_sales_manager/core/catalog/company_summary.dart';
import 'package:sim_sales_manager/core/di/service_locator.dart';
import 'package:sim_sales_manager/core/navigation/new_sale_launcher.dart';
import 'package:sim_sales_manager/features/companies/presentation/pages/companies_page.dart';
import 'package:sim_sales_manager/features/companies/presentation/widgets/company_card.dart';
import 'package:sim_sales_manager/features/customers/presentation/pages/customers_page.dart';
import 'package:sim_sales_manager/features/new_sale/presentation/pages/new_sale_sheet.dart';
import 'package:sim_sales_manager/main.dart';

/// Wraps a bare page (rather than the full `SimSalesManagerApp`) with its
/// own `EasyLocalization`, so tests that pump a single page directly still
/// resolve `.tr()` correctly regardless of what ran before them in this
/// file. Without this, `.tr()` happens to work only because some earlier
/// test already mounted `SimSalesManagerApp` and left translations loaded
/// in easy_localization's global `Localization.instance` — order-dependent
/// and fragile, so every bare-page test uses this instead of a plain
/// `MaterialApp(home: ...)`.
Widget _localizedApp(Widget home) {
  return EasyLocalization(
    supportedLocales: const [Locale('en'), Locale('ar')],
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    startLocale: const Locale('en'),
    child: Builder(
      builder: (context) => MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        home: home,
      ),
    ),
  );
}

void main() {
  // easy_localization needs SharedPreferences (where it caches the chosen
  // locale) primed once before any widget pump — done here instead of in
  // `main()`, which tests never call.
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  // Pages now read Home/Companies/Customers Cubits as app-lifetime
  // singletons via get_it, so each test needs a fresh registration —
  // otherwise state (e.g. a company added in one test) would leak into
  // the next.
  setUp(() async {
    // easy_localization's default RootBundleAssetLoader caches loaded
    // translation strings on `rootBundle`; without clearing it between
    // tests, the second SimSalesManagerApp pumped in this file hangs
    // forever waiting on a stale cached load that never resolves.
    rootBundle.clear();
    await getIt.reset();
    setupServiceLocator();
    NewSaleLauncher.register((context) => NewSaleSheet.show(context));
  });

  testWidgets('Login succeeds and navigates to Home dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const SimSalesManagerApp());
    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsWidgets);

    final textFields = find.byType(TextField);
    await tester.enterText(textFields.at(0), 'owner@simmanager.app');
    await tester.enterText(textFields.at(1), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back, Ahmed'), findsOneWidget);
    expect(find.text('OPERATIONS'), findsOneWidget);

    final pageScrollable = find.ancestor(
      of: find.text('Welcome back, Ahmed'),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.text('YOUR BALANCE WITH SUPPLIER COMPANIES'),
      200,
      scrollable: pageScrollable,
    );
    expect(find.text('YOUR BALANCE WITH SUPPLIER COMPANIES'), findsOneWidget);
  });

  testWidgets('Companies: add, archive, and soft-delete a company', (WidgetTester tester) async {
    // Tall virtual screen so the whole list renders without needing to
    // scroll — ListView only builds items inside its viewport, and
    // scrolling away from the tabs at the top would un-build them.
    tester.view.physicalSize = const Size(400, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_localizedApp(const CompaniesPage()));
    await tester.pumpAndSettle();

    expect(find.text('4 total'), findsOneWidget);
    expect(find.text('Airalo eSIM'), findsOneWidget);

    // Spot-check the Arabic translations actually resolve, then switch
    // back to English before the rest of this test relies on it.
    await tester.element(find.byType(CompaniesPage)).setLocale(const Locale('ar'));
    await tester.pumpAndSettle();
    // "الشركات" matches both the page title and the bottom nav's own
    // Companies label (same word), so this isn't unique — just confirm
    // it's actually rendering.
    expect(find.text('الشركات'), findsWidgets);
    expect(find.text('إضافة شركة'), findsOneWidget);
    await tester.element(find.byType(CompaniesPage)).setLocale(const Locale('en'));
    await tester.pumpAndSettle();

    // Add a new company.
    await tester.tap(find.text('Add Company'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Test Telecom');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('5 total'), findsOneWidget);
    expect(find.text('Test Telecom'), findsOneWidget);

    // Archive it via the card's actions menu.
    await tester.tap(_menuButtonFor(tester, 'Test Telecom'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Archive'));
    await tester.pumpAndSettle();

    expect(find.text('Test Telecom'), findsNothing);
    await tester.tap(find.text('Archived'));
    await tester.pumpAndSettle();
    expect(find.text('Test Telecom'), findsOneWidget);

    // Soft-delete it, then find it under the Deleted tab.
    await tester.tap(_menuButtonFor(tester, 'Test Telecom'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete')); // confirm dialog
    await tester.pumpAndSettle();

    expect(find.text('Test Telecom'), findsNothing);
    await tester.tap(find.text('Deleted'));
    await tester.pumpAndSettle();
    expect(find.text('Test Telecom'), findsOneWidget);
  });

  testWidgets('Customers: open detail, add a line, then soft-delete the customer', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_localizedApp(const CustomersPage()));
    await tester.pumpAndSettle();

    expect(find.text('5 active'), findsOneWidget);
    expect(find.text('Mahmoud Salah'), findsOneWidget);

    // Open the customer's detail page.
    await tester.tap(find.text('Mahmoud Salah'));
    await tester.pumpAndSettle();

    expect(find.text('0599123456'), findsWidgets);
    expect(find.text('₪148.00'), findsWidgets); // total spent
    expect(find.text('₪5.00'), findsWidgets); // owed (also matches a line's own profit/remaining)

    // Spot-check Arabic translations resolve on this detail page too,
    // then switch back before the rest of this test relies on English.
    // Any mounted context works for `setLocale` — grab the nearest
    // Scaffold's rather than CustomersPage's, since the detail page
    // (pushed on top) is what's actually on screen right now.
    await tester.element(find.byType(Scaffold).first).setLocale(const Locale('ar'));
    await tester.pumpAndSettle();
    expect(find.text('إضافة خط'), findsOneWidget);
    expect(find.text('الخطوط / الشرائح'), findsOneWidget);
    await tester.element(find.byType(Scaffold).first).setLocale(const Locale('en'));
    await tester.pumpAndSettle();

    // Add a line.
    await tester.tap(find.text('Add Line'));
    await tester.pumpAndSettle();
    final lineFields = find.byType(TextField);
    await tester.enterText(lineFields.at(0), 'Orange'); // company
    await tester.enterText(lineFields.at(1), 'Test Package'); // package
    await tester.enterText(lineFields.at(2), '0500000000'); // sim number
    await tester.enterText(lineFields.at(4), '50'); // retail price
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Test Package'), findsOneWidget);
    expect(find.text('5'), findsWidgets); // lines count is now 5

    // Soft-delete the customer from the detail header, then confirm it
    // moved to the Deleted tab back on the list.
    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Mahmoud Salah'), findsNothing);
    await tester.tap(find.text('Deleted'));
    await tester.pumpAndSettle();
    expect(find.text('Mahmoud Salah'), findsOneWidget);
  });

  testWidgets('Customers: add payment against a partially-paid line clears it', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_localizedApp(const CustomersPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mahmoud Salah'));
    await tester.pumpAndSettle();

    // Mahmoud's Weekly 1GB / Ooredoo line is partially paid, ₪5 remaining.
    expect(find.text('Add Payment'), findsOneWidget);
    expect(find.text('Partial'), findsOneWidget);

    await tester.tap(find.text('Add Payment'));
    await tester.pumpAndSettle();

    // The sheet prefills the full remaining amount.
    expect(find.text('Currently owed'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add Payment'));
    await tester.pumpAndSettle();

    // The line is now fully paid: no more "Add Payment" button on it, and
    // the customer's overall owed total dropped from ₪5 to ₪0.
    expect(find.text('Paid'), findsWidgets);
    expect(find.text('Add Payment'), findsNothing);
    expect(find.text('₪0.00'), findsWidgets);
  });

  testWidgets('Customers: Debtors tab isolates customers who still owe money', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_localizedApp(const CustomersPage()));
    await tester.pumpAndSettle();

    // Unfiltered (Active tab): all 5 seeded customers are visible.
    expect(find.text('Rana Nasser'), findsOneWidget);
    expect(find.text('Yousef Hamdan'), findsOneWidget);

    await tester.tap(find.text('Debtors'));
    await tester.pumpAndSettle();

    // Mahmoud (₪5 owed), Karim (₪55 owed), and Lina (₪30 owed) still owe
    // money; Rana and Yousef are both fully paid off and drop out.
    expect(find.text('Mahmoud Salah'), findsOneWidget);
    expect(find.text('Karim Odeh'), findsOneWidget);
    expect(find.text('Lina Abu Rahma'), findsOneWidget);
    expect(find.text('Rana Nasser'), findsNothing);
    expect(find.text('Yousef Hamdan'), findsNothing);

    // Paying off Mahmoud's only remaining balance drops him out of the
    // Debtors tab without needing to leave it.
    await tester.tap(find.text('Mahmoud Salah'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Payment'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add Payment'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Mahmoud Salah'), findsNothing);
    expect(find.text('Karim Odeh'), findsOneWidget);
  });

  testWidgets('More: shows the menu + profile, and logout returns to Login', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SimSalesManagerApp());
    await tester.pumpAndSettle();

    final textFields = find.byType(TextField);
    await tester.enterText(textFields.at(0), 'owner@simmanager.app');
    await tester.enterText(textFields.at(1), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();

    expect(find.text('Ahmed Mq'), findsOneWidget);
    expect(find.text('owner@simmanager.app'), findsOneWidget);
    expect(find.text('Shipments & Operations'), findsOneWidget);
    expect(find.text('Number Update'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // All 8 More rows are real now — Shipments & Operations was the
    // last one built, so this confirms it actually opens instead of
    // showing the old "Coming soon" stub.
    await tester.tap(find.text('Shipments & Operations'));
    await tester.pumpAndSettle();
    expect(find.text('New Shipment'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsWidgets);
  });

  testWidgets('Settings: edit profile, change currency app-wide, toggle dark mode, change password', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SimSalesManagerApp());
    await tester.pumpAndSettle();

    final loginFields = find.byType(TextField);
    await tester.enterText(loginFields.at(0), 'owner@simmanager.app');
    await tester.enterText(loginFields.at(1), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    // Profile fields are prefilled from ProfileCubit's mock defaults.
    expect(find.text('Ahmed Mq'), findsOneWidget);
    expect(find.text('owner@simmanager.app'), findsOneWidget);

    // Edit + save the profile.
    final settingsFields = find.byType(TextField);
    await tester.enterText(settingsFields.at(0), 'Ahmed Updated');
    await tester.pump();
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
    expect(find.text('Profile updated.'), findsOneWidget);

    // Switching to Arabic re-renders the whole app's text via
    // easy_localization — spot-check one string here, then switch back to
    // English so the rest of this test (and every other test) can keep
    // relying on English text.
    await tester.tap(find.text('AR'));
    await tester.pumpAndSettle();
    expect(find.text('الإعدادات'), findsOneWidget);
    expect(find.text('Settings'), findsNothing);
    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);

    // Toggle dark mode from Settings and confirm it actually applied.
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(Theme.of(tester.element(find.byType(Scaffold).first)).brightness, Brightness.dark);

    // Change the currency symbol, then confirm it's reflected app-wide
    // (currency_formatter reads it live via SettingsCubit), not just on
    // this page.
    await tester.enterText(settingsFields.at(2), r'$');
    await tester.pump();
    await tester.tap(find.text('Save').first);
    await tester.pumpAndSettle();
    expect(find.text('Currency symbol updated.'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.textContaining(r'$'), findsWidgets);

    // Back to Settings to exercise Change Password.
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Change Password'));
    await tester.pumpAndSettle();

    final passwordFields = find.byType(TextField);
    await tester.enterText(passwordFields.at(3), 'oldpass123');
    await tester.enterText(passwordFields.at(4), 'newpass123');
    await tester.enterText(passwordFields.at(5), 'mismatch');
    await tester.pump();
    await tester.tap(find.text('Save').last);
    await tester.pumpAndSettle();
    expect(find.textContaining("don't match"), findsOneWidget);

    await tester.enterText(passwordFields.at(5), 'newpass123');
    await tester.pump();
    await tester.tap(find.text('Save').last);
    await tester.pumpAndSettle();
    expect(find.text('Password changed.'), findsOneWidget);
  });

  testWidgets('Numbers: filters the global line log by status, company, and search', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SimSalesManagerApp());
    await tester.pumpAndSettle();

    final loginFields = find.byType(TextField);
    await tester.enterText(loginFields.at(0), 'owner@simmanager.app');
    await tester.enterText(loginFields.at(1), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Numbers'));
    await tester.pumpAndSettle();

    expect(find.text('Number Management'), findsOneWidget);

    // Spot-check Arabic translations resolve here too, then switch back.
    await tester.element(find.byType(Scaffold).first).setLocale(const Locale('ar'));
    await tester.pumpAndSettle();
    expect(find.text('إدارة الأرقام'), findsOneWidget);
    await tester.element(find.byType(Scaffold).first).setLocale(const Locale('en'));
    await tester.pumpAndSettle();

    // Tapping "Custom" opens Flutter's real date-range picker — not the
    // old "coming soon" stub. The period pill row scrolls horizontally
    // and "Custom" is the last pill, so it needs scrolling into view
    // first (same reasoning as the vertical-scroll helpers used
    // elsewhere in this file — ListView only builds what's visible).
    final periodRowScrollable = find.descendant(
      of: find.byWidgetPredicate((w) => w is ListView && w.scrollDirection == Axis.horizontal),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(find.text('Custom'), 200, scrollable: periodRowScrollable);

    // Flutter's own `showDateRangePicker` switches to a "fullscreen"
    // layout below a width threshold, and that layout's header can
    // overflow by a few pixels regardless of font/theme (a Flutter
    // framework limitation, not this app's code — see the doc comment on
    // `pickCustomDateRange`). Widen the viewport just for this
    // interaction so the picker uses its wider dialog-style layout
    // instead, sidestepping that framework edge case entirely.
    tester.view.physicalSize = const Size(700, 900);
    await tester.pumpAndSettle();

    // Dismiss it without picking a range (popping the route directly is
    // more robust than hunting for the picker's own Cancel button — its
    // exact label/icon differs between Flutter's compact and fullscreen
    // layouts), and confirm the pill still just says "Custom" (no range
    // was committed) rather than switching the selected period at all.
    await tester.tap(find.text('Custom'));
    await tester.pumpAndSettle();
    expect(find.byType(DateRangePickerDialog), findsOneWidget);
    Navigator.of(tester.element(find.byType(DateRangePickerDialog))).pop();
    await tester.pumpAndSettle();
    expect(find.text('Custom'), findsOneWidget);

    // Back to the narrow viewport for the rest of this test.
    tester.view.physicalSize = const Size(400, 2200);
    await tester.pumpAndSettle();

    // Unfiltered: an expired line (Mahmoud's Jawwal "Monthly 5GB") and an
    // active line (Lina's Airalo "Global 5GB") are both visible. Both
    // package names are unique across the mock dataset, unlike most of
    // the others which repeat across different companies/customers.
    expect(find.text('Monthly 5GB'), findsOneWidget);
    expect(find.text('Global 5GB'), findsOneWidget);

    // Filter to Expired only (the filter pill, which sits above the
    // table — matching badges in the table itself also say "Expired").
    await tester.tap(find.text('Expired').first);
    await tester.pumpAndSettle();
    expect(find.text('Monthly 5GB'), findsOneWidget);
    expect(find.text('Global 5GB'), findsNothing);

    // Back to All (the status pill, which renders after the period pill
    // row so it's the last "All" in the tree), then filter by company.
    await tester.tap(find.text('All').last);
    await tester.pumpAndSettle();
    expect(find.text('Global 5GB'), findsOneWidget);

    await tester.tap(find.byType(PopupMenuButton<String?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Jawwal').last);
    await tester.pumpAndSettle();
    expect(find.text('Monthly 5GB'), findsOneWidget); // Jawwal
    expect(find.text('Global 5GB'), findsNothing); // that one's Airalo eSIM

    // With the Jawwal filter still active, search narrows it further —
    // Karim Odeh has two "Weekly 2GB" lines on different companies/
    // numbers; searching his Jawwal one should isolate just that row.
    await tester.enterText(find.byType(TextField).first, '0569884413');
    await tester.pumpAndSettle();
    expect(find.text('Weekly 2GB'), findsOneWidget);
    expect(find.text('Monthly 5GB'), findsNothing); // filtered out by search now
  });

  testWidgets('Activity Log: shows the mock audit trail and search filters it', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SimSalesManagerApp());
    await tester.pumpAndSettle();

    final loginFields = find.byType(TextField);
    await tester.enterText(loginFields.at(0), 'owner@simmanager.app');
    await tester.enterText(loginFields.at(1), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Activity Log'));
    await tester.pumpAndSettle();

    expect(find.text('15 events'), findsOneWidget);

    // Spot-check Arabic translations resolve here too, then switch back.
    await tester.element(find.byType(Scaffold).first).setLocale(const Locale('ar'));
    await tester.pumpAndSettle();
    expect(find.text('15 حدث'), findsOneWidget);
    await tester.element(find.byType(Scaffold).first).setLocale(const Locale('en'));
    await tester.pumpAndSettle();
    expect(find.text('15 matching'), findsOneWidget);
    expect(find.text('Login'), findsWidgets);
    expect(find.text('Full Collection'), findsWidgets);

    // Search narrows the log to only "Delete" rows (matches both the
    // action-type label and the word "deleted" inside the details text).
    await tester.enterText(find.byType(TextField).first, 'delete');
    await tester.pumpAndSettle();
    expect(find.text('2 matching'), findsOneWidget);
    expect(find.text('Login'), findsNothing);
  });

  testWidgets('Trusted Devices: shows the current device and can revoke another one', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SimSalesManagerApp());
    await tester.pumpAndSettle();

    final loginFields = find.byType(TextField);
    await tester.enterText(loginFields.at(0), 'owner@simmanager.app');
    await tester.enterText(loginFields.at(1), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Trusted Devices'));
    await tester.pumpAndSettle();

    expect(find.text('Windows - Chrome'), findsOneWidget);
    expect(find.text('This Device'), findsOneWidget);
    expect(find.text('192.168.1.12'), findsOneWidget);
    expect(find.text('macOS - Safari'), findsOneWidget);

    // Spot-check Arabic translations resolve here too, then switch back.
    await tester.element(find.byType(Scaffold).first).setLocale(const Locale('ar'));
    await tester.pumpAndSettle();
    expect(find.text('هذا الجهاز'), findsOneWidget);
    await tester.element(find.byType(Scaffold).first).setLocale(const Locale('en'));
    await tester.pumpAndSettle();

    // Revoke the last card (macOS - Safari, not the current device) and
    // confirm it's gone afterward.
    final deleteButtons = find.byIcon(Icons.delete_outline_rounded);
    await tester.tap(deleteButtons.last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Revoke'));
    await tester.pumpAndSettle();

    expect(find.text('macOS - Safari'), findsNothing);
    expect(find.text('Windows - Chrome'), findsOneWidget); // untouched
  });

  testWidgets('Support & Feedback: select a type, submit, and see it in Previous Requests', (WidgetTester tester) async {
    // Deliberately doesn't tap "Attach Photo"/"Record Voice Note" — those
    // call the real image_picker/record plugins, which aren't mocked in
    // the widget-test environment.
    tester.view.physicalSize = const Size(400, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SimSalesManagerApp());
    await tester.pumpAndSettle();

    final loginFields = find.byType(TextField);
    await tester.enterText(loginFields.at(0), 'owner@simmanager.app');
    await tester.enterText(loginFields.at(1), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Support & Feedback'));
    await tester.pumpAndSettle();

    expect(find.text('5 of 5 requests left today'), findsOneWidget);
    expect(find.text('No requests yet'), findsOneWidget);

    // Spot-check Arabic translations resolve here too, then switch back.
    await tester.element(find.byType(Scaffold).first).setLocale(const Locale('ar'));
    await tester.pumpAndSettle();
    expect(find.text('5 من 5 طلبات متبقية اليوم'), findsOneWidget);
    await tester.element(find.byType(Scaffold).first).setLocale(const Locale('en'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Problem'));
    await tester.pumpAndSettle();

    const message = 'The app crashes when I add a new customer.';
    await tester.enterText(find.byType(TextField).first, message);
    await tester.pumpAndSettle();
    expect(find.text('${message.length}/4000'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit'));
    await tester.pumpAndSettle();

    expect(find.text('Thanks — your feedback was submitted.'), findsOneWidget);
    expect(find.text('4 of 5 requests left today'), findsOneWidget);
    expect(find.text('No requests yet'), findsNothing);
    expect(find.text(message), findsOneWidget);
    expect(find.text('0/4000'), findsOneWidget); // form cleared after submit
  });

  testWidgets('Profits: shows real figures derived from seeded lines and companies', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SimSalesManagerApp());
    await tester.pumpAndSettle();

    final loginFields = find.byType(TextField);
    await tester.enterText(loginFields.at(0), 'owner@simmanager.app');
    await tester.enterText(loginFields.at(1), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profits'));
    await tester.pumpAndSettle();

    // Spot-check Arabic translations resolve here too, then switch back.
    await tester.element(find.byType(Scaffold).first).setLocale(const Locale('ar'));
    await tester.pumpAndSettle();
    expect(find.text('الأرباح'), findsOneWidget);
    await tester.element(find.byType(Scaffold).first).setLocale(const Locale('en'));
    await tester.pumpAndSettle();

    // These are real sums over the seeded mock lines/companies (see
    // customers_mock_data.dart / companies_mock_data.dart), not
    // hardcoded mock stats — computed by hand in a code comment here so
    // a future data change makes this test fail loudly instead of
    // silently drifting.
    expect(find.text('₪225.00'), findsOneWidget); // year profit (all 10 lines)
    expect(find.text('₪184.00'), findsWidgets); // month profit == default selected-period net profit (8 lines)
    expect(find.text('₪105.00'), findsOneWidget); // week profit (4 lines)
    expect(find.text('₪0.00'), findsOneWidget); // today profit (none purchased today)

    // Default selected period is "This Month".
    expect(find.text('8'), findsWidgets); // selected-period operations count
    expect(find.text('₪300.00'), findsOneWidget); // selected-period total sales

    // Best Companies by Profit, sorted descending.
    expect(find.text('Jawwal'), findsOneWidget);
    expect(find.text('₪67.00'), findsOneWidget);
    expect(find.text('₪37.00'), findsOneWidget); // Ooredoo

    // Tapping "Year Profit" switches the selected period to This Year
    // (StatCard renders its title uppercased).
    await tester.tap(find.text('YEAR PROFIT'));
    await tester.pumpAndSettle();
    expect(find.text('10'), findsWidgets); // now 10 operations for the year
  });

  testWidgets('Reports: shows real totals over all operations and filters by company', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SimSalesManagerApp());
    await tester.pumpAndSettle();

    final loginFields = find.byType(TextField);
    await tester.enterText(loginFields.at(0), 'owner@simmanager.app');
    await tester.enterText(loginFields.at(1), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reports'));
    await tester.pumpAndSettle();

    // Spot-check Arabic translations resolve here too, then switch back.
    await tester.element(find.byType(Scaffold).first).setLocale(const Locale('ar'));
    await tester.pumpAndSettle();
    expect(find.text('التقارير'), findsOneWidget);
    await tester.element(find.byType(Scaffold).first).setLocale(const Locale('en'));
    await tester.pumpAndSettle();

    // Default filters are "All" period / all companies, so these are
    // sums over every seeded line (hand-computed from
    // customers_mock_data.dart, same approach as the Profits test).
    expect(find.text('₪225.00'), findsOneWidget); // total profit
    expect(find.text('₪421.00'), findsOneWidget); // total sales
    expect(find.text('10'), findsWidgets); // lines sold == operations count
    expect(find.text('₪90.00'), findsOneWidget); // amount to collect
    expect(find.text('3'), findsOneWidget); // partially paid
    expect(find.text('1'), findsOneWidget); // unpaid

    // The operations table includes customer name and rep name columns.
    expect(find.text('Mahmoud Salah'), findsWidgets);
    expect(find.text('Ahmed Mq'), findsWidgets); // rep name, from ProfileCubit

    // Filter to Airalo eSIM (Lina Abu Rahma's two lines: profit 58 + 42).
    await tester.tap(find.byType(PopupMenuButton<String?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Airalo eSIM').last);
    await tester.pumpAndSettle();

    expect(find.text('₪100.00'), findsOneWidget); // total profit, Airalo only
    expect(find.text('Mahmoud Salah'), findsNothing);
  });

  testWidgets('Shipments & Operations: shipments update a real company balance; operations reflect real lines', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SimSalesManagerApp());
    await tester.pumpAndSettle();

    final loginFields = find.byType(TextField);
    await tester.enterText(loginFields.at(0), 'owner@simmanager.app');
    await tester.enterText(loginFields.at(1), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Shipments & Operations'));
    await tester.pumpAndSettle();

    // Spot-check Arabic translations resolve here too, then switch back.
    await tester.element(find.byType(Scaffold).first).setLocale(const Locale('ar'));
    await tester.pumpAndSettle();
    expect(find.text('الشحنات والعمليات'), findsOneWidget);
    await tester.element(find.byType(Scaffold).first).setLocale(const Locale('en'));
    await tester.pumpAndSettle();

    // Shipments tab (default): seeded transaction history + totals.
    // (2000+900+600+1500 total, 2000+300+600+1500 paid, 600 remaining —
    // hand-computed from shipments_mock_data.dart.)
    expect(find.text('₪5,000.00'), findsOneWidget); // total shipments
    expect(find.text('₪4,400.00'), findsOneWidget); // paid
    // ₪600.00 also happens to match Ooredoo's seeded "owed to company"
    // balance card, so this isn't unique — just confirm it's present.
    expect(find.text('₪600.00'), findsWidgets); // remaining
    expect(find.text('Jawwal'), findsWidgets);

    // Add a new shipment against Jawwal and confirm it actually moves
    // that company's real balance (Jawwal starts at ₪1,832.00 available
    // to sell, per companies_mock_data.dart).
    await tester.tap(find.text('New Shipment'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<CompanySummary>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Jawwal').last);
    await tester.pumpAndSettle();

    final shipmentFields = find.byType(TextField);
    await tester.enterText(shipmentFields.at(0), '500'); // total amount
    await tester.enterText(shipmentFields.at(1), '500'); // amount paid
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text('₪2,332.00'), findsOneWidget); // Jawwal's new available-to-sell (1832 + 500)
    expect(find.text('₪5,500.00'), findsOneWidget); // total shipments, updated

    // Operations tab: real stats over the seeded lines (same figures
    // verified independently in the Reports test).
    await tester.tap(find.text('Operations'));
    await tester.pumpAndSettle();

    expect(find.text('3'), findsWidgets); // partially paid
    expect(find.text('1'), findsWidgets); // unpaid
    expect(find.text('₪90.00'), findsOneWidget); // amount to collect

    // Filtering to Unpaid isolates Karim Odeh's one unpaid line. (His
    // number appears twice in the row — SIM Number and Contact columns
    // — since his mock data reuses the same number for both.)
    await tester.tap(find.text('Unpaid'));
    await tester.pumpAndSettle();
    expect(find.text('0569884412'), findsNWidgets(2));
    expect(find.text('0599123456'), findsNothing); // Mahmoud's lines are gone

    // Tapping that row opens the read-only Operation Detail sheet. (The
    // number matches twice — it's both the SIM number and Karim's own
    // contact number in the seeded mock data.)
    await tester.tap(find.text('0569884412').first);
    await tester.pumpAndSettle();
    expect(find.text('Operation Detail'), findsOneWidget);
    // "Karim Odeh" also still appears in the table row behind the sheet.
    expect(find.text('Karim Odeh'), findsWidgets);
  });

  testWidgets('Number Update: shows seeded history for a known number and adds a new entry on update', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SimSalesManagerApp());
    await tester.pumpAndSettle();

    final loginFields = find.byType(TextField);
    await tester.enterText(loginFields.at(0), 'owner@simmanager.app');
    await tester.enterText(loginFields.at(1), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Number Update'));
    await tester.pumpAndSettle();

    // Spot-check Arabic translations resolve here too, then switch back.
    await tester.element(find.byType(Scaffold).first).setLocale(const Locale('ar'));
    await tester.pumpAndSettle();
    expect(find.text('تحديث الأرقام'), findsOneWidget);
    await tester.element(find.byType(Scaffold).first).setLocale(const Locale('en'));
    await tester.pumpAndSettle();

    // No number typed yet — empty state.
    expect(find.text('No history yet'), findsOneWidget);

    // Mahmoud Salah's seeded number has 2 prior "Updated" entries.
    final numberField = find.byType(TextField).first;
    await tester.enterText(numberField, '0599123456');
    await tester.pumpAndSettle();
    expect(find.text('No history yet'), findsNothing);
    expect(find.text('Updated'), findsNWidgets(2));

    // Tapping "Update Number" adds a fresh entry on top of the same log.
    await tester.tap(find.widgetWithText(ElevatedButton, 'Update Number'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();
    expect(find.text('Updated'), findsNWidgets(3));

    // A different, previously-unseen number starts with its own empty log.
    await tester.enterText(numberField, '0501112222');
    await tester.pumpAndSettle();
    expect(find.text('No history yet'), findsOneWidget);
  });

  testWidgets('New Sale: opens from the bottom nav "+" button and shows step 1', (WidgetTester tester) async {
    // The full 4-step flow (dropdowns, date pickers) is exercised in
    // new_sale_cubit_test.dart at the Cubit level, which is far more
    // reliable than driving Flutter's native Dropdown overlay through
    // widget-test taps. This just proves the wiring: NewSaleLauncher ->
    // getIt catalogs -> the sheet actually opens with real data.
    await tester.pumpWidget(_localizedApp(const CompaniesPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('New Sale'));
    await tester.pumpAndSettle();

    expect(find.text('1/4 · Customer'), findsOneWidget);
    expect(find.text('Karim Odeh'), findsOneWidget); // real customer data from the catalog

    // Spot-check Arabic translations resolve here too, then switch back.
    await tester.element(find.byType(Scaffold).first).setLocale(const Locale('ar'));
    await tester.pumpAndSettle();
    expect(find.text('1/4 · العميل'), findsOneWidget);
    await tester.element(find.byType(Scaffold).first).setLocale(const Locale('en'));
    await tester.pumpAndSettle();
  });
}

Finder _menuButtonFor(WidgetTester tester, String companyName) {
  return find.descendant(
    of: find.ancestor(of: find.text(companyName), matching: find.byType(CompanyCard)),
    matching: find.byIcon(Icons.more_vert_rounded),
  );
}

import 'package:flutter_test/flutter_test.dart';

import 'package:sim_sales_manager/core/catalog/company_catalog.dart';
import 'package:sim_sales_manager/core/catalog/company_summary.dart';
import 'package:sim_sales_manager/core/catalog/customer_catalog.dart';
import 'package:sim_sales_manager/core/catalog/customer_summary.dart';
import 'package:sim_sales_manager/core/catalog/line_summary.dart';
import 'package:sim_sales_manager/features/new_sale/presentation/cubit/new_sale_cubit.dart';
import 'package:sim_sales_manager/features/new_sale/presentation/cubit/new_sale_state.dart';

/// Test double standing in for CompaniesCubit — records every call instead
/// of touching real state, so these tests only need to prove NewSaleCubit
/// calls the catalog contract correctly.
class _FakeCompanyCatalog implements CompanyCatalog {
  final List<CompanySummary> companies;
  final List<({String companyId, double wholesaleCost, double profit})> recordedSales = [];

  _FakeCompanyCatalog(this.companies);

  @override
  List<CompanySummary> get activeCompanies => companies;

  @override
  void recordSale({required String companyId, required double wholesaleCost, required double profit}) {
    recordedSales.add((companyId: companyId, wholesaleCost: wholesaleCost, profit: profit));
  }

  @override
  void addShipment({required String companyId, required double totalAmount, required double amountPaid}) {}
}

class _AddedLine {
  final String customerId;
  final String simNumber;
  final String companyName;
  final String packageName;
  final double wholesaleCost;
  final double retailPrice;
  final double amountPaid;

  _AddedLine({
    required this.customerId,
    required this.simNumber,
    required this.companyName,
    required this.packageName,
    required this.wholesaleCost,
    required this.retailPrice,
    required this.amountPaid,
  });
}

class _FakeCustomerCatalog implements CustomerCatalog {
  final List<CustomerSummary> customers;
  final List<_AddedLine> addedLines = [];
  String? quickAddedName;
  String? quickAddedContact;

  _FakeCustomerCatalog(this.customers);

  @override
  List<CustomerSummary> get activeCustomers => customers;

  @override
  List<LineSummary> get allLines => [];

  @override
  String quickAddCustomer({required String name, required String contactNumber}) {
    quickAddedName = name;
    quickAddedContact = contactNumber;
    const id = 'new-customer';
    customers.add(CustomerSummary(id: id, name: name, contactNumber: contactNumber, status: CustomerStatusSummary.normal));
    return id;
  }

  @override
  void addSaleLine({
    required String customerId,
    required String simNumber,
    required String companyName,
    required String companyInitials,
    required String packageName,
    required DateTime purchaseDate,
    required DateTime expiryDate,
    required double wholesaleCost,
    required double retailPrice,
    required double amountPaid,
  }) {
    addedLines.add(_AddedLine(
      customerId: customerId,
      simNumber: simNumber,
      companyName: companyName,
      packageName: packageName,
      wholesaleCost: wholesaleCost,
      retailPrice: retailPrice,
      amountPaid: amountPaid,
    ));
  }
}

void main() {
  const package = PackageSummary(id: 'pkg-1', name: 'Global 5GB', wholesaleCost: 30, retailPrice: 45);
  const company = CompanySummary(id: 'company-1', name: 'Airalo eSIM', initials: 'AE', packages: [package]);
  const customer = CustomerSummary(id: 'cust-1', name: 'Karim Odeh', contactNumber: '0569884412', status: CustomerStatusSummary.troubled);

  test('full flow with an existing customer: records the line and deducts the company balance', () {
    final companyCatalog = _FakeCompanyCatalog([company]);
    final customerCatalog = _FakeCustomerCatalog([customer]);
    final cubit = NewSaleCubit(companyCatalog: companyCatalog, customerCatalog: customerCatalog);

    expect(cubit.state.customers, [customer]);
    expect(cubit.state.companies, [company]);

    // Step 1: customer.
    expect(cubit.state.canGoNextFromCustomerStep, isFalse);
    cubit.selectCustomer('cust-1');
    expect(cubit.state.canGoNextFromCustomerStep, isTrue);
    cubit.goNext();
    expect(cubit.state.step, NewSaleStep.packageAndPrice);

    // Step 2: package & price — selecting the package auto-fills cost/price.
    expect(cubit.state.canGoNextFromPackageStep, isFalse);
    cubit.selectCompany('company-1');
    cubit.selectPackage('pkg-1');
    expect(cubit.state.wholesaleCost, 30);
    expect(cubit.state.retailPrice, 45);
    expect(cubit.state.profit, 15);
    cubit.simNumberChanged('0500000111');
    expect(cubit.state.canGoNextFromPackageStep, isTrue);
    cubit.goNext();
    expect(cubit.state.step, NewSaleStep.payment);

    // Step 3: payment — "mark fully paid" shortcut.
    cubit.markFullyPaid();
    expect(cubit.state.amountPaid, 45);
    expect(cubit.state.remaining, 0);
    expect(cubit.state.paymentStatus, LinePaymentStatus.paid);
    cubit.goNext();
    expect(cubit.state.step, NewSaleStep.confirm);

    // Step 4: confirm & save.
    cubit.confirmAndSave();

    expect(cubit.state.saved, isTrue);
    expect(cubit.state.savedSummary, 'Karim Odeh · Global 5GB');

    expect(customerCatalog.addedLines, hasLength(1));
    final line = customerCatalog.addedLines.single;
    expect(line.customerId, 'cust-1');
    expect(line.simNumber, '0500000111');
    expect(line.companyName, 'Airalo eSIM');
    expect(line.packageName, 'Global 5GB');
    expect(line.retailPrice, 45);
    expect(line.amountPaid, 45);

    expect(companyCatalog.recordedSales, hasLength(1));
    final sale = companyCatalog.recordedSales.single;
    expect(sale.companyId, 'company-1');
    expect(sale.wholesaleCost, 30);
    expect(sale.profit, 15);
  });

  test('creates a new customer inline and records an unpaid line when "Unpaid" is chosen', () {
    final companyCatalog = _FakeCompanyCatalog([company]);
    final customerCatalog = _FakeCustomerCatalog([]);
    final cubit = NewSaleCubit(companyCatalog: companyCatalog, customerCatalog: customerCatalog);

    cubit.toggleNewCustomerForm();
    expect(cubit.state.showNewCustomerForm, isTrue);
    expect(cubit.state.canGoNextFromCustomerStep, isFalse);
    cubit.newCustomerNameChanged('New Guy');
    cubit.newCustomerContactChanged('0511111111');
    expect(cubit.state.canGoNextFromCustomerStep, isTrue);
    cubit.goNext();

    cubit.selectCompany('company-1');
    cubit.selectPackage('pkg-1');
    cubit.simNumberChanged('0500000222');
    cubit.goNext();

    cubit.markUnpaid();
    expect(cubit.state.paymentStatus, LinePaymentStatus.unpaid);
    cubit.goNext();

    cubit.confirmAndSave();

    expect(customerCatalog.quickAddedName, 'New Guy');
    expect(customerCatalog.quickAddedContact, '0511111111');
    expect(customerCatalog.addedLines.single.customerId, 'new-customer');
    expect(customerCatalog.addedLines.single.amountPaid, 0);
    expect(companyCatalog.recordedSales.single.profit, 15);
  });

  test('goNext is a no-op while the current step has unmet requirements', () {
    final companyCatalog = _FakeCompanyCatalog([company]);
    final customerCatalog = _FakeCustomerCatalog([customer]);
    final cubit = NewSaleCubit(companyCatalog: companyCatalog, customerCatalog: customerCatalog);

    cubit.goNext(); // no customer selected yet
    expect(cubit.state.step, NewSaleStep.customer);

    cubit.selectCustomer('cust-1');
    cubit.goNext();
    expect(cubit.state.step, NewSaleStep.packageAndPrice);

    cubit.goNext(); // no company/package/sim yet
    expect(cubit.state.step, NewSaleStep.packageAndPrice);
  });
}

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/catalog/company_catalog.dart';
import '../../../../core/catalog/customer_catalog.dart';
import 'new_sale_state.dart';

/// Drives the 4-step New Sale wizard (Customer -> Package & Price ->
/// Payment -> Confirm). Reads/writes Companies and Customers data only
/// through the [CompanyCatalog]/[CustomerCatalog] interfaces — see
/// core/catalog/ for why (no cross-feature imports).
class NewSaleCubit extends Cubit<NewSaleState> {
  final CompanyCatalog _companyCatalog;
  final CustomerCatalog _customerCatalog;

  NewSaleCubit({required CompanyCatalog companyCatalog, required CustomerCatalog customerCatalog})
      : _companyCatalog = companyCatalog,
        _customerCatalog = customerCatalog,
        super(NewSaleState(
          purchaseDate: DateTime.now(),
          expiryDate: DateTime.now().add(const Duration(days: 30)),
        )) {
    emit(state.copyWith(customers: _customerCatalog.activeCustomers, companies: _companyCatalog.activeCompanies));
  }

  // --- Step 1: customer ---

  void customerSearchChanged(String query) => emit(state.copyWith(customerSearch: query));

  void selectCustomer(String id) => emit(state.copyWith(selectedCustomerId: id, showNewCustomerForm: false));

  void toggleNewCustomerForm() => emit(state.copyWith(
        showNewCustomerForm: !state.showNewCustomerForm,
        clearSelectedCustomer: !state.showNewCustomerForm,
      ));

  void newCustomerNameChanged(String value) => emit(state.copyWith(newCustomerName: value));

  void newCustomerContactChanged(String value) => emit(state.copyWith(newCustomerContact: value));

  // --- Step 2: package & price ---

  void selectCompany(String companyId) {
    emit(state.copyWith(
      selectedCompanyId: companyId,
      clearSelectedPackage: true,
      wholesaleCost: 0,
      retailPrice: 0,
    ));
  }

  void selectPackage(String packageId) {
    final company = state.selectedCompany;
    if (company == null) return;
    final matches = company.packages.where((p) => p.id == packageId);
    if (matches.isEmpty) return;
    final package = matches.first;
    emit(state.copyWith(
      selectedPackageId: packageId,
      wholesaleCost: package.wholesaleCost,
      // Deliberately not pre-filled from the package — a package no
      // longer carries its own retail price (see CompanyPackage's doc
      // comment), so the seller always types it fresh per sale.
      retailPrice: 0,
    ));
  }

  void simNumberChanged(String value) => emit(state.copyWith(simNumber: value));

  void wholesaleCostChanged(double value) => emit(state.copyWith(wholesaleCost: value));

  void retailPriceChanged(double value) => emit(state.copyWith(retailPrice: value));

  void purchaseDateChanged(DateTime date) => emit(state.copyWith(purchaseDate: date));

  void expiryDateChanged(DateTime date) => emit(state.copyWith(expiryDate: date));

  // --- Step 3: payment ---

  void amountPaidChanged(double value) => emit(state.copyWith(amountPaid: value));

  void markFullyPaid() => emit(state.copyWith(amountPaid: state.retailPrice));

  void markUnpaid() => emit(state.copyWith(amountPaid: 0));

  void paymentMethodChanged(String value) => emit(state.copyWith(paymentMethod: value));

  void referenceNumberChanged(String value) => emit(state.copyWith(referenceNumber: value));

  void notesChanged(String value) => emit(state.copyWith(notes: value));

  // --- Navigation ---

  void goNext() {
    switch (state.step) {
      case NewSaleStep.customer:
        if (state.canGoNextFromCustomerStep) emit(state.copyWith(step: NewSaleStep.packageAndPrice));
      case NewSaleStep.packageAndPrice:
        if (state.canGoNextFromPackageStep) emit(state.copyWith(step: NewSaleStep.payment));
      case NewSaleStep.payment:
        emit(state.copyWith(step: NewSaleStep.confirm));
      case NewSaleStep.confirm:
        break;
    }
  }

  void goBack() {
    switch (state.step) {
      case NewSaleStep.customer:
        break;
      case NewSaleStep.packageAndPrice:
        emit(state.copyWith(step: NewSaleStep.customer));
      case NewSaleStep.payment:
        emit(state.copyWith(step: NewSaleStep.packageAndPrice));
      case NewSaleStep.confirm:
        emit(state.copyWith(step: NewSaleStep.payment));
    }
  }

  /// Creates the customer if needed, records the Line under them, and
  /// deducts the wholesale cost from the company's shipment balance.
  void confirmAndSave() {
    String customerId;
    String customerName;
    if (state.showNewCustomerForm) {
      customerName = state.newCustomerName.trim();
      customerId = _customerCatalog.quickAddCustomer(name: customerName, contactNumber: state.newCustomerContact.trim());
    } else {
      final customer = state.selectedCustomer!;
      customerId = customer.id;
      customerName = customer.name;
    }

    final company = state.selectedCompany!;
    final package = state.selectedPackage!;

    _customerCatalog.addSaleLine(
      customerId: customerId,
      simNumber: state.simNumber.trim(),
      companyId: company.id,
      companyName: company.name,
      companyInitials: company.initials,
      packageId: package.id,
      packageName: package.name,
      packageSimType: package.simType,
      purchaseDate: state.purchaseDate,
      expiryDate: state.expiryDate,
      wholesaleCost: state.wholesaleCost,
      retailPrice: state.retailPrice,
      amountPaid: state.amountPaid,
    );

    _companyCatalog.recordSale(companyId: company.id, wholesaleCost: state.wholesaleCost, profit: state.profit);

    emit(state.copyWith(saved: true, savedSummary: '$customerName · ${package.name}'));
  }
}

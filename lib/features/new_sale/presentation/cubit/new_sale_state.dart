import 'package:equatable/equatable.dart';

import '../../../../core/catalog/company_summary.dart';
import '../../../../core/catalog/customer_summary.dart';
import '../../../../core/catalog/line_summary.dart';

enum NewSaleStep { customer, packageAndPrice, payment, confirm }

class NewSaleState extends Equatable {
  final NewSaleStep step;

  // Step 1: customer
  final List<CustomerSummary> customers;
  final String customerSearch;
  final String? selectedCustomerId;
  final bool showNewCustomerForm;
  final String newCustomerName;
  final String newCustomerContact;

  // Step 2: package & price
  final List<CompanySummary> companies;
  final String? selectedCompanyId;
  final String? selectedPackageId;
  final String simNumber;
  final double wholesaleCost;
  final double retailPrice;
  final DateTime purchaseDate;
  final DateTime expiryDate;

  // Step 3: payment
  final double amountPaid;
  final String paymentMethod;
  final String referenceNumber;
  final String notes;

  // Result
  final bool saved;
  final String? savedSummary;

  const NewSaleState({
    this.step = NewSaleStep.customer,
    this.customers = const [],
    this.customerSearch = '',
    this.selectedCustomerId,
    this.showNewCustomerForm = false,
    this.newCustomerName = '',
    this.newCustomerContact = '',
    this.companies = const [],
    this.selectedCompanyId,
    this.selectedPackageId,
    this.simNumber = '',
    this.wholesaleCost = 0,
    this.retailPrice = 0,
    required this.purchaseDate,
    required this.expiryDate,
    this.amountPaid = 0,
    this.paymentMethod = 'Cash',
    this.referenceNumber = '',
    this.notes = '',
    this.saved = false,
    this.savedSummary,
  });

  CustomerSummary? get selectedCustomer {
    if (selectedCustomerId == null) return null;
    for (final c in customers) {
      if (c.id == selectedCustomerId) return c;
    }
    return null;
  }

  CompanySummary? get selectedCompany {
    if (selectedCompanyId == null) return null;
    for (final c in companies) {
      if (c.id == selectedCompanyId) return c;
    }
    return null;
  }

  PackageSummary? get selectedPackage {
    final company = selectedCompany;
    if (company == null || selectedPackageId == null) return null;
    for (final p in company.packages) {
      if (p.id == selectedPackageId) return p;
    }
    return null;
  }

  List<CustomerSummary> get filteredCustomers {
    final query = customerSearch.trim().toLowerCase();
    if (query.isEmpty) return customers;
    return customers
        .where((c) => c.name.toLowerCase().contains(query) || c.contactNumber.toLowerCase().contains(query))
        .toList();
  }

  double get profit => retailPrice - wholesaleCost;

  double get remaining => (retailPrice - amountPaid).clamp(0, double.infinity).toDouble();

  /// Decoupled from any localized label string — compare this, not
  /// `paymentStatusLabel`, since the label text changes with the locale.
  LinePaymentStatus get paymentStatus {
    if (amountPaid <= 0) return LinePaymentStatus.unpaid;
    if (amountPaid >= retailPrice) return LinePaymentStatus.paid;
    return LinePaymentStatus.partial;
  }

  String get paymentStatusLabel => paymentStatus.label;

  bool get canGoNextFromCustomerStep {
    if (showNewCustomerForm) {
      return newCustomerName.trim().isNotEmpty && newCustomerContact.trim().isNotEmpty;
    }
    return selectedCustomerId != null;
  }

  /// Selling a line consumes from the company's shipment balance at
  /// wholesale price (design/APP_CONTEXT.md) — never let a sale go
  /// through for more than what's actually available.
  bool get exceedsCompanyBalance {
    final company = selectedCompany;
    if (company == null) return false;
    return wholesaleCost > company.availableToSell;
  }

  bool get canGoNextFromPackageStep {
    return selectedCompanyId != null &&
        selectedPackageId != null &&
        simNumber.trim().isNotEmpty &&
        retailPrice > 0 &&
        !exceedsCompanyBalance;
  }

  NewSaleState copyWith({
    NewSaleStep? step,
    List<CustomerSummary>? customers,
    String? customerSearch,
    bool clearSelectedCustomer = false,
    String? selectedCustomerId,
    bool? showNewCustomerForm,
    String? newCustomerName,
    String? newCustomerContact,
    List<CompanySummary>? companies,
    bool clearSelectedCompany = false,
    String? selectedCompanyId,
    bool clearSelectedPackage = false,
    String? selectedPackageId,
    String? simNumber,
    double? wholesaleCost,
    double? retailPrice,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    double? amountPaid,
    String? paymentMethod,
    String? referenceNumber,
    String? notes,
    bool? saved,
    String? savedSummary,
  }) {
    return NewSaleState(
      step: step ?? this.step,
      customers: customers ?? this.customers,
      customerSearch: customerSearch ?? this.customerSearch,
      selectedCustomerId: clearSelectedCustomer ? null : (selectedCustomerId ?? this.selectedCustomerId),
      showNewCustomerForm: showNewCustomerForm ?? this.showNewCustomerForm,
      newCustomerName: newCustomerName ?? this.newCustomerName,
      newCustomerContact: newCustomerContact ?? this.newCustomerContact,
      companies: companies ?? this.companies,
      selectedCompanyId: clearSelectedCompany ? null : (selectedCompanyId ?? this.selectedCompanyId),
      selectedPackageId: clearSelectedPackage ? null : (selectedPackageId ?? this.selectedPackageId),
      simNumber: simNumber ?? this.simNumber,
      wholesaleCost: wholesaleCost ?? this.wholesaleCost,
      retailPrice: retailPrice ?? this.retailPrice,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expiryDate: expiryDate ?? this.expiryDate,
      amountPaid: amountPaid ?? this.amountPaid,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      notes: notes ?? this.notes,
      saved: saved ?? this.saved,
      savedSummary: savedSummary ?? this.savedSummary,
    );
  }

  @override
  List<Object?> get props => [
        step,
        customers,
        customerSearch,
        selectedCustomerId,
        showNewCustomerForm,
        newCustomerName,
        newCustomerContact,
        companies,
        selectedCompanyId,
        selectedPackageId,
        simNumber,
        wholesaleCost,
        retailPrice,
        purchaseDate,
        expiryDate,
        amountPaid,
        paymentMethod,
        referenceNumber,
        notes,
        saved,
        savedSummary,
      ];
}

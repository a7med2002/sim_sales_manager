import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/catalog/customer_catalog.dart';
import '../../../../core/catalog/customer_summary.dart';
import '../../../../core/catalog/line_summary.dart';
import '../../data/customers_mock_data.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/line.dart';
import 'customers_state.dart';

/// Full CRUD over the in-memory mock customer + line lists — every
/// customer and every line is addable, editable and deletable. No
/// Drift/Supabase persistence yet: this only lives for the app session.
/// Also implements [CustomerCatalog], the narrow read/write surface other
/// features (New Sale) use instead of importing this Cubit directly.
class CustomersCubit extends Cubit<CustomersState> implements CustomerCatalog {
  CustomersCubit()
      : super(CustomersState(
          customers: CustomersMockData.initialCustomers(),
          lines: CustomersMockData.initialLines(),
        ));

  int _customerIdCounter = 1;
  int _lineIdCounter = 1;

  // --- List filters ---

  void selectTab(CustomersTab tab) {
    emit(state.copyWith(tab: tab));
  }

  void searchChanged(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void statusFilterChanged(CustomerStatus? status) {
    emit(state.copyWith(statusFilter: status, clearStatusFilter: status == null));
  }

  void tagFilterChanged(String? tag) {
    emit(state.copyWith(tagFilter: tag, clearTagFilter: tag == null));
  }

  // --- Customer CRUD ---

  Customer addCustomer({
    required String name,
    required String contactNumber,
    required List<String> tags,
    required CustomerStatus status,
    required bool pinned,
    required String notes,
  }) {
    final customer = Customer(
      id: 'customer-${_customerIdCounter++}',
      name: name,
      contactNumber: contactNumber,
      tags: tags,
      status: status,
      pinned: pinned,
      notes: notes,
    );
    emit(state.copyWith(customers: [...state.customers, customer]));
    return customer;
  }

  void updateCustomer(
    String id, {
    required String name,
    required String contactNumber,
    required List<String> tags,
    required CustomerStatus status,
    required bool pinned,
    required String notes,
  }) {
    _replaceCustomer(
      id,
      (c) => c.copyWith(
        name: name,
        contactNumber: contactNumber,
        tags: tags,
        status: status,
        pinned: pinned,
        notes: notes,
      ),
    );
  }

  void softDeleteCustomer(String id) {
    _replaceCustomer(id, (c) => c.copyWith(deleted: true));
  }

  void restoreCustomer(String id) {
    _replaceCustomer(id, (c) => c.copyWith(deleted: false));
  }

  void permanentlyDeleteCustomer(String id) {
    emit(state.copyWith(
      customers: state.customers.where((c) => c.id != id).toList(),
      lines: state.lines.where((l) => l.customerId != id).toList(),
    ));
  }

  void _replaceCustomer(String id, Customer Function(Customer) update) {
    emit(state.copyWith(
      customers: state.customers.map((c) => c.id == id ? update(c) : c).toList(),
    ));
  }

  // --- Line CRUD ---

  void addLine(
    String customerId, {
    required String simNumber,
    required String companyName,
    required String companyInitials,
    required String packageName,
    required DateTime purchaseDate,
    required DateTime expiryDate,
    required double wholesaleCost,
    required double retailPrice,
    required PaymentStatus paymentStatus,
    required double amountPaid,
    required double amountRemaining,
  }) {
    final line = Line(
      id: 'line-${_lineIdCounter++}',
      customerId: customerId,
      simNumber: simNumber,
      companyName: companyName,
      companyInitials: companyInitials,
      packageName: packageName,
      purchaseDate: purchaseDate,
      expiryDate: expiryDate,
      wholesaleCost: wholesaleCost,
      retailPrice: retailPrice,
      paymentStatus: paymentStatus,
      amountPaid: amountPaid,
      amountRemaining: amountRemaining,
    );
    emit(state.copyWith(lines: [...state.lines, line]));
  }

  void updateLine(
    String id, {
    required String simNumber,
    required String companyName,
    required String companyInitials,
    required String packageName,
    required DateTime purchaseDate,
    required DateTime expiryDate,
    required double wholesaleCost,
    required double retailPrice,
    required PaymentStatus paymentStatus,
    required double amountPaid,
    required double amountRemaining,
  }) {
    emit(state.copyWith(
      lines: state.lines
          .map((l) => l.id == id
              ? l.copyWith(
                  simNumber: simNumber,
                  companyName: companyName,
                  companyInitials: companyInitials,
                  packageName: packageName,
                  purchaseDate: purchaseDate,
                  expiryDate: expiryDate,
                  wholesaleCost: wholesaleCost,
                  retailPrice: retailPrice,
                  paymentStatus: paymentStatus,
                  amountPaid: amountPaid,
                  amountRemaining: amountRemaining,
                )
              : l)
          .toList(),
    ));
  }

  void deleteLine(String id) {
    emit(state.copyWith(lines: state.lines.where((l) => l.id != id).toList()));
  }

  /// Records a payment towards a specific line's remaining balance —
  /// e.g. the customer comes back later and pays off part or all of what
  /// they still owe on that one line (independent of their other lines).
  void addPayment(String lineId, double amount) {
    if (amount <= 0) return;
    emit(state.copyWith(
      lines: state.lines.map((l) => l.id == lineId ? l.applyPayment(amount) : l).toList(),
    ));
  }

  // --- CustomerCatalog ---

  @override
  List<CustomerSummary> get activeCustomers => state.customers
      .where((c) => !c.deleted)
      .map((c) => CustomerSummary(id: c.id, name: c.name, contactNumber: c.contactNumber, status: _toStatusSummary(c.status)))
      .toList();

  CustomerStatusSummary _toStatusSummary(CustomerStatus status) {
    switch (status) {
      case CustomerStatus.normal:
        return CustomerStatusSummary.normal;
      case CustomerStatus.troubled:
        return CustomerStatusSummary.troubled;
      case CustomerStatus.blocked:
        return CustomerStatusSummary.blocked;
    }
  }

  @override
  List<LineSummary> get allLines => state.lines.map((l) {
        final matchingCustomers = state.customers.where((c) => c.id == l.customerId);
        final customerName = matchingCustomers.isEmpty ? '' : matchingCustomers.first.name;
        final customerContact = matchingCustomers.isEmpty ? '' : matchingCustomers.first.contactNumber;
        return LineSummary(
          id: l.id,
          customerName: customerName,
          customerContact: customerContact,
          simNumber: l.simNumber,
          companyName: l.companyName,
          companyInitials: l.companyInitials,
          packageName: l.packageName,
          purchaseDate: l.purchaseDate,
          expiryDate: l.expiryDate,
          wholesaleCost: l.wholesaleCost,
          retailPrice: l.retailPrice,
          amountPaid: l.amountPaid,
          amountRemaining: l.amountRemaining,
          paymentStatus: _toLinePaymentStatus(l.paymentStatus),
        );
      }).toList();

  LinePaymentStatus _toLinePaymentStatus(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return LinePaymentStatus.paid;
      case PaymentStatus.partial:
        return LinePaymentStatus.partial;
      case PaymentStatus.unpaid:
        return LinePaymentStatus.unpaid;
    }
  }

  @override
  String quickAddCustomer({required String name, required String contactNumber}) {
    final customer = addCustomer(
      name: name,
      contactNumber: contactNumber,
      tags: const [],
      status: CustomerStatus.normal,
      pinned: false,
      notes: '',
    );
    return customer.id;
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
    final amountRemaining = (retailPrice - amountPaid).clamp(0, double.infinity).toDouble();
    final PaymentStatus paymentStatus;
    if (amountPaid <= 0) {
      paymentStatus = PaymentStatus.unpaid;
    } else if (amountPaid >= retailPrice) {
      paymentStatus = PaymentStatus.paid;
    } else {
      paymentStatus = PaymentStatus.partial;
    }

    addLine(
      customerId,
      simNumber: simNumber,
      companyName: companyName,
      companyInitials: companyInitials,
      packageName: packageName,
      purchaseDate: purchaseDate,
      expiryDate: expiryDate,
      wholesaleCost: wholesaleCost,
      retailPrice: retailPrice,
      paymentStatus: paymentStatus,
      amountPaid: amountPaid,
      amountRemaining: amountRemaining,
    );
  }
}

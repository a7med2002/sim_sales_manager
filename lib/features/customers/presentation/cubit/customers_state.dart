import 'package:equatable/equatable.dart';

import '../../domain/entities/customer.dart';
import '../../domain/entities/line.dart';

/// Active: not deleted. Debtors: not deleted *and* owes money on at least
/// one line — a convenience filter so collecting outstanding balances
/// doesn't require scanning every active customer by eye. Deleted:
/// soft-deleted (existing "Deleted" tab, unchanged).
enum CustomersTab { active, debtors, deleted }

class CustomersState extends Equatable {
  final List<Customer> customers;
  final List<Line> lines;
  final CustomersTab tab;
  final String searchQuery;
  final CustomerStatus? statusFilter;
  final String? tagFilter;

  const CustomersState({
    this.customers = const [],
    this.lines = const [],
    this.tab = CustomersTab.active,
    this.searchQuery = '',
    this.statusFilter,
    this.tagFilter,
  });

  List<String> get allTags {
    final tags = <String>{};
    for (final c in customers) {
      tags.addAll(c.tags);
    }
    final sorted = tags.toList()..sort();
    return sorted;
  }

  List<Customer> get visibleCustomers {
    final query = searchQuery.trim().toLowerCase();
    final filtered = customers.where((c) {
      switch (tab) {
        case CustomersTab.active:
          if (c.deleted) return false;
        case CustomersTab.debtors:
          if (c.deleted || totalOwedFor(c.id) <= 0) return false;
        case CustomersTab.deleted:
          if (!c.deleted) return false;
      }
      if (statusFilter != null && c.status != statusFilter) return false;
      if (tagFilter != null && !c.tags.contains(tagFilter)) return false;
      if (query.isNotEmpty &&
          !c.name.toLowerCase().contains(query) &&
          !c.contactNumber.toLowerCase().contains(query)) {
        return false;
      }
      return true;
    }).toList();

    filtered.sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
      return a.name.compareTo(b.name);
    });
    return filtered;
  }

  int get activeCount => customers.where((c) => !c.deleted).length;

  List<Line> linesFor(String customerId) => lines.where((l) => l.customerId == customerId).toList();

  double totalSpentFor(String customerId) =>
      linesFor(customerId).fold(0.0, (sum, l) => sum + l.retailPrice);

  double totalOwedFor(String customerId) =>
      linesFor(customerId).fold(0.0, (sum, l) => sum + l.amountRemaining);

  DateTime? lastPurchaseFor(String customerId) {
    final customerLines = linesFor(customerId);
    if (customerLines.isEmpty) return null;
    return customerLines.map((l) => l.purchaseDate).reduce((a, b) => a.isAfter(b) ? a : b);
  }

  CustomersState copyWith({
    List<Customer>? customers,
    List<Line>? lines,
    CustomersTab? tab,
    String? searchQuery,
    bool clearStatusFilter = false,
    CustomerStatus? statusFilter,
    bool clearTagFilter = false,
    String? tagFilter,
  }) {
    return CustomersState(
      customers: customers ?? this.customers,
      lines: lines ?? this.lines,
      tab: tab ?? this.tab,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      tagFilter: clearTagFilter ? null : (tagFilter ?? this.tagFilter),
    );
  }

  @override
  List<Object?> get props => [customers, lines, tab, searchQuery, statusFilter, tagFilter];
}

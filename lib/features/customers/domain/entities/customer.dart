import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';

enum CustomerStatus { normal, troubled, blocked }

extension CustomerStatusLabel on CustomerStatus {
  String get label {
    switch (this) {
      case CustomerStatus.normal:
        return 'customers.status.normal'.tr();
      case CustomerStatus.troubled:
        return 'customers.status.troubled'.tr();
      case CustomerStatus.blocked:
        return 'customers.status.blocked'.tr();
    }
  }
}

/// A customer who buys SIM/eSIM lines. Soft-deletable (`deleted`), fully
/// editable, and pin-to-top-able — matches design/screenshots/customers.png.
class Customer extends Equatable {
  final String id;
  final String name;
  final String contactNumber;
  final List<String> tags;
  final CustomerStatus status;
  final bool pinned;
  final String notes;
  final bool deleted;

  const Customer({
    required this.id,
    required this.name,
    required this.contactNumber,
    this.tags = const [],
    this.status = CustomerStatus.normal,
    this.pinned = false,
    this.notes = '',
    this.deleted = false,
  });

  Customer copyWith({
    String? name,
    String? contactNumber,
    List<String>? tags,
    CustomerStatus? status,
    bool? pinned,
    String? notes,
    bool? deleted,
  }) {
    return Customer(
      id: id,
      name: name ?? this.name,
      contactNumber: contactNumber ?? this.contactNumber,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      pinned: pinned ?? this.pinned,
      notes: notes ?? this.notes,
      deleted: deleted ?? this.deleted,
    );
  }

  @override
  List<Object?> get props => [id, name, contactNumber, tags, status, pinned, notes, deleted];
}

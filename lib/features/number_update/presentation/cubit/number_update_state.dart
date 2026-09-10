import 'package:equatable/equatable.dart';

import '../../domain/entities/number_update_entry.dart';

class NumberUpdateState extends Equatable {
  final String phoneNumber;
  final bool isSubmitting;
  final List<NumberUpdateEntry> log;

  const NumberUpdateState({
    this.phoneNumber = '',
    this.isSubmitting = false,
    this.log = const [],
  });

  /// History for exactly the number currently typed in, newest first —
  /// empty (and the page shows its empty state) until something is typed.
  List<NumberUpdateEntry> get entriesForCurrentNumber {
    final number = phoneNumber.trim();
    if (number.isEmpty) return const [];
    final matches = log.where((e) => e.phoneNumber == number).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return matches;
  }

  NumberUpdateState copyWith({
    String? phoneNumber,
    bool? isSubmitting,
    List<NumberUpdateEntry>? log,
  }) {
    return NumberUpdateState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      log: log ?? this.log,
    );
  }

  @override
  List<Object?> get props => [phoneNumber, isSubmitting, log];
}

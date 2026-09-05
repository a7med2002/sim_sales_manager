import 'package:equatable/equatable.dart';

import '../../domain/entities/number_update_entry.dart';

class NumberUpdateState extends Equatable {
  final String phoneNumber;
  final bool isSubmitting;
  final List<NumberUpdateEntry> log;

  /// A translation key (not resolved text — same convention as
  /// `LoginState`) for a validation problem that stopped `submitUpdate`
  /// before it ever called a provider: the number isn't registered to
  /// any Line in the app, or its company has no Number Update provider
  /// configured. `errorMessageArgs` carries any `namedArgs` the key
  /// needs (e.g. the company's name).
  final String? errorMessage;
  final Map<String, String>? errorMessageArgs;

  const NumberUpdateState({
    this.phoneNumber = '',
    this.isSubmitting = false,
    this.log = const [],
    this.errorMessage,
    this.errorMessageArgs,
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
    bool clearErrorMessage = false,
    String? errorMessage,
    Map<String, String>? errorMessageArgs,
  }) {
    return NumberUpdateState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      log: log ?? this.log,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      errorMessageArgs: clearErrorMessage ? null : (errorMessageArgs ?? this.errorMessageArgs),
    );
  }

  @override
  List<Object?> get props => [phoneNumber, isSubmitting, log, errorMessage, errorMessageArgs];
}

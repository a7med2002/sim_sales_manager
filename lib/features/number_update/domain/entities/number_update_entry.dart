import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';

enum NumberUpdateStatus { success, notFound, failed }

extension NumberUpdateStatusLabel on NumberUpdateStatus {
  String get label => switch (this) {
        NumberUpdateStatus.success => 'numberUpdate.status.success'.tr(),
        NumberUpdateStatus.notFound => 'numberUpdate.status.notFound'.tr(),
        NumberUpdateStatus.failed => 'numberUpdate.status.failed'.tr(),
      };
}

/// One row in a number's update history — either a manual "Update Number"
/// tap or (once the real platform lookup exists) an automatic refresh.
class NumberUpdateEntry extends Equatable {
  final String id;
  final String phoneNumber;
  final DateTime timestamp;
  final NumberUpdateStatus status;
  final String message;

  const NumberUpdateEntry({
    required this.id,
    required this.phoneNumber,
    required this.timestamp,
    required this.status,
    required this.message,
  });

  @override
  List<Object?> get props => [id, phoneNumber, timestamp, status, message];
}

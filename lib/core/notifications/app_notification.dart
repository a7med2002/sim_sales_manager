import 'package:equatable/equatable.dart';

import 'notification_type.dart';

/// One row from the local `notifications` table (see
/// `notifications_table.dart`) — a plain read model for the inbox page.
class AppNotification extends Equatable {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final String? relatedEntityId;
  final DateTime fireAt;
  final bool read;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.relatedEntityId,
    required this.fireAt,
    required this.read,
  });

  bool get isPending => fireAt.isAfter(DateTime.now());

  @override
  List<Object?> get props => [id, type, title, body, relatedEntityId, fireAt, read];
}
